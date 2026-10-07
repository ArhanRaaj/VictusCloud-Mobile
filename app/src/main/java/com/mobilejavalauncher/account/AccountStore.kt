package com.mobilejavalauncher.account

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.mobilejavalauncher.model.Account

class AccountStore(context: Context) {
    private val gson = Gson()
    private val prefs = EncryptedSharedPreferences.create(
        context,
        "mjl_accounts",
        MasterKey.Builder(context).setKeyScheme(MasterKey.KeyScheme.AES256_GCM).build(),
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun load(): MutableList<Account> {
        val json = prefs.getString("accounts", null) ?: return mutableListOf()
        return runCatching {
            gson.fromJson<MutableList<Account>>(json, object : TypeToken<MutableList<Account>>() {}.type)
        }.getOrDefault(mutableListOf())
    }

    fun save(accounts: List<Account>) {
        prefs.edit().putString("accounts", gson.toJson(accounts)).apply()
    }

    fun current(): Account? = load().firstOrNull { it.id == prefs.getString("current_account", null) }

    fun setCurrent(id: String?) {
        prefs.edit().putString("current_account", id).apply()
    }
}
