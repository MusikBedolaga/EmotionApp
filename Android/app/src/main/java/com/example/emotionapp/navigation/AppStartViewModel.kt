package com.example.emotionapp.navigation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.emotionapp.domain.repository.UserPreferencesRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

sealed interface AppStartState {
    data object Loading: AppStartState
    data class Ready(val startDestination: String): AppStartState
}

class AppStartViewModel @Inject constructor(
    repo: UserPreferencesRepository
) : ViewModel() {

    val state: StateFlow<AppStartState> =
        repo.onboardingDone
            .combine(repo.username) { done, username ->
                val start = when {
                    !done -> Route.Onboarding.route
                    username.isBlank() -> Route.Auth.route
                    else -> Route.Main.route
                }
                AppStartState.Ready(startDestination = start)
            }
            .stateIn(
                scope = viewModelScope,
                started = SharingStarted.WhileSubscribed(3_000),
                initialValue = AppStartState.Loading
            )
}

