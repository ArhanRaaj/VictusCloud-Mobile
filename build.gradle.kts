plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "2.0.20" apply false
}

// The project lives inside a synced cloud folder, whose file-locking breaks
// Gradle's incremental output cleanup. Build into a local, unsynced directory.
// Override with -PoutDir=/some/path, or delete this block if you relocate the project.
val isolatedBuildDir: String? = (findProperty("outDir") as String?)
    ?: System.getenv("MJL_BUILD_DIR")

if (isolatedBuildDir != null) {
    allprojects {
        layout.buildDirectory.set(file("$isolatedBuildDir/${project.name}"))
    }
}
