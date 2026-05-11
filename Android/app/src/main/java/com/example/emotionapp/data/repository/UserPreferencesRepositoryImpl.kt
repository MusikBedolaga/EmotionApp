package com.example.emotionapp.data.repository

import com.example.emotionapp.data.local.prefs.UserPreferencesDataStore
import com.example.emotionapp.domain.repository.UserPreferencesRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class UserPreferencesRepositoryImpl @Inject constructor(
    private val ds: UserPreferencesDataStore
): UserPreferencesRepository {

    override val onboardingDone: Flow<Boolean> = ds.onboardingDone
    override val username: Flow<String> = ds.username
    override val email: Flow<String> = ds.email
    override val notificationsEnabled: Flow<Boolean> = ds.notificationsEnabled
    override val selectedTheme: Flow<String> = ds.selectedTheme

    override suspend fun setOnboardingDone(done: Boolean) = ds.setOnboardingDone(done)
    override suspend fun setUsername(username: String) = ds.setUsername(username.trim())
    override suspend fun setEmail(email: String) = ds.setEmail(email.trim())
    override suspend fun setNotificationsEnabled(enabled: Boolean) = ds.setNotificationsEnabled(enabled)
    override suspend fun setSelectedTheme(theme: String) = ds.setSelectedTheme(theme)
    override suspend fun clearSession() = ds.clearSession()
}