package com.example.emotionapp.presentation.AlbumDetails

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ArrowBack
import androidx.compose.material.icons.outlined.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.emotionapp.domain.entities.NoteSummary
import com.example.emotionapp.presentation.AppComponents.SearchField
import com.example.emotionapp.ui.theme.EmotionAppTheme
import kotlinx.coroutines.flow.collectLatest

@Composable
fun AlbumDetailsScreen(
    vm: AlbumDetailsViewModel,
    albumId: Long,
    title: String,
    modifier: Modifier = Modifier,
    onOpenNote: (Long) -> Unit,
    onCreateNote: () -> Unit,
    onBack: () -> Unit
) {
    val state by vm.uiState.collectAsState()
    val filtered by vm.filteredNotes.collectAsState()
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(albumId) {
        vm.onAppear(albumId = albumId)
    }

    LaunchedEffect(Unit) {
        vm.events.collectLatest { event ->
            when (event) {
                is AlbumDetailsUiEvent.NavigateToNote -> onOpenNote(event.noteId)
                AlbumDetailsUiEvent.NavigateToCreateNote -> onCreateNote()
                AlbumDetailsUiEvent.NavigateGoBack -> onBack()
                is AlbumDetailsUiEvent.ShowMessage ->
                    snackbarHostState.showSnackbar(event.text)
            }
        }
    }

    AlbumDetailsView(
        state = state,
        notes = filtered,
        screenTitle = title,
        snackbarHostState = snackbarHostState,
        modifier = modifier,
        onBackClick = { vm.navigateGoBack() },
        onSearchChange = vm::onChangeTextField,
        onNoteClick = vm::openNote,
        onCreateClick = vm::onCreateNewNote
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AlbumDetailsView(
    state: AlbumDetailsUiState,
    notes: List<NoteSummary>,
    screenTitle: String,
    snackbarHostState: SnackbarHostState,
    modifier: Modifier = Modifier,
    onBackClick: () -> Unit,
    onSearchChange: (String) -> Unit,
    onNoteClick: (Long) -> Unit,
    onCreateClick: () -> Unit
) {
    Scaffold(
        modifier = modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = { Text(screenTitle) },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Outlined.ArrowBack, contentDescription = "Назад")
                    }
                }
            )
        },
        snackbarHost = { SnackbarHost(hostState = snackbarHostState) },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onCreateClick,
                shape = CircleShape
            ) {
                Icon(Icons.Outlined.Add, contentDescription = "Добавить")
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            SearchField(
                value = state.searchText,
                onValueChange = onSearchChange,
                placeholder = "Поиск по заметкам"
            )

            Box(modifier = Modifier.fillMaxSize()) {
                when {
                    state.isLoading -> {
                        CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                    }

                    notes.isEmpty() -> {
                        Text(
                            text = if (state.searchText.isBlank()) "Пока нет заметок" else "Ничего не найдено",
                            style = MaterialTheme.typography.bodyLarge,
                            modifier = Modifier
                                .align(Alignment.Center)
                                .padding(16.dp)
                        )
                    }

                    else -> {
                        LazyColumn(
                            modifier = Modifier.fillMaxSize(),
                            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                            verticalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            items(
                                items = notes,
                                key = { it.id }
                            ) { note ->
                                NoteCard(
                                    title = note.title,
                                    subtitle = note.createdAt,
                                    onClick = { onNoteClick(note.id) }
                                )
                            }

                            item {
                                Spacer(Modifier.height(88.dp))
                            }
                        }
                    }
                }
            }
        }
    }
}

private fun fakeNotes(): List<NoteSummary> = listOf(
    NoteSummary(id = 1, title = "Созвон с клиентом", createdAt = "21 апреля, 13:10"),
    NoteSummary(id = 2, title = "Созвон с клиентом", createdAt = "21 апреля, 13:10"),
    NoteSummary(id = 3, title = "Созвон с клиентом", createdAt = "21 апреля, 13:10"),
    NoteSummary(id = 4, title = "Очень длинное название заметки чтобы проверить как работает Ellipsis в карточке",
        createdAt = "21 апреля, 13:10"
    )
)

@Preview(name = "AlbumDetailsView - content", showBackground = true)
@Composable
private fun Preview_AlbumDetailsView_Content() {
    EmotionAppTheme {
        AlbumDetailsView(
            state = AlbumDetailsUiState(
                searchText = "",
                isLoading = false,
                errorText = null,
                notes = fakeNotes()
            ),
            notes = fakeNotes(),
            screenTitle = "Работа",
            snackbarHostState = remember { SnackbarHostState() },
            onBackClick = {},
            onSearchChange = {},
            onNoteClick = {},
            onCreateClick = {}
        )
    }
}

@Preview(name = "AlbumDetailsView - loading", showBackground = true)
@Composable
private fun Preview_AlbumDetailsView_Loading() {
    EmotionAppTheme {
        AlbumDetailsView(
            state = AlbumDetailsUiState(
                searchText = "",
                isLoading = true,
                errorText = null,
                notes = emptyList()
            ),
            notes = emptyList(),
            screenTitle = "Работа",
            snackbarHostState = remember { SnackbarHostState() },
            onBackClick = {},
            onSearchChange = {},
            onNoteClick = {},
            onCreateClick = {}
        )
    }
}

@Preview(name = "AlbumDetailsView - empty", showBackground = true)
@Composable
private fun Preview_AlbumDetailsView_Empty() {
    EmotionAppTheme {
        AlbumDetailsView(
            state = AlbumDetailsUiState(
                searchText = "",
                isLoading = false,
                errorText = null,
                notes = emptyList()
            ),
            notes = emptyList(),
            screenTitle = "Работа",
            snackbarHostState = remember { SnackbarHostState() },
            onBackClick = {},
            onSearchChange = {},
            onNoteClick = {},
            onCreateClick = {}
        )
    }
}

@Preview(name = "AlbumDetailsView - search no results", showBackground = true)
@Composable
private fun Preview_AlbumDetailsView_SearchNoResults() {
    EmotionAppTheme {
        AlbumDetailsView(
            state = AlbumDetailsUiState(
                searchText = "qwerty",
                isLoading = false,
                errorText = null,
                notes = fakeNotes()
            ),
            notes = emptyList(),
            screenTitle = "Работа",
            snackbarHostState = remember { SnackbarHostState() },
            onBackClick = {},
            onSearchChange = {},
            onNoteClick = {},
            onCreateClick = {}
        )
    }
}
