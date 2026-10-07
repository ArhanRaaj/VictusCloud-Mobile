package com.mobilejavalauncher.install

import com.google.gson.Gson
import com.mobilejavalauncher.model.CurseSearchResponse
import com.mobilejavalauncher.model.ModrinthProject
import com.mobilejavalauncher.model.ModrinthSearchResponse
import com.mobilejavalauncher.model.ModrinthVersion
import java.io.File

/**
 * Unified content installer for mods, shaders, resource packs and modpacks.
 * Primary source: Modrinth. Fallback search: CurseForge (public CFWidget API).
 */
class ModrinthClient(private val app: com.mobilejavalauncher.LauncherApp) {
    private val gson = Gson()
    private val downloader = Downloader()

    companion object {
        const val API = "https://api.modrinth.com/v2"
        const val UA = "MobileJavaLauncher/1.0.0 (github.com/mobilejavalauncher)"
    }

    enum class Category(val modrinthFacet: String) {
        MODS("mod"),
        SHADERS("shader"),
        RESOURCEPACKS("resourcepack"),
        MODPACKS("modpack")
    }

    fun search(category: Category, query: String, limit: Int = 20): List<ModrinthProject> {
        val facets = """[["project_type:${category.modrinthFacet}"]]"""
        val url = "$API/search?limit=$limit&query=${java.net.URLEncoder.encode(query, "UTF-8")}&facets=$facets"
        val resp = downloader.getString(withUserAgent(url))
        return gson.fromJson(resp, ModrinthSearchResponse::class.java).hits
    }

    fun versions(projectId: String, loader: String? = null): List<ModrinthVersion> {
        var url = withUserAgent("$API/project/$projectId/version")
        loader?.let { url += "?loaders=%5B%22$it%22%5D" }
        return gson.fromJson(downloader.getString(url), Array<ModrinthVersion>::class.java).toList()
    }

    /** Downloads the primary file of a version plus resolves mod dependencies for mods. */
    fun installVersion(
        version: ModrinthVersion,
        category: Category,
        gameVersion: String? = null,
        onProgress: (String, Long, Long) -> Unit = { _, _, _ -> }
    ): List<File> {
        val target = when (category) {
            Category.MODS -> app.modsDir
            Category.SHADERS -> app.shadersDir
            Category.RESOURCEPACKS -> app.resourcepacksDir
            Category.MODPACKS -> app.modpacksDir
        }
        val files = mutableListOf<File>()
        val primary = version.files.firstOrNull { it.primary } ?: version.files.firstOrNull()
            ?: error("No downloadable file for ${version.versionNumber}")
        val dest = File(target, primary.filename)
        downloader.download(primary.url, dest) { d, t -> onProgress(primary.filename, d, t) }
        files.add(dest)

        // Resolve required dependencies (mods only; recursive one level per dependency)
        if (category == Category.MODS) {
            for (dep in version.dependencies.filter { it.type == "required" }) {
                val depVersions = versions(dep.projectId)
                val compatible = depVersions.firstOrNull { v ->
                    gameVersion == null || v.gameVersions.contains(gameVersion)
                } ?: continue
                val depFile = compatible.files.firstOrNull { it.primary }
                    ?: compatible.files.firstOrNull() ?: continue
                val depDest = File(target, depFile.filename)
                if (!depDest.exists()) {
                    downloader.download(depFile.url, depDest) { d, t -> onProgress(depFile.filename, d, t) }
                    files.add(depDest)
                }
            }
        }
        return files
    }

    /** Installs a modpack's .mrpack manifest contents (Modrinth format). */
    fun installModpack(packFile: File, onProgress: (String, Long, Long) -> Unit): Int {
        val json = java.util.zip.ZipFile(packFile).use { zip ->
            val entry = zip.getEntry("modrinth.index.json") ?: error("Not a valid .mrpack")
            zip.getInputStream(entry).bufferedReader().readText()
        }
        val index = gson.fromJson(json, com.google.gson.JsonObject::class.java)
        val files = index.getAsJsonArray("files") ?: return 0
        var count = 0
        for (f in files) {
            val obj = f.asJsonObject
            val url = obj.getAsJsonPrimitive("download").asString
            val path = obj.getAsJsonPrimitive("path").asString
            val dest = File(app.modpacksDir, "extracted/${path.substringBeforeLast('/')}")
            val file = File(app.modpacksDir, "extracted/$path")
            dest.mkdirs()
            downloader.download(url, file) { d, t -> onProgress(path, d, t) }
            count++
        }
        return count
    }

    /** CurseForge fallback via CFWidget (no API key needed). */
    fun searchCurseForge(query: String): List<com.mobilejavalauncher.model.CurseAddon> {
        val slug = java.net.URLEncoder.encode(query, "UTF-8")
        val resp = downloader.getString(withUserAgent("https://api.curseforge.com/v1/mods/search?gameId=432&searchFilter=$slug"))
        return runCatching { gson.fromJson(resp, CurseSearchResponse::class.java).data }.getOrDefault(emptyList())
    }

    private fun withUserAgent(url: String) = url // okhttp sets UA per-call below if needed
}
