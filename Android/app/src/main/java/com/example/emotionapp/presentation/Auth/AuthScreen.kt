package com.example.emotionapp.presentation.Auth

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.material3.TextFieldDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.emotionapp.presentation.AppComponents.PrimaryButton
import com.example.emotionapp.ui.theme.EmotionAppTheme

enum class AuthMode { LOGIN, REGISTER }

@Composable
fun AuthScreenStateful(
    vm: AuthViewModel,
    onFinish: () -> Unit
) {

    val state = vm.uiState.collectAsState().value
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(state.errorText) {
        val msg = state.errorText
        if (!msg.isNullOrBlank()) {
            snackbarHostState.showSnackbar(message = msg)
            vm.clearError()
        }
    }

    LaunchedEffect(Unit) {
        vm.events.collect { event ->
            when (event) {
                AuthUiEvent.NavigateHome -> onFinish()
                is AuthUiEvent.ShowMessage -> snackbarHostState.showSnackbar(event.text)
            }
        }
    }

    AuthScreen(
        mode = state.mode,
        name = state.name,
        email = state.email,
        password = state.password,
        repeatPassword = state.repeatPassword,
        onNameChange = vm::onNameChange,
        onEmailChange = vm::onEmailChange,
        onPasswordChange = vm::onPasswordChange,
        onRepeatPasswordChange = vm::onRepeatPasswordChange,
        onSubmit = vm::submit,
        onToggleMode = vm::toggleMode,
        isLoading = state.isLoading,
        snackbarHostState = snackbarHostState
    )
}

@Composable
fun AuthScreen(
    mode: AuthMode,

    name: String,
    email: String,
    password: String,
    repeatPassword: String,

    onNameChange: (String) -> Unit,
    onEmailChange: (String) -> Unit,
    onPasswordChange: (String) -> Unit,
    onRepeatPasswordChange: (String) -> Unit,

    onSubmit: () -> Unit,
    onToggleMode: () -> Unit,

    modifier: Modifier = Modifier,
    isLoading: Boolean = false,
    snackbarHostState: SnackbarHostState
) {
    val colors = MaterialTheme.colorScheme

    Scaffold(
        modifier = modifier.fillMaxSize(),
        containerColor = colors.background,
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) }
    ) { padding ->
        Surface(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding),
            color = colors.background
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .imePadding()
                    .padding(horizontal = 24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Spacer(Modifier.height(56.dp))

                IconPlaceholder()

                Spacer(Modifier.weight(1f))

                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(14.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    if (mode == AuthMode.REGISTER) {
                        AuthField(
                            value = name,
                            onValueChange = onNameChange,
                            placeholder = "Введите имя",
                            keyboardType = KeyboardType.Text,
                            isPassword = false
                        )
                    }

                    AuthField(
                        value = email,
                        onValueChange = onEmailChange,
                        placeholder = if (mode == AuthMode.LOGIN) {
                            "Имя пользователя"
                        } else {
                            "Введите email"
                        },
                        keyboardType = if (mode == AuthMode.LOGIN) {
                            KeyboardType.Text
                        } else {
                            KeyboardType.Email
                        },
                        isPassword = false
                    )

                    AuthField(
                        value = password,
                        onValueChange = onPasswordChange,
                        placeholder = "Введите пароль",
                        keyboardType = KeyboardType.Password,
                        isPassword = true
                    )

                    if (mode == AuthMode.REGISTER) {
                        AuthField(
                            value = repeatPassword,
                            onValueChange = onRepeatPasswordChange,
                            placeholder = "Повторите пароль",
                            keyboardType = KeyboardType.Password,
                            isPassword = true
                        )
                    }
                }

                Spacer(Modifier.height(56.dp))

                PrimaryButton(
                    text = if (mode == AuthMode.LOGIN) "Войти" else "Создать аккаунт",
                    onClick = onSubmit,
                    loading = isLoading
                )

                Spacer(Modifier.height(10.dp))

                Text(
                    text = if (mode == AuthMode.LOGIN) "Нет аккаунта? Регистрация" else "Уже есть аккаунт? Войти",
                    modifier = Modifier
                        .clickable(onClick = onToggleMode)
                        .padding(vertical = 6.dp),
                    color = colors.onSurfaceVariant,
                    style = MaterialTheme.typography.bodySmall,
                    textAlign = TextAlign.Center
                )

                Spacer(Modifier.height(24.dp))
            }
        }
    }
}

@Composable
private fun IconPlaceholder() {
    val colors = MaterialTheme.colorScheme

    Box(
        modifier = Modifier
            .size(170.dp)
            .background(colors.primary, RoundedCornerShape(28.dp)),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = "Иконка",
            color = colors.onPrimary,
            style = MaterialTheme.typography.titleLarge,
            textAlign = TextAlign.Center
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AuthField(
    value: String,
    onValueChange: (String) -> Unit,
    placeholder: String,
    keyboardType: KeyboardType,
    isPassword: Boolean
) {
    val colors = MaterialTheme.colorScheme

    TextField(
        value = value,
        onValueChange = onValueChange,
        modifier = Modifier
            .fillMaxWidth()
            .height(48.dp),
        singleLine = true,
        shape = RoundedCornerShape(999.dp),
        placeholder = {
            Text(
                text = placeholder,
                color = colors.onPrimary.copy(alpha = 0.9f),
                style = MaterialTheme.typography.bodyLarge
            )
        },
        textStyle = MaterialTheme.typography.bodyLarge.copy(
            color = colors.onPrimary
        ),
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
        visualTransformation = if (isPassword) PasswordVisualTransformation() else VisualTransformation.None,
        colors = TextFieldDefaults.colors(
            focusedContainerColor = colors.primary,
            unfocusedContainerColor = colors.primary,
            disabledContainerColor = colors.primary.copy(alpha = 0.7f),

            focusedIndicatorColor = Color.Transparent,
            unfocusedIndicatorColor = Color.Transparent,
            disabledIndicatorColor = Color.Transparent,

            focusedTextColor = colors.onPrimary,
            unfocusedTextColor = colors.onPrimary,
            cursorColor = colors.onPrimary
        )
    )
}

@Preview(showBackground = true)
@Composable
fun AuthScreenPreview() {
    EmotionAppTheme {
        val snackbarHostState = remember { SnackbarHostState() }

        AuthScreen(
            mode = AuthMode.LOGIN,
            name = "",
            email = "",
            password = "",
            repeatPassword = "",
            onNameChange = {},
            onEmailChange = {},
            onPasswordChange = {},
            onRepeatPasswordChange = {},
            onSubmit = {},
            onToggleMode = {},
            isLoading = false,
            snackbarHostState = snackbarHostState
        )
    }
}
