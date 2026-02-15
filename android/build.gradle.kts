buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
        classpath("com.google.firebase:firebase-crashlytics-gradle:3.0.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

/**
 * Temporary compatibility fix for older Android library plugins that do not declare `namespace`.
 *
 * AGP 8+ requires `namespace` to be set in every Android library module.
 * Some transitive Flutter plugins (from pub cache) can still ship without it, which breaks the build with:
 * "Namespace not specified. Specify a namespace in the module's build file ..."
 *
 * This block assigns a best-effort namespace only when it is missing.
 * It uses `plugins.withId("com.android.library")` instead of `afterEvaluate`, which
 * is no longer allowed in newer Gradle/AGP versions.
 *
 * Safe to remove once all plugins in your dependency tree support AGP 8+.
 */
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            if (namespace.isNullOrBlank()) {
                // Prefer using the group if set, otherwise fall back to a deterministic namespace.
                val fallback = if (project.group.toString().isNotBlank()) {
                    project.group.toString()
                } else {
                    "com.fitness.fitzee.${project.name.replace('-', '_')}"
                }
                namespace = fallback
            }
        }
    }
}