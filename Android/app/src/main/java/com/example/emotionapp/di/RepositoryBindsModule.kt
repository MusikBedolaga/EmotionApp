package com.example.emotionapp.di

import com.example.emotionapp.data.repository.AuthRepositoryImpl
import com.example.emotionapp.data.repository.AiRepositoryImpl
import com.example.emotionapp.data.repository.UserPreferencesRepositoryImpl
import com.example.emotionapp.domain.repository.AiRepository
import com.example.emotionapp.domain.repository.AuthRepository
import com.example.emotionapp.domain.repository.UserPreferencesRepository
import dagger.Binds
import dagger.Module

@Module
interface RepositoryBindsModule {

    @Binds fun bindAiRepository(impl: AiRepositoryImpl): AiRepository
    @Binds fun bindAuthRepository(impl: AuthRepositoryImpl): AuthRepository
    @Binds fun bindUserPreferencesRepository(impl: UserPreferencesRepositoryImpl): UserPreferencesRepository
}
