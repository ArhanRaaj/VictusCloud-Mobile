package com.mobilejavalauncher.model

import com.google.gson.annotations.SerializedName

data class Account(
    val id: String,
    val name: String,
    val type: Type,             // OFFLINE or MICROSOFT
    val accessToken: String?,   // MSA/Minecraft token (premium only)
    val refreshToken: String?,
    val expiresAt: Long,
    val uuid: String?
) {
    enum class Type { OFFLINE, MICROSOFT }

    val isPremium: Boolean get() = type == Type.MICROSOFT
}

data class LaunchProfile(
    val versionId: String,
    val memoryMb: Int = 2048,
    val jvmArgs: String = "-XX:+UseG1GC",
    val renderer: String = "gl4es",  // gl4es | virgl | zink
    val mods: List<String> = emptyList(),
    val modpackId: String? = null
)

// --- Mojang version manifest models ---
data class VersionManifest(
    val latest: Latest,
    val versions: List<VersionEntry>
) {
    data class Latest(val release: String, val snapshot: String)
    data class VersionEntry(
        val id: String,
        val type: String,       // release | snapshot | old_beta ...
        val url: String,
        val releaseTime: String
    )
}

data class VersionDetails(
    val id: String,
    val downloads: Downloads,
    @SerializedName("assetIndex") val assetIndex: AssetIndexInfo,
    val libraries: List<Library>,
    val mainClass: String,
    val minecraftArguments: String?,
    @SerializedName("arguments") val args: ArgBlock?
) {
    data class Downloads(val client: ClientDownload)
    data class ClientDownload(val url: String, val sha1: String, val size: Long)
    data class AssetIndexInfo(val id: String, val url: String, val totalSize: Long)
    data class Library(
        val name: String,
        val downloads: LibDownloads?,
        val rules: List<Rule>?
    ) {
        data class LibDownloads(val artifact: Artifact?)
        data class Artifact(val url: String, val sha1: String, val path: String, val size: Long)
    }
    data class Rule(val action: String, val os: OsRule?)
    data class OsRule(val name: String?)
    data class ArgBlock(val game: List<Any>, val jvm: List<Any>)
}

// --- Modrinth API models ---
data class ModrinthSearchResponse(val hits: List<ModrinthProject>)
data class ModrinthProject(
    @SerializedName("project_id") val projectId: String,
    val slug: String,
    val title: String,
    val description: String,
    val downloads: Long,
    @SerializedName("latest_version") val latestVersion: String?
)
typealias ModrinthVersionsResponse = ArrayList<ModrinthVersion>
data class ModrinthVersion(
    val id: String,
    @SerializedName("version_number") val versionNumber: String,
    val files: List<ModrinthFile>,
    @SerializedName("game_versions") val gameVersions: List<String>,
    @SerializedName("loaders") val loaders: List<String>,
    val dependencies: List<Dependency> = emptyList()
) {
    data class ModrinthFile(val url: String, val filename: String, val primary: Boolean, val size: Long)
    data class Dependency(
        @SerializedName("project_id") val projectId: String,
        @SerializedName("dependency_type") val type: String
    )
}

data class CurseSearchResponse(val data: List<CurseAddon>)
data class CurseAddon(
    val id: Long,
    val name: String,
    val summary: String,
    val downloadCount: Long,
    val links: Links?
) {
    data class Links(val websiteUrl: String?)
}
