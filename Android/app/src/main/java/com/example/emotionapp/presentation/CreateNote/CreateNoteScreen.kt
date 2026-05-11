@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.example.emotionapp.presentation.CreateNote

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
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
fun CreateNoteScreenStateful(
    vm: CreateNoteViewModel,
    albumId: Long,
    onBack: () -> Unit
) {
    val state by vm.uiState.collectAsState()
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(Unit) {
        vm.events.collect { event ->
            when (event) {
                is CreateNoteUiEvent.ShowMessage -> snackbarHostState.showSnackbar(event.text)
                CreateNoteUiEvent.NoteCreated -> onBack()
            }
        }
    }

    CreateNoteScreen(
        state = state,
        snackbarHostState = snackbarHostState,
        onBack = onBack,
        onTitleChange = vm::onTitleChange,
        onContentChange = vm::onContentChange,
        onSave = { vm.save(albumId) }
    )
}

@Composable
fun CreateNoteScreen(
    state: CreateNoteUiState,
    snackbarHostState: SnackbarHostState,
    onBack: () -> Unit,
    onTitleChange: (String) -> Unit,
    onContentChange: (String) -> Unit,
    onSave: () -> Unit
) {
    Scaffold(
        modifier = Modifier.fillMaxSize(),
        containerColor = MaterialTheme.colorScheme.background,
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Новая заметка",
                        fontWeight = FontWeight.SemiBold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Outlined.ArrowBack, contentDescription = "Назад")
                    }
                }
            )
        },
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 18.dp)
        ) {
            OutlinedTextField(
                value = state.title,
                onValueChange = onTitleChange,
                modifier = Modifier.fillMaxWidth(),
                singleLine = true,
                label = { Text("Название") },
                placeholder = { Text("Например, План на неделю") }
            )

            Spacer(Modifier.height(14.dp))

            OutlinedTextField(
                value = state.content,
                onValueChange = onContentChange,
                modifier = Modifier.fillMaxWidth(),
                minLines = 6,
                label = { Text("Содержимое") },
                placeholder = { Text("Введите текст заметки") }
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
private fun CreateNoteScreenPreview() {
    EmotionAppTheme {
        CreateNoteScreen(
            state = CreateNoteUiState(
                title = "Новая заметка",
                content = "Короткий текст заметки"
            ),
            snackbarHostState = remember { SnackbarHostState() },
            onBack = {},
            onTitleChange = {},
            onContentChange = {},
            onSave = {}
        )
    }
}
