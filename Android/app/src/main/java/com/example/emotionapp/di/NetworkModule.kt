package com.example.emotionapp.di

import android.content.Context
import android.content.SharedPreferences
import com.example.emotionapp.BuildConfig
import com.example.emotionapp.data.network.AuthTokenInterceptor
import com.example.emotionapp.data.network.TokenStorage
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import dagger.Module
import dagger.Provides
import java.util.concurrent.TimeUnit
import javax.inject.Named
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit

@Module
object NetworkModule {

    @Provides
    fun providePrefs(context: Context): SharedPreferences =
        context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)

    @Provides
    fun provideTokenStorage(prefs: SharedPreferences): TokenStorage =
        TokenStorage(prefs)

    @Provides
    fun provideJson(): Json = Json {
        ignoreUnknownKeys = true
        explicitNulls = false
    }

    @Provides
    fun provideOkHttp(tokenStorage: TokenStorage): OkHttpClient {
        val builder = OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .addInterceptor(AuthTokenInterceptor { tokenStorage.get() })

        if (BuildConfig.DEBUG) {
            val logging = HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BASIC
            }
            builder.addInterceptor(logging)
        }

        return builder.build()
    }

    @Provides
    @OptIn(ExperimentalSerializationApi::class)
    fun provideRetrofit(
        okHttp: OkHttpClient,
        json: Json,
        @BaseUrl baseUrl: String
    ): Retrofit =
        Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(okHttp)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()

    @Provides
    @Named("aiBaseUrl")
    fun provideAiBaseUrl(@BaseUrl baseUrl: String): String =
        baseUrl.replace(":8086/", ":8010/")

    @Provides
    @Named("aiRetrofit")
    @OptIn(ExperimentalSerializationApi::class)
    fun provideAiRetrofit(
        okHttp: OkHttpClient,
        json: Json,
        @Named("aiBaseUrl") aiBaseUrl: String
    ): Retrofit =
        Retrofit.Builder()
            .baseUrl(aiBaseUrl)
            .client(okHttp)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
}
