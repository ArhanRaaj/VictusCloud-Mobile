package com.mobilejavalauncher

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import androidx.viewpager2.adapter.FragmentStateAdapter
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.mobilejavalauncher.ui.AccountsFragment
import com.mobilejavalauncher.ui.HomeFragment
import com.mobilejavalauncher.ui.InstallFragment
import com.mobilejavalauncher.ui.SettingsFragment
import com.mobilejavalauncher.ui.SkinsFragment

class MainActivity : AppCompatActivity() {
    private lateinit var pager: ViewPager2

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Apply the user's saved theme. Never let theming take the app down.
        runCatching { com.mobilejavalauncher.theme.ThemeStore(this).applyTo(window.decorView) }

        pager = findViewById(R.id.pager)
        pager.adapter = object : FragmentStateAdapter(this) {
            override fun getItemCount() = 5
            override fun createFragment(position: Int): Fragment = when (position) {
                0 -> HomeFragment()
                1 -> AccountsFragment()
                2 -> InstallFragment()
                3 -> SkinsFragment()
                else -> SettingsFragment()
            }
        }
        pager.isUserInputEnabled = false

        val nav = findViewById<BottomNavigationView>(R.id.bottomNav)
        nav.setOnItemSelectedListener { item ->
            pager.currentItem = when (item.itemId) {
                R.id.nav_home -> 0
                R.id.nav_accounts -> 1
                R.id.nav_install -> 2
                R.id.nav_skins -> 3
                else -> 4
            }
            true
        }
    }
}
