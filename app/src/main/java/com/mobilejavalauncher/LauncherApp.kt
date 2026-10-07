package com.mobilejavalauncher

import android.app.Application
import java.io.File

class LauncherApp : Application() {
    lateinit var launcherDir: File      // root: /storage/emulated/0/Android/data/<pkg>/files/mjl
    lateinit var versionsDir: File
    lateinit var modsDir: File
    lateinit var shadersDir: File
    lateinit var resourcepacksDir: File
    lateinit var modpacksDir: File
    lateinit var skinsDir: File
    lateinit var assetsDir: File
    lateinit var librariesDir: File

    override fun onCreate() {
        super.onCreate()
        CrashLogger.install(this)
        val base = getExternalFilesDir(null) ?: filesDir
        launcherDir = File(base, "mjl").apply { mkdirs() }
        versionsDir = File(launcherDir, "versions").apply { mkdirs() }
        modsDir = File(launcherDir, "mods").apply { mkdirs() }
        shadersDir = File(launcherDir, "shaderpacks").apply { mkdirs() }
        resourcepacksDir = File(launcherDir, "resourcepacks").apply { mkdirs() }
        modpacksDir = File(launcherDir, "modpacks").apply { mkdirs() }
        skinsDir = File(launcherDir, "skins").apply { mkdirs() }
        assetsDir = File(launcherDir, "assets").apply { mkdirs() }
        librariesDir = File(launcherDir, "libraries").apply { mkdirs() }
    }
}
