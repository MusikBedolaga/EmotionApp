package com.example.emotionapp.presentation.NoteDetails

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.emotionapp.domain.entities.Note

@Composable
fun NoteDetailsView(
    modifier: Modifier = Modifier,
    state: NoteDetailsUiState,
    snackbarHostState: SnackbarHostState,
    onBack: () -> Unit,
    onChangeTitle: (String) -> Unit,
    onChangeContent: (String) -> Unit,
    onSave: () -> Unit,
    onDelete: () -> Unit
) {
    var isEditing by remember { mutableStateOf(false) }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            NoteDetailsTopBar(
                onBack = onBack,
                onDelete = onDelete
            )
        },
        bottomBar = {
            BottomPrimaryButton(
                text = if (isEditing) "Сохранить" else "Текст",
                enabled = !state.isSaving && !state.isDeleting,
                onClick = { if (isEditing) onSave() else isEditing = true }
            )
        }
    ) { padding ->
        Column(
            Modifier
                .padding(padding)
                .fillMaxSize()
                .padding(horizontal = 16.dp)
        ) {
            Spacer(Modifier.height(14.dp))

            NoteTitleCard(
                title = state.title.ifBlank { state.note?.title.orEmpty() },
                isEditing = isEditing,
                onToggleEdit = { isEditing = !isEditing },
                onTitleChange = onChangeTitle
            )

            Spacer(Modifier.height(10.dp))

            NoteContentCard(
                content = state.content.ifBlank { state.note?.content.orEmpty() },
                isEditing = isEditing,
                onContentChange = onChangeContent
            )

            Spacer(Modifier.height(12.dp))

            Card(
                shape = MaterialTheme.shapes.large,
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                elevation = CardDefaults.cardElevation(defaultElevation = 0.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(Modifier.fillMaxWidth()) {
                    InfoRow(label = "Создано", value = state.note?.createdAt ?: "—")
                    Divider(Modifier.padding(horizontal = 14.dp))
                    InfoRow(label = "Альбом", value = "Работа") // TODO
                    Divider(Modifier.padding(horizontal = 14.dp))
                    InfoRow(label = "Топик", value = "Все") // TODO
                }
            }

            if (state.isLoading || state.isSaving || state.isDeleting) {
                Spacer(Modifier.height(12.dp))
                LinearProgressIndicator(Modifier.fillMaxWidth())
            }

            state.errorMessage?.let {
                Spacer(Modifier.height(10.dp))
                Text(it, color = MaterialTheme.colorScheme.error)
            }

            Spacer(Modifier.height(90.dp))
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun NoteDetailsViewPreview() {
    val note = Note(
        id = 1,
        albumId = 1,
        title = "Созвон с клиентом",
        content = "Необходимо завершить отчет по текущему проекту. Проверить все данные...",
        createdAt = "Вчера, 14:22"
    )

    MaterialTheme {
        NoteDetailsView(
            state = NoteDetailsUiState(
                note = note,
                title = note.title,
                content = note.content
            ),
            snackbarHostState = remember { SnackbarHostState() },
            onBack = {},
            onChangeTitle = {},
            onChangeContent = {},
            onSave = {},
            onDelete = {}
        )
    }
}
