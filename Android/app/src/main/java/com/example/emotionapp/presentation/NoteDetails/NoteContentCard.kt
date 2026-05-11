package com.example.emotionapp.presentation.NoteDetails

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

@Composable
fun NoteContentCard(
    content: String,
    isEditing: Boolean,
    onContentChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp),
        modifier = modifier.fillMaxWidth()
    ) {
        if (isEditing) {
            TextField(
                value = content,
                onValueChange = onContentChange,
                placeholder = { Text("Текст заметки") },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(6.dp),
                minLines = 6,
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = MaterialTheme.colorScheme.surface,
                    unfocusedContainerColor = MaterialTheme.colorScheme.surface,
                    disabledContainerColor = MaterialTheme.colorScheme.surface
                )
            )
        } else {
            Text(
                text = content,
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(14.dp)
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun NoteContentCardPreview() {
    MaterialTheme {
        NoteContentCard(
            content = "Необходимо завершить отчет по текущему проекту...",
            isEditing = false,
            onContentChange = {}
        )
    }
}
