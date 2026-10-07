package com.mobilejavalauncher.install

import com.google.gson.Gson
import com.mobilejavalauncher.LauncherApp
import com.mobilejavalauncher.model.VersionDetails
import com.mobilejavalauncher.model.VersionManifest
import java.io.File

class VersionInstaller(private val app: LauncherApp) {
    private val gson = Gson()
    private val downloader = Downloader()

    companion object {
        const val MANIFEST_URL = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
    }

    fun fetchManifest(): VersionManifest =
        gson.fromJson(downloader.getString(MANIFEST_URL), VersionManifest::class.java)

    fun install(versionId: String, onProgress: (String, Long, Long) -> Unit): File {
        val manifest = fetchManifest()
        val entry = manifest.versions.first { it.id == versionId }
        val versionDir = File(app.versionsDir, versionId).apply { mkdirs() }

        // Version JSON
        val jsonFile = File(versionDir, "$versionId.json")
        if (!jsonFile.exists()) downloader.download(entry.url, jsonFile)
        val details = gson.fromJson(jsonFile.readText(), VersionDetails::class.java)

        // Client jar
        val jarFile = File(versionDir, "$versionId.jar")
        if (!jarFile.exists()) {
            downloader.download(details.downloads.client.url, jarFile) { d, t -> onProgress("client.jar", d, t) }
        }

        // Libraries (skip natives for other OSes — rules os.name == linux/windows excluded)
        for (lib in details.libraries) {
            val artifact = lib.downloads?.artifact ?: continue
            val allowed = lib.rules?.let { rules ->
                rules.none { it.os?.name in listOf("windows", "osx") && it.action == "allow" }
            } ?: true
            if (!allowed) continue
            val dest = File(app.librariesDir, artifact.path)
            if (!dest.exists()) {
                downloader.download(artifact.url, dest) { d, t -> onProgress(lib.name, d, t) }
            }
        }

        // Asset index + assets
        val indexFile = File(app.assetsDir, "indexes/${details.assetIndex.id}.json")
        if (!indexFile.exists()) {
            downloader.download(details.assetIndex.url, indexFile)
        }
        val index = gson.fromJson(indexFile.readText(), Map::class.java)
        @Suppress("UNCHECKED_CAST")
        val objects = index["objects"] as? Map<String, Map<String, Any>> ?: emptyMap()
        for ((name, obj) in objects) {
            val hash = obj["hash"] as? String ?: continue
            val sub = hash.substring(0, 2)
            val dest = File(app.assetsDir, "objects/$sub/$hash")
            if (!dest.exists()) {
                val url = "https://resources.download.minecraft.net/$sub/$hash"
                runCatching { downloader.download(url, dest) { d, t -> onProgress("asset: $name", d, t) } }
            }
        }

        return jarFile
    }

    fun installedVersions(): List<String> =
        app.versionsDir.listFiles { f -> f.isDirectory }
            ?.mapNotNull { f -> f.listFiles { g -> g.name.endsWith(".jar") }?.firstOrNull()?.let { f.name } }
            ?: emptyList()
}
