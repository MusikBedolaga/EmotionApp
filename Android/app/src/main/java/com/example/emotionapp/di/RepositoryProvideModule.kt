package com.example.emotionapp.di

import com.example.emotionapp.data.repository.*
import com.example.emotionapp.data.repository.fake.FakeAlbumRepository
import com.example.emotionapp.data.repository.fake.FakeNoteRepository
import com.example.emotionapp.data.repository.fake.FakeTopicRepository
import com.example.emotionapp.domain.repository.*
import dagger.Module
import dagger.Provides

@Module
object RepositoryProvideModule {

    private const val USE_FAKE = false

    @Provides
    fun provideAlbumRepository(
        real: AlbumRepositoryImpl,
        fake: FakeAlbumRepository
    ): AlbumRepository = if (USE_FAKE) fake else real

    @Provides
    fun provideNoteRepository(
        real: NoteRepositoryImpl,
        fake: FakeNoteRepository
    ): NoteRepository = if (USE_FAKE) fake else real

    @Provides
    fun provideTopicRepository(
        real: TopicRepositoryImpl,
        fake: FakeTopicRepository
    ): TopicRepository = if (USE_FAKE) fake else real
}