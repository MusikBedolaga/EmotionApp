package com.example.emotionapp.utils

import android.content.Context
import com.example.emotionapp.data.local.prefs.UserPreferencesDataStore
import com.example.emotionapp.data.repository.UserPreferencesRepositoryImpl
import com.example.emotionapp.domain.repository.UserPreferencesRepository

fun buildUserPrefsRepo(context: Context): UserPreferencesRepository {
    return UserPreferencesRepositoryImpl(
        ds = UserPreferencesDataStore(context)
    )
}
