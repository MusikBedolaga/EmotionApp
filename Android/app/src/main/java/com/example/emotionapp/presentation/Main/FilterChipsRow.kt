package com.example.emotionapp.presentation.Main

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

@Composable
fun FilterChipsRow(
    tabs: List<String>,
    selectedIndex: Int,
    onSelect: (Int) -> Unit
) {
    Row(
        Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        tabs.forEachIndexed { idx, label ->
            val selected = idx == selectedIndex
            FilterChip(
                selected = selected,
                onClick = { onSelect(idx) },
                label = { Text(label) },
                shape = RoundedCornerShape(12.dp),
                border = if (!selected) BorderStroke(
                    1.dp,
                    MaterialTheme.colorScheme.outline.copy(alpha = 0.6f)
                ) else null
            )
        }
    }
}

@Preview(showBackground = true, backgroundColor = 0xFFFFFFFF)
@Composable
private fun FilterChipsRowPreview() {
    MaterialTheme {
        Surface {
            val tabs = listOf("Все", "Работа", "Учеба", "Личное")
            val (selected, setSelected) = remember { mutableStateOf(0) }

            FilterChipsRow(
                tabs = tabs,
                selectedIndex = selected,
                onSelect = setSelected
            )
        }
    }
}
