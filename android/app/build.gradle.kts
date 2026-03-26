import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Release signing
// Before building a release AAB you must generate a keystore and fill in
// android/key.properties. Example keytool command:
//
//   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
//     -keysize 2048 -validity 10000 -alias upload
//
// See https://docs.flutter.dev/deployment/android#create-an-upload-keystore
// ---------------------------------------------------------------------------
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
} else {
    logger.warn(
        "[SubSentry] key.properties not found. " +
        "Release signing will fail unless signing values are supplied " +
        "via environment variables or another mechanism."
    )
}

android {
    namespace = "com.subsentry.sub_sentry"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.subsentry.sub_sentry"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
                ?: error("keyAlias missing from key.properties")
            keyPassword = keystoreProperties["keyPassword"] as String?
                ?: error("keyPassword missing from key.properties")
            storeFile = (keystoreProperties["storeFile"] as String?)
                ?.let { file(it) }
                ?: error("storeFile missing from key.properties")
            storePassword = keystoreProperties["storePassword"] as String?
                ?: error("storePassword missing from key.properties")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
