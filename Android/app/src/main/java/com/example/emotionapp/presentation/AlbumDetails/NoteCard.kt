package com.example.emotionapp.presentation.AlbumDetails

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.emotionapp.ui.theme.EmotionAppTheme

@Composable
fun NoteCard(
    title: String,
    subtitle: String?,
    onClick: () -> Unit
) {
    Surface(
        shape = MaterialTheme.shapes.large,
        tonalElevation = 1.dp,
        shadowElevation = 0.dp,
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = title.ifBlank { "Без названия" },
                style = MaterialTheme.typography.titleLarge,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            if (!subtitle.isNullOrBlank()) {
                Spacer(Modifier.height(6.dp))
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Preview(name = "NoteCard - normal", showBackground = true)
@Composable
private fun Preview_NoteCard_Normal() {
    EmotionAppTheme {
        NoteCard(
            title = "Созвон с клиентом",
            subtitle = "21 апреля, 13:10",
            onClick = {}
        )
    }
}

@Preview(name = "NoteCard - without subtitle", showBackground = true)
@Composable
private fun Preview_NoteCard_NoSubtitle() {
    EmotionAppTheme {
        NoteCard(
            title = "Без даты",
            subtitle = null,
            onClick = {}
        )
    }
}

@Preview(name = "NoteCard - long title", showBackground = true)
@Composable
private fun Preview_NoteCard_LongTitle() {
    EmotionAppTheme {
        NoteCard(
            title = "Очень длинное название заметки чтобы проверить как работает Ellipsis в карточке и не ломает ли верстку",
            subtitle = "21 апреля, 13:10",
            onClick = {}
        )
    }
}
