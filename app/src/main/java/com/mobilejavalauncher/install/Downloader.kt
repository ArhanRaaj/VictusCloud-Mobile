package com.mobilejavalauncher.install

import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.File
import java.util.concurrent.TimeUnit

class Downloader {
    private val http = OkHttpClient.Builder()
        .connectTimeout(20, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .build()

    fun download(url: String, dest: File, onProgress: (downloaded: Long, total: Long) -> Unit = { _, _ -> }): File {
        dest.parentFile?.mkdirs()
        val resp = http.newCall(Request.Builder().url(url).build()).execute()
        resp.use {
            check(it.isSuccessful) { "HTTP ${it.code} for $url" }
            val body = it.body ?: error("Empty body for $url")
            val total = body.contentLength()
            var done = 0L
            body.byteStream().use { input ->
                dest.outputStream().use { out ->
                    val buf = ByteArray(64 * 1024)
                    while (true) {
                        val n = input.read(buf)
                        if (n <= 0) break
                        out.write(buf, 0, n)
                        done += n
                        onProgress(done, total)
                    }
                }
            }
        }
        return dest
    }

    fun getString(url: String): String =
        http.newCall(Request.Builder().url(url).build()).execute().use {
            check(it.isSuccessful) { "HTTP ${it.code} for $url" }
            it.body!!.string()
        }
}
