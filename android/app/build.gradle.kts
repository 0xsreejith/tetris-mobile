import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}
val isReleaseBuild =
    gradle.startParameter.taskNames.any { it.contains("release", ignoreCase = true) }

android {
    namespace = "com.oxsreejith.tetrismobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.oxsreejith.tetrismobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                    ?: throw GradleException("Missing `storeFile` in android/key.properties")
                val storePassword = keystoreProperties.getProperty("storePassword")
                    ?: throw GradleException("Missing `storePassword` in android/key.properties")
                val keyAlias = keystoreProperties.getProperty("keyAlias")
                    ?: throw GradleException("Missing `keyAlias` in android/key.properties")
                val keyPassword = keystoreProperties.getProperty("keyPassword")
                    ?: throw GradleException("Missing `keyPassword` in android/key.properties")

                storeFile = rootProject.file(storeFilePath)
                this.storePassword = storePassword
                this.keyAlias = keyAlias
                this.keyPassword = keyPassword
            }
        }
    }

    buildTypes {
        release {
            if (!keystorePropertiesFile.exists()) {
                if (isReleaseBuild) {
                    throw GradleException(
                        "Missing android/key.properties for release signing. " +
                            "Copy android/key.properties.example to android/key.properties and fill values.",
                    )
                }
            } else {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
