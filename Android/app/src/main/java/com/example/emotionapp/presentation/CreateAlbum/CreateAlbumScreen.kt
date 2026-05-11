package com.example.emotionapp.presentation.CreateAlbum

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.emotionapp.presentation.AppComponents.PrimaryButton
import com.example.emotionapp.ui.theme.EmotionAppTheme

@Composable
fun CreateAlbumScreenStateful(
    vm: CreateAlbumViewModel,
    title: String = "Создать альбом",
    onSaved: () -> Unit = {}
) {
    val state by vm.uiState.collectAsState()
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(Unit) {
        vm.events.collect { event ->
            when (event) {
                is CreateAlbumUiEvent.ShowMessage -> snackbarHostState.showSnackbar(event.text)
                CreateAlbumUiEvent.AlbumCreated -> onSaved()
            }
        }
    }

    CreateAlbumScreen(
        state = state,
        title = title,
        snackbarHostState = snackbarHostState,
        onTitleChange = vm::onTitleChange,
        onDescriptionChange = vm::onDescriptionChange,
        onSave = vm::save
    )
}

@Composable
fun CreateAlbumScreen(
    state: CreateAlbumUiState,
    title: String,
    snackbarHostState: SnackbarHostState,
    onTitleChange: (String) -> Unit,
    onDescriptionChange: (String) -> Unit,
    onSave: () -> Unit
) {
    androidx.compose.material3.Scaffold(
        modifier = Modifier.fillMaxSize(),
        containerColor = MaterialTheme.colorScheme.background,
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 18.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold
            )

            Spacer(Modifier.height(8.dp))

            Text(
                text = "Новый альбом для заметок и тем.",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            Spacer(Modifier.height(20.dp))

            OutlinedTextField(
                value = state.title,
                onValueChange = onTitleChange,
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                label = { Text("Название") },
                placeholder = { Text("Например, Рабочие идеи") }
            )

            Spacer(Modifier.height(14.dp))

            OutlinedTextField(
                value = state.description,
                onValueChange = onDescriptionChange,
                modifier = Modifier.fillMaxWidth(),
                minLines = 4,
                label = { Text("Описание") },
                placeholder = { Text("Короткое описание альбома") }
            )

            state.errorText?.let {
                Spacer(Modifier.height(12.dp))
                Text(
                    text = it,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.error
                )
            }

            Spacer(Modifier.height(20.dp))

            PrimaryButton(
                text = "Сохранить",
                loading = state.isSaving,
                onClick = onSave
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun CreateAlbumScreenPreview() {
    EmotionAppTheme {
        CreateAlbumScreen(
            state = CreateAlbumUiState(title = "Работа", description = "Все заметки по рабочим задачам"),
            title = "Создать альбом",
            snackbarHostState = remember { SnackbarHostState() },
            onTitleChange = {},
            onDescriptionChange = {},
            onSave = {}
        )
    }
}
