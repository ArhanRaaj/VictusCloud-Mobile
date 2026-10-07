package com.mobilejavalauncher.account

import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.mobilejavalauncher.model.Account
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.UUID
import java.util.concurrent.TimeUnit

/**
 * Handles Microsoft (premium) OAuth device-code flow -> XBL -> XSTS -> Minecraft
 * services, and offline (cracked) account creation.
 */
class AuthManager(private val store: AccountStore) {
    private val gson = Gson()
    private val http = OkHttpClient.Builder()
        .connectTimeout(20, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

    companion object {
        // Device-code flow does not require a redirect URI secret in app builds.
        // Replace with your own Azure app client id.
        const val CLIENT_ID = "00000000-0000-0000-0000-000000000000"
        const val MSA_DEVICECODE_URL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/devicecode"
        const val MSA_TOKEN_URL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/token"
        const val XBL_URL = "https://user.auth.xboxlive.com/user/authenticate"
        const val XSTS_URL = "https://xsts.auth.xboxlive.com/xsts/authorize"
        const val MC_LOGIN_URL = "https://api.minecraftservices.com/authentication/login_with_xbox"
        const val MC_PROFILE_URL = "https://api.minecraftservices.com/minecraft/profile"
        const val SCOPE = "XboxLive.signin offline_access"
    }

    // ---------- Offline / crack ----------
    fun createOfflineAccount(name: String): Account {
        val uuid = UUID.nameUUIDFromBytes("OfflinePlayer:$name".toByteArray()).toString().replace("-", "")
        val acc = Account(
            id = UUID.randomUUID().toString(),
            name = name,
            type = Account.Type.OFFLINE,
            accessToken = "0",                 // offline token placeholder
            refreshToken = null,
            expiresAt = Long.MAX_VALUE,
            uuid = uuid
        )
        upsert(acc)
        return acc
    }

    // ---------- Microsoft premium ----------
    data class DeviceCodeStart(
        @SerializedName("device_code") val deviceCode: String,
        @SerializedName("user_code") val userCode: String,
        @SerializedName("verification_uri") val verificationUri: String,
        @SerializedName("expires_in") val expiresIn: Int,
        @SerializedName("interval") val interval: Int
    )

    fun startDeviceFlow(): DeviceCodeStart {
        val body = "client_id=$CLIENT_ID&scope=$SCOPE"
            .toRequestBody("application/x-www-form-urlencoded".toMediaType())
        val resp = http.newCall(
            Request.Builder().url(MSA_DEVICECODE_URL).post(body).build()
        ).execute()
        return gson.fromJson(resp.body!!.string(), DeviceCodeStart::class.java)
    }

    /** Polls until the user finishes signing in; returns the Minecraft account. */
    fun awaitDeviceFlow(start: DeviceCodeStart, onUserCodeNeeded: (DeviceCodeStart) -> Unit): Account {
        onUserCodeNeeded(start)
        val interval = (start.interval.takeIf { it > 0 } ?: 5).toLong()
        while (true) {
            Thread.sleep(interval * 1000)
            val form = "grant_type=urn:ietf:params:oauth:grant-type:device_code" +
                    "&client_id=$CLIENT_ID" +
                    "&device_code=${start.deviceCode}"
            val resp = http.newCall(
                Request.Builder().url(MSA_TOKEN_URL)
                    .post(form.toRequestBody("application/x-www-form-urlencoded".toMediaType()))
                    .build()
            ).execute()
            val json = gson.fromJson(resp.body!!.string(), Map::class.java)
            val access = json["access_token"] as? String
            val refresh = json["refresh_token"] as? String
            if (access != null) return finishMsaLogin(access, refresh)
            val error = json["error"] as? String ?: continue
            if (error == "authorization_pending" || error == "slow_down") continue
            throw IllegalStateException("MSA auth failed: $error")
        }
    }

    fun refreshAccessToken(refreshToken: String): Account {
        val form = "grant_type=refresh_token&client_id=$CLIENT_ID&refresh_token=$refreshToken"
        val resp = http.newCall(
            Request.Builder().url(MSA_TOKEN_URL)
                .post(form.toRequestBody("application/x-www-form-urlencoded".toMediaType()))
                .build()
        ).execute()
        val json = gson.fromJson(resp.body!!.string(), Map::class.java)
        val access = json["access_token"] as? String
            ?: throw IllegalStateException("Refresh failed: $json")
        return finishMsaLogin(access, (json["refresh_token"] as? String) ?: refreshToken)
    }

    private fun finishMsaLogin(msaAccessToken: String, refreshToken: String?): Account {
        // 1) XBL
        val xblJson = postJson(XBL_URL, """{
            "Properties":{"AuthMethod":"RPS","SiteName":"user.auth.xboxlive.com",
            "RpsTicket":"d=$msaAccessToken"},
            "RelyingParty":"http://auth.xboxlive.com","TokenType":"JWT"}""")
        val xblToken = xblJson["Token"] as? String ?: error("XBL failed")

        // 2) XSTS
        val xstsJson = postJson(XSTS_URL, """{
            "Properties":{"SandboxId":"RETAIL","UserTokens":["$xblToken"]},
            "RelyingParty":"rp://api.minecraftservices.com/","TokenType":"JWT"}""")
        val xstsToken = xstsJson["Token"] as? String ?: error("XSTS failed")
        @Suppress("UNCHECKED_CAST")
        val uhs = ((xstsJson["DisplayClaims"] as? Map<String, Any>)?.get("xui")
                as? List<Map<String, Any>>)?.firstOrNull()?.get("uhs") as? String ?: error("UHS missing")

        // 3) Minecraft login
        val mcJson = postJson(MC_LOGIN_URL, """{"identityToken":"XBL3.0 x=$uhs;$xstsToken"}""")
        val mcAccess = mcJson["access_token"] as? String ?: error("MC login failed")
        val expiresAt = System.currentTimeMillis() +
                (((mcJson["expires_in"] as? Double) ?: 86400.0) * 1000).toLong()

        // 4) Profile
        val profReq = Request.Builder().url(MC_PROFILE_URL)
            .header("Authorization", "Bearer $mcAccess").build()
        val profResp = http.newCall(profReq).execute()
        val profJson = gson.fromJson(profResp.body!!.string(), Map::class.java)
        val name = profJson["name"] as? String ?: error("No Minecraft profile — account may not own the game")
        val uuid = (profJson["id"] as? String) ?: ""

        val acc = Account(
            id = uuid, name = name, type = Account.Type.MICROSOFT,
            accessToken = mcAccess, refreshToken = refreshToken,
            expiresAt = expiresAt, uuid = uuid
        )
        upsert(acc)
        return acc
    }

    private fun postJson(url: String, body: String): Map<*, *> {
        val req = Request.Builder().url(url)
            .header("Content-Type", "application/json")
            .post(body.toRequestBody("application/json".toMediaType()))
            .build()
        val resp = http.newCall(req).execute()
        return gson.fromJson(resp.body!!.string(), Map::class.java)
    }

    private fun upsert(acc: Account) {
        val list = store.load()
        list.removeAll { it.id == acc.id }
        list.add(acc)
        store.save(list)
        store.setCurrent(acc.id)
    }
}
