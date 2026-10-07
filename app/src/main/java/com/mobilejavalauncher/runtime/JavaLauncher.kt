package com.mobilejavalauncher.runtime

import android.content.Context
import android.os.Build
import com.mobilejavalauncher.LauncherApp
import com.mobilejavalauncher.model.Account
import com.mobilejavalauncher.model.LaunchProfile
import com.oracle.dalvik.VMLauncher
import net.kdt.pojavlaunch.utils.JREUtils
import java.io.File
import java.util.TimeZone

/**
 * Assembles the actual Minecraft: Java Edition command line and hands it to
 * libpojavexec.so, which creates the JVM inside this process.
 */
class JavaLauncher(
    private val activity: Context,
    private val runtime: RuntimeManager
) {

    fun buildClasspath(app: LauncherApp, versionId: String): String {
        val parts = mutableListOf<String>()

        // Our patched GLFW classes must shadow the desktop lwjgl-glfw jar.
        val lwjgl = runtime.lwjglClassesJar()
        if (lwjgl.exists()) parts.add(lwjgl.absolutePath)

        // Game jar
        parts.add(File(app.versionsDir, "$versionId/$versionId.jar").absolutePath)

        // Every downloaded library (includes lwjgl core/opengl/stb/tinyfd)
        app.librariesDir.walkTopDown()
            .filter { it.isFile && it.extension == "jar" && !it.name.contains("natives") }
            .forEach { parts.add(it.absolutePath) }

        return parts.joinToString(":")
    }

    fun launch(app: LauncherApp, profile: LaunchProfile, account: Account, versionJson: File) {
        val versionId = profile.versionId
        val versionDir = File(app.versionsDir, versionId)
        val jreHome = runtime.jreFor(versionId)
        val nativeLibDir = activity.applicationInfo.nativeLibraryDir
        val jreLibDir = pickJreLibDir(jreHome)
        val jvmDir = File(jreHome, "$jreLibDir/${if (File(jreHome, "$jreLibDir/server/libjvm.so").exists()) "server" else "client"}")

        val gameDir = File(app.launcherDir, "instances/$versionId").apply { mkdirs() }
        val tmpDir = File(activity.cacheDir, "jvm-tmp").apply { mkdirs() }

        // ---- Environment (read by libjvm, gl4es, LWJGL stub, and the JRE) ----
        val env = HashMap<String, String>()
        env["JAVA_HOME"] = jreHome.absolutePath
        env["HOME"] = gameDir.absolutePath
        env["TMPDIR"] = tmpDir.absolutePath
        env["POJAV_NATIVEDIR"] = nativeLibDir
        env["POJAV_RENDERER"] = profile.renderer
        // GL4ES tuning: matches what PojavLauncher sets for stability.
        env["LIBGL_ES"] = if (profile.renderer == "opengles3" || profile.renderer == "opengles3_ltw") "3" else "2"
        env["LIBGL_MIPMAP"] = "3"
        env["LIBGL_NOERROR"] = "1"
        env["LIBGL_NOINTOVLHACK"] = "1"
        env["LIBGL_NORMALIZE"] = "1"
        env["force_glsl_extensions_warn"] = "true"
        env["MESA_GLSL_CACHE_DIR"] = tmpDir.absolutePath
        env["PATH"] = "${jreHome.absolutePath}/bin:" + (System.getenv("PATH") ?: "")

        val ld = buildString {
            append(jvmDir.absolutePath).append(':')
            append(jreHome.absolutePath).append('/').append(jreLibDir).append("/jli:")
            append(jreHome.absolutePath).append('/').append(jreLibDir).append(':')
            append("/system/lib64:/vendor/lib64:")
            append(nativeLibDir)
        }
        env["LD_LIBRARY_PATH"] = ld
        JREUtils.LD_LIBRARY_PATH = ld
        JREUtils.jvmLibraryPath = jvmDir.absolutePath
        for ((k, v) in env) {
            runCatching { android.system.Os.setenv(k, v, true) }
        }
        JREUtils.setLdLibraryPath(ld)

        val width = 1280; val height = 720
        env["AWTSTUB_WIDTH"] = width.toString()
        env["AWTSTUB_HEIGHT"] = height.toString()
        runCatching { android.system.Os.setenv("AWTSTUB_WIDTH", width.toString(), true) }
        runCatching { android.system.Os.setenv("AWTSTUB_HEIGHT", height.toString(), true) }

        // ---- Load the graphics backend + JRE internals before the JVM starts ----
        val renderLib = when (profile.renderer) {
            "opengles3_ltw" -> "libltw.so"
            "vulkan_zink" -> "libOSMesa.so"
            else -> "libgl4es_114.so"
        }
        JREUtils.dlopen(renderLib)
        JREUtils.initJavaRuntime(jreHome.absolutePath, nativeLibDir, jreLibDir)

        // ---- Arguments ----
        val args = ArrayList<String>()
        args.add("java")
        args.add("-Xmx${profile.memoryMb}M")
        args.add("-Xms${profile.memoryMb}M")
        profile.jvmArgs.split(' ').filter { it.isNotBlank() && !it.startsWith("-Xmx") && !it.startsWith("-Xms") }
            .forEach { args.add(it) }
        args.add("-XX:ActiveProcessorCount=${Runtime.getRuntime().availableProcessors()}")
        args.add("-Djava.home=${jreHome.absolutePath}")
        args.add("-Djava.io.tmpdir=${tmpDir.absolutePath}")
        args.add("-Duser.home=${gameDir.absolutePath}")
        args.add("-Dos.name=Linux")
        args.add("-Dos.version=Android-${Build.VERSION.RELEASE}")
        args.add("-Duser.timezone=${TimeZone.getDefault().id}")
        args.add("-Dorg.lwjgl.opengl.libname=$renderLib")
        args.add("-Dorg.lwjgl.freetype.libname=$nativeLibDir/libfreetype.so")
        args.add("-Dorg.lwjgl.vulkan.libname=libvulkan.so")
        args.add("-Dglfwstub.windowWidth=$width")
        args.add("-Dglfwstub.windowHeight=$height")
        args.add("-Dglfwstub.initEgl=false")
        args.add("-Djna.boot.library.path=$nativeLibDir")
        args.add("-Dlog4j2.formatMsgNoLookups=true")
        args.add("-Dfml.earlyprogresswindow=false")
        args.add("-Djdk.lang.Process.launchMechanism=FORK")
        args.add("-Djava.class.path=${buildClasspath(app, versionId)}")

        // Game arguments
        args.add("net.minecraft.client.main.Main")
        args.add("--username"); args.add(account.name)
        args.add("--version"); args.add(versionId)
        args.add("--gameDir"); args.add(gameDir.absolutePath)
        args.add("--assetsDir"); args.add(app.assetsDir.absolutePath)
        args.add("--assetIndex"); args.add(assetIndexFor(versionJson))
        args.add("--uuid"); args.add(account.uuid ?: "00000000000000000000000000000000")
        args.add("--accessToken"); args.add(if (account.isPremium) (account.accessToken ?: "0") else "0")
        args.add("--userType"); args.add(if (account.isPremium) "msa" else "legacy")
        args.add("--versionType"); args.add("MJL")

        // ---- Go ----
        JREUtils.initializeHooks()
        JREUtils.chdir(gameDir.absolutePath)
        val exitCode = VMLauncher.launchJVM(args.toTypedArray())
        throw IllegalStateException("Minecraft exited with code $exitCode")
    }

    private fun pickJreLibDir(jreHome: File): String {
        val candidates = listOf("lib/aarch64", "lib/arm64", "lib/arm", "lib/aarch32", "lib/i386", "lib/amd64")
        for (c in candidates) {
            if (File(jreHome, c).isDirectory) return c
        }
        return "lib"
    }

    private fun assetIndexFor(versionJson: File): String = runCatching {
        com.google.gson.JsonParser.parseString(versionJson.readText())
            .asJsonObject.getAsJsonObject("assetIndex").get("id").asString
    }.getOrDefault("legacy")
}
