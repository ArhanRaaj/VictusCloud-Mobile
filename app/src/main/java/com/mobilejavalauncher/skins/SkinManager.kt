package com.mobilejavalauncher.skins

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import com.google.gson.Gson
import com.mobilejavalauncher.model.Account
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.File

class SkinManager(private val app: Context, private val skinsDir: File) {
    private val gson = Gson()
    private val http = OkHttpClient()

    data class SkinEntry(val name: String, val file: String, val model: String) // classic|slim

    fun list(): List<SkinEntry> =
        skinsDir.listFiles { f -> f.extension == "png" }
            ?.map { SkinEntry(it.nameWithoutExtension, it.name, modelFor(it)) } ?: emptyList()

    fun import(source: android.net.Uri, resolver: android.content.ContentResolver): SkinEntry {
        val bmp = BitmapFactory.decodeStream(resolver.openInputStream(source))
            ?: error("Not a valid image")
        require(bmp.width == 64 && (bmp.height == 32 || bmp.height == 64)) { "Skin must be 64x32 or 64x64" }
        val name = "skin_${System.currentTimeMillis()}"
        val file = File(skinsDir, "$name.png")
        file.outputStream().use { bmp.compress(Bitmap.CompressFormat.PNG, 100, it) }
        return SkinEntry(name, file.name, modelFor(file))
    }

    fun delete(entry: SkinEntry) = File(skinsDir, entry.file).delete()

    private fun modelFor(file: File): String {
        // slim (Alex) detection: transparent armpit pixel heuristic at (55, 20)
        val bmp = BitmapFactory.decodeFile(file.absolutePath)
        val pixel = if (bmp.width >= 64) bmp.getPixel(55, 20) else 0
        return if (android.graphics.Color.alpha(pixel) < 128) "slim" else "classic"
    }

    /** Renders a simple front-view preview (head + body + legs) from a 64x64 skin. */
    fun renderPreview(skinFile: File, out: Bitmap) {
        val skin = BitmapFactory.decodeFile(skinFile.absolutePath) ?: return
        val canvas = Canvas(out)
        canvas.drawColor(android.graphics.Color.TRANSPARENT)
        val paint = Paint()
        fun drawFace(sx: Int, sy: Int, sw: Int, sh: Int, dx: Float, dy: Float, dw: Float, dh: Float) {
            val src = android.graphics.Rect(sx, sy, sx + sw, sy + sh)
            val dst = android.graphics.RectF(dx, dy, dx + dw, dy + dh)
            canvas.drawBitmap(skin, src, dst, paint)
        }
        val w = out.width.toFloat(); val scale = w / 16f
        // head front (8,8,8x8)
        drawFace(8, 8, 8, 8, 4 * scale, 0f, 8 * scale, 8 * scale)
        // body front (20,20,8x12)
        drawFace(20, 20, 8, 12, 4 * scale, 8 * scale, 8 * scale, 12 * scale)
        // right arm front (44,20,4x12)
        drawFace(44, 20, 4, 12, 0f, 8 * scale, 4 * scale, 12 * scale)
        // left arm front (36,52,4x12) for 64x64 skins
        if (skin.height == 64) drawFace(36, 52, 4, 12, 12 * scale, 8 * scale, 4 * scale, 12 * scale)
        else drawFace(44, 20, 4, 12, 12 * scale, 8 * scale, 4 * scale, 12 * scale)
        // legs
        drawFace(4, 20, 4, 12, 4 * scale, 20 * scale, 4 * scale, 12 * scale)
        drawFace(4, 20, 4, 12, 8 * scale, 20 * scale, 4 * scale, 12 * scale)
    }

    /** Uploads skin to Mojang for a premium account (requires Bearer token). */
    fun uploadToMojang(account: Account, skinFile: File, model: String): Boolean {
        val token = account.accessToken ?: return false
        val body = MultipartBody.Builder().setType(MultipartBody.FORM)
            .addFormDataPart("model", model)
            .addFormDataPart(
                "file", "skin.png",
                skinFile.asRequestBody("image/png".toMediaType())
            ).build()
        val req = Request.Builder()
            .url("https://api.minecraftservices.com/minecraft/profile/skins")
            .header("Authorization", "Bearer $token")
            .post(body).build()
        http.newCall(req).execute().use { return it.isSuccessful }
    }

    /** Captures current Mojang skin for the wardrobe (premium accounts). */
    fun fetchServerSkin(account: Account): File? {
        val token = account.accessToken ?: return null
        val req = Request.Builder()
            .url("https://api.minecraftservices.com/minecraft/profile")
            .header("Authorization", "Bearer $token").build()
        http.newCall(req).execute().use { resp ->
            if (!resp.isSuccessful) return null
            val json = gson.fromJson(resp.body!!.string(), Map::class.java)
            @Suppress("UNCHECKED_CAST")
            val skins = json["skins"] as? List<Map<String, Any>> ?: return null
            val url = skins.firstOrNull { it["state"] == "ACTIVE" }?.get("url") as? String ?: return null
            val out = File(skinsDir, "remote_${account.name}.png")
            return runCatching {
                okhttp3.OkHttpClient().newCall(Request.Builder().url(url).build()).execute().use { r ->
                    out.outputStream().use { r.body!!.byteStream().copyTo(it) }
                }
                out
            }.getOrNull()
        }
    }

    fun toJson(entry: SkinEntry): String = gson.toJson(entry)
    fun fromJson(s: String): SkinEntry = gson.fromJson(s, SkinEntry::class.java)
}
