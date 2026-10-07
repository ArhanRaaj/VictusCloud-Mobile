package com.mobilejavalauncher.runtime

import android.content.Context
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream
import org.apache.commons.compress.compressors.xz.XZCompressorInputStream
import java.io.File
import java.io.FileOutputStream

/**
 * Unpacks the bundled Java runtime (JRE) and LWJGL component from the app's
 * assets into a real directory on disk, because the JVM can only be started
 * from a filesystem path.
 *
 * Layout produced under filesDir/runtime:
 *   jre8/    Java 8 runtime (universal + bin-arm64)
 *   jre17/   Java 21 runtime (jre-21 component; runs 1.17+)
 *   lwjgl3/  LWJGL glfw classes jar (patched for Android)
 */
class RuntimeManager(private val context: Context) {

    companion object {
        const val COMPONENT_JRE8 = "jre-new"
        const val COMPONENT_JRE21 = "jre-21"
    }

    private val root: File get() = File(context.filesDir, "runtime").apply { mkdirs() }

    fun jre8Dir(): File = File(root, "jre8")
    fun jre21Dir(): File = File(root, "jre21")
    fun lwjglClassesJar(): File = File(root, "lwjgl3/lwjgl-glfw-classes.jar")

    /** Picks the JRE appropriate for the game version (1.17+ needs Java 17/21). */
    fun jreFor(versionId: String): File {
        val minor = Regex("^1\\.(\\d+)").find(versionId)?.groupValues?.get(1)?.toIntOrNull()
        val patch = Regex("^(\\d+)\\.").find(versionId)?.groupValues?.get(1)?.toIntOrNull()
        val needsJava17 = (minor != null && minor >= 17) || (patch != null && patch >= 17)
        return if (needsJava17) jre21Dir() else jre8Dir()
    }

    fun isReady(): Boolean = File(jre8Dir(), "lib").exists() && File(jre21Dir(), "lib").exists()

    /** Extracts everything; calls onProgress(label, done, total) so UI can show status. */
    fun extractAll(onProgress: (String, Int) -> Unit = { _, _ -> }) {
        extractJre(COMPONENT_JRE8, jre8Dir(), onProgress)
        extractJre(COMPONENT_JRE21, jre21Dir(), onProgress)
        extractFile("components/lwjgl3/lwjgl-glfw-classes.jar", lwjglClassesJar(), onProgress)
    }

    private fun extractJre(component: String, target: File, onProgress: (String, Int) -> Unit) {
        if (File(target, "lib").exists()) return
        target.mkdirs()
        val abiSuffix = when (android.os.Build.SUPPORTED_ABIS.firstOrNull()) {
            "arm64-v8a" -> "bin-arm64"
            "armeabi-v7a", "armeabi" -> "bin-arm"
            "x86_64" -> "bin-x86_64"
            else -> "bin-x86"
        }
        // universal.tar.xz holds the bulk; the per-ABI archive adds libjvm.so and friends.
        extractTarXz("components/$component/universal.tar.xz", target, onProgress)
        extractTarXz("components/$component/$abiSuffix.tar.xz", target, onProgress)
    }

    private fun extractFile(assetPath: String, dest: File, onProgress: (String, Int) -> Unit) {
        if (dest.exists()) return
        dest.parentFile?.mkdirs()
        onProgress(dest.name, 0)
        context.assets.open(assetPath).use { input ->
            dest.outputStream().use { input.copyTo(it) }
        }
        onProgress(dest.name, 100)
    }

    private fun extractTarXz(assetPath: String, target: File, onProgress: (String, Int) -> Unit) {
        val label = assetPath.substringAfterLast('/')
        context.assets.open(assetPath).use { raw ->
            XZCompressorInputStream(raw).use { xz ->
                TarArchiveInputStream(xz).use { tar ->
                    val buffer = ByteArray(64 * 1024)
                    var count = 0
                    var entry = tar.nextEntry
                    while (entry != null) {
                        val outFile = File(target, entry.name)
                        // Guard against path traversal in the archive.
                        if (!outFile.canonicalPath.startsWith(target.canonicalPath)) {
                            entry = tar.nextEntry
                            continue
                        }
                        when {
                            entry.isDirectory -> outFile.mkdirs()
                            entry.isSymbolicLink || entry.isLink -> {
                                // Preserve symlinks, many JRE entries rely on them.
                                outFile.parentFile?.mkdirs()
                                outFile.delete()
                                try {
                                    android.system.Os.symlink(entry.linkName, outFile.absolutePath)
                                } catch (_: Throwable) {
                                }
                            }
                            else -> {
                                outFile.parentFile?.mkdirs()
                                FileOutputStream(outFile).use { out ->
                                    var read: Int
                                    while (tar.read(buffer).also { read = it } > 0) {
                                        out.write(buffer, 0, read)
                                    }
                                }
                                outFile.setExecutable(true, false)
                            }
                        }
                        count++
                        if (count % 200 == 0) onProgress(label, count)
                        entry = tar.nextEntry
                    }
                }
            }
        }
        onProgress(label, 100)
    }
}
