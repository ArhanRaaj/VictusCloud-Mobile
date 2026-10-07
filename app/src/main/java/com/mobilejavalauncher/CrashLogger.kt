package com.mobilejavalauncher

import android.content.Context
import java.io.File
import java.io.PrintWriter
import java.io.StringWriter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Writes uncaught exceptions to a file so a crash on a device can be read back
 * and shared without needing a logcat cable.
 */
object CrashLogger {

    private fun file(context: Context) = File(context.filesDir, "last_crash.txt")

    fun install(context: Context) {
        val previous = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            runCatching { record(context, throwable) }
            previous?.uncaughtException(thread, throwable)
        }
    }

    private fun record(context: Context, throwable: Throwable) {
        val timestamp = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US).format(Date())
        val writer = StringWriter()
        throwable.printStackTrace(PrintWriter(writer))
        val text = buildString {
            append("time: ").append(timestamp).append('\n')
            append("device: ").append(android.os.Build.MODEL)
                .append(" / Android ").append(android.os.Build.VERSION.RELEASE)
                .append(" / ").append(android.os.Build.SUPPORTED_ABIS.joinToString())
                .append('\n')
            append("app: ").append(context.packageName).append('\n')
            append("--- stack trace ---\n")
            append(writer.toString())
        }
        // Keep a short history so a second crash doesn't erase the first.
        val target = file(context)
        if (target.exists() && target.length() > 0) {
            target.copyTo(File(context.filesDir, "previous_crash.txt"), overwrite = true)
        }
        target.writeText(text)
    }

    fun lastCrash(context: Context): String =
        file(context).takeIf { it.exists() }?.readText()?.takeLast(4000) ?: ""

    fun clear(context: Context) {
        file(context).delete()
        File(context.filesDir, "previous_crash.txt").delete()
    }
}
