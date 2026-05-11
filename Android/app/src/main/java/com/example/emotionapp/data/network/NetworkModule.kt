package com.example.emotionapp.data.network

import com.example.emotionapp.data.api.AlbumApi
import com.example.emotionapp.data.api.NoteApi
import com.example.emotionapp.data.api.TopicApi
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import javax.inject.Inject

class NetworkModule @Inject constructor(
    private val tokenStorage: TokenStorage,
    baseUrl: String
) {
    val retrofit: Retrofit
    val albumApi: AlbumApi
    val noteApi: NoteApi
    val topicApi: TopicApi

    init {
        val okHttp = OkHttpClient.Builder()
            .addInterceptor(AuthTokenInterceptor { tokenStorage.get() })
            .build()

        val json = Json {
            ignoreUnknownKeys = true
            explicitNulls = false
        }

        retrofit = Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(okHttp)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()

        albumApi = retrofit.create(AlbumApi::class.java)
        noteApi = retrofit.create(NoteApi::class.java)
        topicApi = retrofit.create(TopicApi::class.java)
    }
}