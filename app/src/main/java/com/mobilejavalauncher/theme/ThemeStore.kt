package com.mobilejavalauncher.theme

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.core.view.ViewCompat

/**
 * A small theming engine driven by a single persisted record.
 * The editor writes here; every screen reads here, so changes are live.
 */
data class LauncherTheme(
    val name: String = "Victus",
    val accent: Int = 0xFF7B6BE0.toInt(),
    val accentSecondary: Int = 0xFF3D3DB5.toInt(),
    val background: Int = 0xFF101214.toInt(),
    val surface: Int = 0xFF1A1D21.toInt(),
    val text: Int = 0xFFFFFFFF.toInt(),
    val textMuted: Int = 0xFF9AA0A6.toInt(),
    val cornerRadius: Int = 14,
    val darkMode: Boolean = true
)

class ThemeStore(context: Context) {

    private val prefs = context.getSharedPreferences("mjl_theme", Context.MODE_PRIVATE)

    companion object {
        val PRESETS = listOf(
            LauncherTheme(name = "Victus",
                accent = 0xFF7B6BE0.toInt(), accentSecondary = 0xFF4B2FC0.toInt(),
                background = 0xFF101214.toInt(), surface = 0xFF1A1D21.toInt()),
            LauncherTheme(name = "Emerald",
                accent = 0xFF3DDC84.toInt(), accentSecondary = 0xFF2BB673.toInt(),
                background = 0xFF0B1410.toInt(), surface = 0xFF13221A.toInt()),
            LauncherTheme(name = "Nether",
                accent = 0xFFFF5C42.toInt(), accentSecondary = 0xFFB32D1B.toInt(),
                background = 0xFF1A0F0D.toInt(), surface = 0xFF261512.toInt()),
            LauncherTheme(name = "Lapis",
                accent = 0xFF4A9BFF.toInt(), accentSecondary = 0xFF2857B8.toInt(),
                background = 0xFF0A1220.toInt(), surface = 0xFF121D30.toInt()),
            LauncherTheme(name = "Daylight",
                accent = 0xFF6D5BD0.toInt(), accentSecondary = 0xFF4B3FAF.toInt(),
                background = 0xFFF4F5F8.toInt(), surface = 0xFFFFFFFF.toInt(),
                text = 0xFF14161A.toInt(), textMuted = 0xFF5A6068.toInt(), darkMode = false)
        )
    }

    fun load(): LauncherTheme = LauncherTheme(
        name = prefs.getString("name", "Victus") ?: "Victus",
        accent = prefs.getInt("accent", 0xFF7B6BE0.toInt()),
        accentSecondary = prefs.getInt("accent_secondary", 0xFF3D3DB5.toInt()),
        background = prefs.getInt("background", 0xFF101214.toInt()),
        surface = prefs.getInt("surface", 0xFF1A1D21.toInt()),
        text = prefs.getInt("text", 0xFFFFFFFF.toInt()),
        textMuted = prefs.getInt("text_muted", 0xFF9AA0A6.toInt()),
        cornerRadius = prefs.getInt("corner", 14),
        darkMode = prefs.getBoolean("dark", true)
    )

    fun save(theme: LauncherTheme) {
        prefs.edit()
            .putString("name", theme.name)
            .putInt("accent", theme.accent)
            .putInt("accent_secondary", theme.accentSecondary)
            .putInt("background", theme.background)
            .putInt("surface", theme.surface)
            .putInt("text", theme.text)
            .putInt("text_muted", theme.textMuted)
            .putInt("corner", theme.cornerRadius)
            .putBoolean("dark", theme.darkMode)
            .apply()
    }

    fun reset() = prefs.edit().clear().apply()

    /** Applies the theme to a fragment/activity view tree by walking it. */
    fun applyTo(root: View, theme: LauncherTheme = load()) {
        root.setBackgroundColor(theme.background)
        applyRecursive(root, theme)
    }

    private fun applyRecursive(view: View, theme: LauncherTheme) {
        when (view) {
            is Button -> {
                view.background = rounded(theme.accent, theme.accentSecondary, theme.cornerRadius)
                view.setTextColor(contrastOn(theme.accent))
            }
            is TextView -> view.setTextColor(theme.text)
            is ViewGroup -> {
                if (view.id != View.NO_ID && view.background is ColorDrawable) {
                    view.setBackgroundColor(theme.surface)
                }
                for (i in 0 until view.childCount) applyRecursive(view.getChildAt(i), theme)
            }
        }
    }

    fun rounded(startColor: Int, endColor: Int, radius: Int): GradientDrawable =
        GradientDrawable(GradientDrawable.Orientation.LEFT_RIGHT, intArrayOf(startColor, endColor)).apply {
            cornerRadius = radius.toFloat()
        }

    fun contrastOn(color: Int): Int {
        val luminance = (0.299 * Color.red(color) + 0.587 * Color.green(color) + 0.114 * Color.blue(color)) / 255.0
        return if (luminance > 0.6) Color.BLACK else Color.WHITE
    }

    /** Parses #RRGGBB / #AARRGGBB, returns null when unusable. */
    fun parseHex(input: String): Int? {
        val cleaned = input.trim().removePrefix("#")
        if (cleaned.length != 6 && cleaned.length != 8) return null
        return runCatching {
            val value = cleaned.toLong(16)
            if (cleaned.length == 6) (0xFF000000L or value).toInt() else value.toInt()
        }.getOrNull()
    }

    fun toHex(color: Int): String = String.format("#%08X", color)
}
