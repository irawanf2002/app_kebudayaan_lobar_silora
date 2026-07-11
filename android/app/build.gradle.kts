plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_kebudyaan_lobar"

    compileSdk = 36
    
    // 1. Kunci versi NDK yang diminta oleh plugin jni & speech_to_text
    ndkVersion = "28.2.13676358" 
    
    // 2. TRIK KHUSUS: Mengarahkan Gradle ke folder tujuan agar dia mendownload 
    // secara otomatis jika versinya belum ada di laptopmu.
    ndkPath = "${android.sdkDirectory.absolutePath}/ndk/28.2.13676358"

    defaultConfig {
        applicationId = "com.example.app_kebudyaan_lobar"
        
        // FIX: Langsung set ke angka 23 agar aman dan mendukung Firebase terbaru
        minSdk = flutter.minSdkVersion 
        
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
        multiDexEnabled = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    packaging {
        resources {
            excludes += "META-INF/*"
        }
    }
}

dependencies {
    // 🔥 Desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // 🔥 Firebase BOM
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics")

    // 🔥 Multidex
    implementation("androidx.multidex:multidex:2.0.1")
}
