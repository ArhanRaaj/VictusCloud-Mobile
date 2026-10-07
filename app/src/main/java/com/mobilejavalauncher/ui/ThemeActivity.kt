package com.mobilejavalauncher.ui

import android.os.Bundle
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import com.mobilejavalauncher.R
import com.mobilejavalauncher.theme.ThemeStore

/** Full-screen theme editor, opened from Settings. */
class ThemeActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_theme)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        title = getString(R.string.theme_editor)

        runCatching { ThemeStore(this).applyTo(findViewById(R.id.themeHost)) }

        if (savedInstanceState == null) {
            supportFragmentManager.beginTransaction()
                .replace(R.id.themeHost, ThemeFragment())
                .commit()
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == android.R.id.home) {
            finish()
            return true
        }
        return super.onOptionsItemSelected(item)
    }
}
