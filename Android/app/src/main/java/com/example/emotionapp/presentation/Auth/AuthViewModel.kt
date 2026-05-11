package com.example.emotionapp.presentation.Auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.emotionapp.BuildConfig
import com.example.emotionapp.domain.entities.SignInRequest
import com.example.emotionapp.domain.entities.SignUpRequest
import com.example.emotionapp.domain.repository.AuthRepository
import com.example.emotionapp.domain.repository.UserPreferencesRepository
import com.example.emotionapp.utils.NetworkResult
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AuthUiState(
    val mode: AuthMode = AuthMode.LOGIN,
    val name: String = "",
    val email: String = "",
    val password: String = "",
    val repeatPassword: String = "",
    val isLoading: Boolean = false,
    val errorText: String? = null
)

sealed interface AuthUiEvent {
    data object NavigateHome: AuthUiEvent
    data class ShowMessage(val text: String): AuthUiEvent
}

class AuthViewModel @Inject constructor(
    private val authRepository: AuthRepository,
    private val userPreferencesRepository: UserPreferencesRepository
): ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    private val _events = Channel<AuthUiEvent>(Channel.BUFFERED)
    val events: Flow<AuthUiEvent> = _events.receiveAsFlow()

    fun toggleMode() {
        _uiState.update {
            it.copy(
                mode = if (it.mode == AuthMode.LOGIN) AuthMode.REGISTER else AuthMode.LOGIN,
                errorText = null
            )
        }
    }

    fun onNameChange(v: String) = _uiState.update { it.copy(name = v, errorText = null) }
    fun onEmailChange(v: String) = _uiState.update { it.copy(email = v, errorText = null) }
    fun onPasswordChange(v: String) = _uiState.update { it.copy(password = v, errorText = null) }
    fun onRepeatPasswordChange(v: String) = _uiState.update { it.copy(repeatPassword = v, errorText = null) }
    fun clearError() = _uiState.update { it.copy(errorText = null) }

    fun submit() {
        val s = _uiState.value

        if (s.mode == AuthMode.LOGIN) {
            if (s.email.isBlank() || s.password.isBlank()) {
                _uiState.update { it.copy(errorText = "Заполните имя пользователя и пароль") }
                return
            }
        } else {
            if (s.name.isBlank() || s.email.isBlank() || s.password.isBlank()) {
                _uiState.update { it.copy(errorText = "Заполните имя, email и пароль") }
                return
            }
            if (s.repeatPassword != s.password) {
                _uiState.update { it.copy(errorText = "Пароли не совпадают") }
                return
            }
        }

        if (s.password.length < 8) {
            _uiState.update { it.copy(errorText = "Пароль не короче 8 символов (требование сервера)") }
            return
        }
        if (s.mode == AuthMode.REGISTER) {
            if (s.name.trim().length < 5) {
                _uiState.update { it.copy(errorText = "Имя пользователя не короче 5 символов") }
                return
            }
        } else {
            if (s.email.trim().length < 5) {
                _uiState.update { it.copy(errorText = "Имя пользователя не короче 5 символов") }
                return
            }
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorText = null) }
            val loginOrEmail = s.email.trim()
            val authResult = if (s.mode == AuthMode.REGISTER) {
                authRepository.signUp(
                    SignUpRequest(
                        username = s.name.trim(),
                        email = loginOrEmail,
                        password = s.password
                    )
                )
            } else {
                authRepository.signIn(
                    SignInRequest(
                        username = loginOrEmail,
                        password = s.password
                    )
                )
            }

            when (authResult) {
                is NetworkResult.Ok -> {
                    val displayName = if (s.mode == AuthMode.REGISTER) {
                        s.name.trim()
                    } else {
                        loginOrEmail
                    }
                    userPreferencesRepository.setUsername(displayName)
                    if (s.mode == AuthMode.REGISTER) {
                        userPreferencesRepository.setEmail(loginOrEmail)
                    }
                    _events.send(AuthUiEvent.NavigateHome)
                }
                is NetworkResult.Error.Http -> {
                    val msg = "Ошибка сервера (${authResult.code}). ${authResult.body?.take(120) ?: ""}".trim()
                    _uiState.update { it.copy(errorText = msg) }
                    _events.send(AuthUiEvent.ShowMessage(msg))
                }
                is NetworkResult.Error.Network -> {
                    val detail = authResult.message?.trim().orEmpty()
                    val msg = buildString {
                        append("Не удалось достучаться до ")
                        append(BuildConfig.API_BASE_URL)
                        append(". ")
                        if (detail.isNotEmpty()) {
                            append("Причина: ")
                            append(detail)
                            append(". ")
                        }
                        append("Проверьте: api-gateway на порту 8086; с эмулятора хост — 10.0.2.2; с телефона — в файле Android/local.properties задайте API_BASE_URL=http://ВАШ_IP:8086/ или USB: adb reverse tcp:8086 tcp:8086 и API_BASE_URL=http://127.0.0.1:8086/")
                    }
                    _uiState.update { it.copy(errorText = msg) }
                    val short = if (detail.isNotEmpty()) {
                        "Сеть: $detail"
                    } else {
                        "Нет ответа от ${BuildConfig.API_BASE_URL}"
                    }
                    _events.send(AuthUiEvent.ShowMessage(short))
                }
                is NetworkResult.Error.Unknown -> {
                    val msg = authResult.message ?: "Неизвестная ошибка"
                    _uiState.update { it.copy(errorText = msg) }
                    _events.send(AuthUiEvent.ShowMessage(msg))
                }
            }

            _uiState.update { it.copy(isLoading = false) }
        }
    }
}
