package com.example.emotionapp.data.local.prefs

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

private val Context.dataStore by preferencesDataStore("user_prefs")

class UserPreferencesDataStore @Inject constructor(
    private val context: Context
) {

    private object Keys {
        val ONBOARDING_DONE = booleanPreferencesKey("onboarding_done")
        val USERNAME = stringPreferencesKey("username")
        val EMAIL = stringPreferencesKey("email")
        val NOTIFICATIONS_ENABLED = booleanPreferencesKey("notifications_enabled")
        val SELECTED_THEME = stringPreferencesKey("selected_theme")
    }

    val onboardingDone: Flow<Boolean> =
        context.dataStore.data.map { it[Keys.ONBOARDING_DONE] ?: false }

    val username: Flow<String> =
        context.dataStore.data.map { it[Keys.USERNAME] ?: "" }

    val email: Flow<String> =
        context.dataStore.data.map { it[Keys.EMAIL] ?: "" }

    val notificationsEnabled: Flow<Boolean> =
        context.dataStore.data.map { it[Keys.NOTIFICATIONS_ENABLED] ?: true }

    val selectedTheme: Flow<String> =
        context.dataStore.data.map { it[Keys.SELECTED_THEME] ?: "light" }

    suspend fun setOnboardingDone(done: Boolean) {
        context.dataStore.edit { it[Keys.ONBOARDING_DONE] = done }
    }

    suspend fun setUsername(value: String) {
        context.dataStore.edit { it[Keys.USERNAME] = value }
    }

    suspend fun setEmail(value: String) {
        context.dataStore.edit { it[Keys.EMAIL] = value }
    }

    suspend fun setNotificationsEnabled(value: Boolean) {
        context.dataStore.edit { it[Keys.NOTIFICATIONS_ENABLED] = value }
    }

    suspend fun setSelectedTheme(value: String) {
        context.dataStore.edit { it[Keys.SELECTED_THEME] = value }
    }

    suspend fun clearSession() {
        context.dataStore.edit {
            it[Keys.USERNAME] = ""
            it[Keys.EMAIL] = ""
        }
    }
}