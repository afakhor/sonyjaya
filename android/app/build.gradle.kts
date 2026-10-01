plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-plugin-loader")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sonyjaya"
    compileSdk = 35
    ndkVersion = "28.2.13676358" // <- UPDATE INI

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.sonyjaya"
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
            pickFirsts += listOf("**/libsqlite3.so", "**/libsqlite.so")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
