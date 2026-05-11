package com.example.emotionapp

import android.app.Application
import android.os.Build
import android.util.Log
import com.example.emotionapp.di.AppComponent
import com.example.emotionapp.di.DaggerAppComponent

class App : Application() {

    lateinit var appComponent: AppComponent
        private set

    override fun onCreate() {
        super.onCreate()

        val baseUrl = BuildConfig.API_BASE_URL
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "API_BASE_URL=$baseUrl")
            if (baseUrl.contains("10.0.2.2") && !isProbablyEmulator()) {
                Log.e(
                    TAG,
                    "Сейчас API_BASE_URL указывает на 10.0.2.2, а приложение запущено на ФИЗИЧЕСКОМ устройстве " +
                        "(${Build.MODEL}). 10.0.2.2 есть только в эмуляторе → будет SocketTimeoutException. " +
                        "В Android/local.properties задайте API_BASE_URL=http://IP_ВАШЕГО_MAC:8086/ " +
                        "(Mac и телефон в одной Wi‑Fi, в конце слэш), затем Rebuild."
                )
            }
        }

        appComponent = DaggerAppComponent.factory()
            .create(this, baseUrl)
    }

    private companion object {
        private const val TAG = "EmotionApp"

        /** 10.0.2.2 работает только в AVD; на реальном телефоне его использовать нельзя. */
        private fun isProbablyEmulator(): Boolean =
            Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.MODEL.contains("Emulator", ignoreCase = true)
                || Build.MODEL.contains("Android SDK built for x86", ignoreCase = true)
                || Build.MANUFACTURER.contains("Genymotion", ignoreCase = true)
                || (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || Build.PRODUCT == "google_sdk"
    }
}
