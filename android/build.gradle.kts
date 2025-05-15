// TOP OF FILE
plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
}

// If you have repository settings, keep them like this:
//dependencyResolutionManagement {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

// Keep your existing build directory and tasks:
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
