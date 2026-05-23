allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // bonsoir_android (and some plugins) use the Kotlin 2.x `kotlin { }` DSL
    // without applying org.jetbrains.kotlin.android themselves.
    pluginManager.withPlugin("com.android.library") {
        if (!pluginManager.hasPlugin("org.jetbrains.kotlin.android")) {
            apply(plugin = "org.jetbrains.kotlin.android")
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
