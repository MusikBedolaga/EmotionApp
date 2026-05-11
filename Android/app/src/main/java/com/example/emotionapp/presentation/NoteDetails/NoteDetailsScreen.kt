package com.example.emotionapp.presentation.NoteDetails

import androidx.compose.material3.SnackbarHostState
import androidx.compose.runtime.*
import kotlinx.coroutines.flow.collectLatest

@Composable
fun NoteDetailsScreen(
    vm: NoteDetailsViewModel,
    noteId: Long,
    modifier: androidx.compose.ui.Modifier = androidx.compose.ui.Modifier,
    onBack: () -> Unit
) {
    val state by vm.uiState.collectAsState()
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(noteId) {
        vm.onAppear(noteId)
    }

    LaunchedEffect(Unit) {
        vm.events.collectLatest { event ->
            when (event) {
                NoteDetailsUiEvents.NavigateGoBack -> onBack()
                NoteDetailsUiEvents.Saved -> snackbarHostState.showSnackbar("Сохранено")
                NoteDetailsUiEvents.Deleted -> snackbarHostState.showSnackbar("Удалено")
            }
        }
    }

    NoteDetailsView(
        modifier = modifier,
        state = state,
        snackbarHostState = snackbarHostState,
        onBack = vm::navigateGoBack,
        onChangeTitle = vm::onChangeTitle,
        onChangeContent = vm::onChangeContent,
        onSave = vm::onSaveClicked,
        onDelete = vm::onDeleteClicked
    )
}
