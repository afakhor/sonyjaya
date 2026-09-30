plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sonyjaya"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.sonyjaya"
        minSdk = 23 // WAJIB 23 buat sqlite3_flutter_libs & isar_community
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true // WAJIB biar Isar + sqlite3 gak FC hitam
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