plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase plugin eklendi
}

android {
    namespace = "com.example.movie_app"
    compileSdk = 34

    ndkVersion = "27.0.12077973" // Firebase’in istediği NDK sürümü

    defaultConfig {
        applicationId = "com.example.movie_app"
        minSdk = 23 // Firebase auth için minimum 23 olmalı
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
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
