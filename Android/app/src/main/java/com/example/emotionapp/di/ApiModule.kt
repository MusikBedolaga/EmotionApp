package com.example.emotionapp.di

import com.example.emotionapp.data.api.AlbumApi
import com.example.emotionapp.data.api.AiApi
import com.example.emotionapp.data.api.AuthApi
import com.example.emotionapp.data.api.NoteApi
import com.example.emotionapp.data.api.TopicApi
import dagger.Module
import dagger.Provides
import javax.inject.Named
import retrofit2.Retrofit

@Module
object ApiModule {

    @Provides
    fun provideAlbumApi(retrofit: Retrofit): AlbumApi =
        retrofit.create(AlbumApi::class.java)

    @Provides
    fun provideNoteApi(retrofit: Retrofit): NoteApi =
        retrofit.create(NoteApi::class.java)

    @Provides
    fun provideTopicApi(retrofit: Retrofit): TopicApi =
        retrofit.create(TopicApi::class.java)

    @Provides
    fun provideAuthApi(retrofit: Retrofit): AuthApi =
        retrofit.create(AuthApi::class.java)

    @Provides
    fun provideAiApi(@Named("aiRetrofit") retrofit: Retrofit): AiApi =
        retrofit.create(AiApi::class.java)
}