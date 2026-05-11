package com.example.emotionapp.presentation.Main

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.emotionapp.domain.entities.Album
import com.example.emotionapp.domain.entities.Topic
import com.example.emotionapp.presentation.AppComponents.SearchField

@Composable
fun MainScreen(
    vm: MainViewModel,
    modifier: Modifier = Modifier,
    onOpenAlbum: (Long, String) -> Unit,
    onAnalyticsClick: () -> Unit,
    onCreateAlbum: () -> Unit
) {
    val state = vm.uiState.collectAsState().value
    val filtered = vm.filteredAlbums.collectAsState().value
    val snackbarHostState = remember { SnackbarHostState() }

    LaunchedEffect(Unit) {
        vm.onAppear()
    }

    LaunchedEffect(Unit) {
        vm.events.collect { event ->
            when (event) {
                is MainUiEvent.NavigateToAlbumDetails -> onOpenAlbum(event.albumId, event.title)
                MainUiEvent.NavigateToAnalyticsAi -> onAnalyticsClick()
                MainUiEvent.NavigateToCreateAlbum -> onCreateAlbum()
                is MainUiEvent.ShowMessage -> snackbarHostState.showSnackbar(event.text)
            }
        }
    }

    MainView(
        modifier = modifier,
        state = state,
        filteredAlbums = filtered,
        snackbarHostState = snackbarHostState,
        onSearchChange = vm::onFilterTextChange,
        onSelectTopic = vm::onSelectTopic,
        onAlbumClick = vm::openNoteScreen,
        onAnalyticsClick = vm::openAnalytics,
        onCreateAlbum = vm::onCreateNewAlbum
    )
}

@Composable
fun MainView(
    modifier: Modifier = Modifier,
    state: MainUiState,
    filteredAlbums: List<Album>,
    snackbarHostState: SnackbarHostState,
    onSearchChange: (String) -> Unit,
    onSelectTopic: (Long?) -> Unit,
    onAlbumClick: (Long, String) -> Unit,
    onAnalyticsClick: () -> Unit,
    onCreateAlbum: () -> Unit
) {
    Scaffold(
        modifier = modifier.fillMaxSize(),
        snackbarHost = { SnackbarHost(snackbarHostState) },
        topBar = {
            Column(
                Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 18.dp)
            ) {
                Text(
                    text = "Заметки",
                    style = MaterialTheme.typography.headlineLarge,
                    fontWeight = FontWeight.ExtraBold
                )
            }
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = onCreateAlbum,
                shape = CircleShape
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add")
            }
        }
    ) { padding ->
        Column(
            Modifier
                .padding(padding)
                .fillMaxSize()
                .padding(horizontal = 8.dp)
        ) {
            Spacer(Modifier.height(8.dp))

            AnalyticsCard(
                onMoreClick = onAnalyticsClick,
                onShowChartClick = onAnalyticsClick
            )

            Spacer(Modifier.height(16.dp))

            SearchField(
                value = state.searchText,
                onValueChange = onSearchChange,
                placeholder = "Поиск по альбомам"
            )

            Spacer(Modifier.height(12.dp))

            val chips = listOf<Long?>(null) + state.topics.map { it.id }
            val labels = listOf("Все") + state.topics.map { it.name }
            val selectedIndex = chips.indexOf(state.selectedTopicId).coerceAtLeast(0)

            FilterChipsRow(
                tabs = labels,
                selectedIndex = selectedIndex,
                onSelect = { onSelectTopic(chips[it]) }
            )

            Spacer(Modifier.height(16.dp))

            if (state.isLoading) {
                LinearProgressIndicator(Modifier.fillMaxWidth())
                Spacer(Modifier.height(12.dp))
            }

            // TODO: Добавить текст если ничего не найдено

            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                verticalArrangement = Arrangement.spacedBy(14.dp),
                horizontalArrangement = Arrangement.spacedBy(14.dp),
                contentPadding = PaddingValues(bottom = 96.dp)
            ) {
                items(filteredAlbums, key = { it.id }) { album ->
                    AlbumCard(
                        title = album.title,
                        notesCount = album.notesCount ?: 0,
                        onClick = { onAlbumClick(album.id, album.title) }
                    )
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun MainScreenContentPreview() {
    val state = MainUiState(
        searchText = "",
        topics = listOf(
            Topic(1, "Работа", "#FF0000"),
            Topic(2, "Учеба", "#00FF00")
        ),
        albums = listOf(
            Album(1, "Работа", "", "", emptyList(), 12),
            Album(2, "Учеба", "", "", emptyList(), 8)
        )
    )

    MaterialTheme {
        MainView(
            state = state,
            filteredAlbums = state.albums,
            snackbarHostState = remember { SnackbarHostState() },
            onSearchChange = {},
            onSelectTopic = {},
            onAlbumClick = { _, _ -> },
            onAnalyticsClick = {},
            onCreateAlbum = {}
        )
    }
}
