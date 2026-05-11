package com.example.emotionapp.domain.repository

import kotlinx.coroutines.flow.Flow

interface UserPreferencesRepository {
    val onboardingDone: Flow<Boolean>
    val username: Flow<String>
    val email: Flow<String>
    val notificationsEnabled: Flow<Boolean>
    val selectedTheme: Flow<String>

    suspend fun setOnboardingDone(done: Boolean)
    suspend fun setUsername(username: String)
    suspend fun setEmail(email: String)
    suspend fun setNotificationsEnabled(enabled: Boolean)
    suspend fun setSelectedTheme(theme: String)
    suspend fun clearSession()
}