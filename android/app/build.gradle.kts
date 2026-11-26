import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter se aplica después de Android y Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

// La clave de publicación vive fuera del repositorio (P-050).
val propiedadesClave = Properties().apply {
    val archivo = rootProject.file("key.properties")
    if (archivo.exists()) archivo.inputStream().use { load(it) }
}
val tieneClavePropia = propiedadesClave.getProperty("storeFile") != null

android {
    namespace = "ec.coti.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "ec.coti.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (tieneClavePropia) {
            create("publicacion") {
                storeFile = file(propiedadesClave.getProperty("storeFile"))
                storePassword = propiedadesClave.getProperty("storePassword")
                keyAlias = propiedadesClave.getProperty("keyAlias")
                keyPassword = propiedadesClave.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Sin key.properties se firma con la clave de depuración, solo para pruebas.
            signingConfig = if (tieneClavePropia) {
                signingConfigs.getByName("publicacion")
            } else {
                logger.warn("Coti: falta android/key.properties; el release se firma con la clave de depuración.")
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Tema AppCompat que exige local_auth en Android 8 o anterior.
    implementation("androidx.appcompat:appcompat:1.7.0")
}
