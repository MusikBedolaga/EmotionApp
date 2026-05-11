package com.example.emotionapp.presentation.Main

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreHoriz
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp

@Composable
fun AnalyticsCard(
    onMoreClick: () -> Unit,
    onShowChartClick: () -> Unit
) {
    val shape = RoundedCornerShape(14.dp)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(elevation = 6.dp, shape = shape)
            .clip(shape)
            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.25f))
            .padding(14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.25f))
        )

        Spacer(Modifier.width(12.dp))

        Column(Modifier.weight(1f)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "Аналитика от ИИ",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.weight(1f)
                )
                IconButton(
                    onClick = onMoreClick,
                    modifier = Modifier.size(34.dp)
                ) {
                    Icon(Icons.Default.MoreHoriz, contentDescription = "More")
                }
            }

            Divider(
                modifier = Modifier.padding(top = 6.dp, bottom = 10.dp),
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.15f)
            )

            Text(
                text = "Активность за неделю",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f)
            )

            Spacer(Modifier.height(10.dp))

            Button(
                onClick = onShowChartClick,
                contentPadding = PaddingValues(horizontal = 18.dp, vertical = 10.dp),
                shape = RoundedCornerShape(10.dp)
            ) {
                Text("Посмотреть график")
            }
        }
    }
}

@Preview(showBackground = true, backgroundColor = 0xFFFFFFFF)
@Composable
private fun AnalyticsCardPreview() {
    MaterialTheme {
        Surface {
            AnalyticsCard(
                onMoreClick = {},
                onShowChartClick = {}
            )
        }
    }
}
