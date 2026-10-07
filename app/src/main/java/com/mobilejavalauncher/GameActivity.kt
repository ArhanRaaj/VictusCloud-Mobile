package com.mobilejavalauncher

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.Gravity
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import com.mobilejavalauncher.account.AccountStore
import com.mobilejavalauncher.model.LaunchProfile
import com.mobilejavalauncher.runtime.JavaLauncher
import com.mobilejavalauncher.runtime.RuntimeManager
import net.kdt.pojavlaunch.utils.JREUtils
import java.io.File

/**
 * Hosts the SurfaceView that the patched LWJGL GLFW stub renders Minecraft into,
 * and starts the JVM in a background thread once that surface exists.
 */
class GameActivity : Activity() {

    companion object {
        const val EXTRA_VERSION = "version"
        private const val TAG = "MJL_Game"
    }

    private lateinit var surfaceView: SurfaceView
    private lateinit var statusView: TextView
    private var launched = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val app = application as LauncherApp

        val root = FrameLayout(this)
        root.setBackgroundColor(0xFF101214.toInt())

        surfaceView = SurfaceView(this)
        root.addView(surfaceView, FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))

        statusView = TextView(this).apply {
            gravity = Gravity.CENTER
            setTextColor(0xFFFFFFFF.toInt())
            text = "Preparing Java runtime…"
        }
        root.addView(statusView, FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))

        setContentView(root)

        // The bundled native runtime is arm64-only; say so instead of dying in
        // an UnsatisfiedLinkError deep inside the JVM loader.
        if (android.os.Build.SUPPORTED_ABIS.firstOrNull() != "arm64-v8a") {
            fail("This build ships an arm64-v8a runtime only.\n" +
                "Your device reports: ${android.os.Build.SUPPORTED_ABIS.joinToString()}")
            return
        }

        val versionId = intent.getStringExtra(EXTRA_VERSION) ?: run {
            fail("No version supplied"); return
        }

        surfaceView.holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                // Hand the surface to the GLFW bridge before the JVM boots.
                runCatching { JREUtils.setupBridgeWindow(holder.surface) }
                    .onFailure { Log.e(TAG, "setupBridgeWindow failed", it) }
                startGame(app, versionId)
            }

            override fun surfaceChanged(h: SurfaceHolder, f: Int, w: Int, ht: Int) {}
            override fun surfaceDestroyed(holder: SurfaceHolder) {
                runCatching { JREUtils.releaseBridgeWindow() }
            }
        })
    }

    private fun startGame(app: LauncherApp, versionId: String) {
        if (launched) return
        launched = true

        Thread {
            try {
                val runtime = RuntimeManager(this)
                if (!runtime.isReady()) {
                    runOnUiThread { statusView.text = "Extracting Java runtime (first run only)…" }
                    runtime.extractAll { label, done ->
                        runOnUiThread { statusView.text = "Extracting $label ($done%)" }
                    }
                }
                runOnUiThread { statusView.text = "Starting Java…" }

                val account = AccountStore(this).current()
                    ?: throw IllegalStateException("No account selected")
                val profile = LaunchProfile(
                    versionId = versionId,
                    memoryMb = getSharedPreferences("mjl_settings", MODE_PRIVATE)
                        .getInt("memory_mb", 2048),
                    jvmArgs = getSharedPreferences("mjl_settings", MODE_PRIVATE)
                        .getString("jvm_args", "-XX:+UseG1GC") ?: "-XX:+UseG1GC",
                    renderer = listOf("opengles2", "opengles3", "opengles3_ltw", "vulkan_zink")[
                        getSharedPreferences("mjl_settings", MODE_PRIVATE).getInt("renderer_idx", 0)]
                )
                val versionJson = File(app.versionsDir, "$versionId/$versionId.json")

                runOnUiThread { statusView.visibility = TextView.GONE }
                JavaLauncher(this, runtime).launch(app, profile, account, versionJson)
            } catch (t: Throwable) {
                Log.e(TAG, "Launch failed", t)
                fail("Launch failed: ${t.message ?: t.javaClass.simpleName}")
            }
        }.start()
    }

    private fun fail(message: String) {
        runOnUiThread {
            statusView.visibility = TextView.VISIBLE
            statusView.text = message
        }
    }
}
