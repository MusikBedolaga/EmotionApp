@file:OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)

package com.example.emotionapp.presentation.Analytics

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.ArrowBack
import androidx.compose.material.icons.outlined.Refresh
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.example.emotionapp.ui.theme.EmotionAppTheme

@Composable
fun AnalyticsScreenStateful(
    vm: AnalyticsViewModel,
    onBack: () -> Unit
) {
    val state by vm.uiState.collectAsState()

    LaunchedEffect(Unit) {
        vm.load()
    }

    AnalyticsScreen(
        state = state,
        onBack = onBack,
        onRefresh = vm::retry,
        onSelectPeriod = vm::onSelectPeriod
    )
}

@Composable
fun AnalyticsScreen(
    state: AnalyticsUiState,
    onBack: () -> Unit,
    onRefresh: () -> Unit,
    onSelectPeriod: (AnalyticsPeriod) -> Unit
) {
    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Аналитика",
                        fontWeight = FontWeight.SemiBold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Outlined.ArrowBack, contentDescription = "Назад")
                    }
                },
                actions = {
                    IconButton(onClick = onRefresh) {
                        Icon(Icons.Outlined.Refresh, contentDescription = "Обновить")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 16.dp, vertical = 12.dp)
        ) {
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                AnalyticsPeriod.entries.forEach { period ->
                    FilterChip(
                        selected = state.selectedPeriod == period,
                        onClick = { onSelectPeriod(period) },
                        label = { Text(period.title) }
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            state.errorText?.let { errorText ->
                AnalyticsCard {
                    Column(Modifier.fillMaxWidth().padding(16.dp)) {
                        Text(
                            text = "Не удалось обновить аналитику",
                            style = MaterialTheme.typography.titleSmall,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(Modifier.height(6.dp))
                        Text(
                            text = errorText,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
                Spacer(Modifier.height(16.dp))
            }

            AnalyticsCard {
                Column(Modifier.fillMaxWidth().padding(16.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.Top
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(
                                text = "Активность",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.SemiBold
                            )
                            Spacer(Modifier.height(4.dp))
                            Text(
                                text = state.totalNotesLabel,
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }

                        BadgeLabel(text = state.activityBadgeText)
                    }

                    Spacer(Modifier.height(18.dp))

                    if (state.activityPoints.any { it.count > 0 }) {
                        ActivityBarChart(points = state.activityPoints)
                    } else {
                        EmptyCardText("Пока нет заметок за выбранный период")
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            AnalyticsCard {
                Column(Modifier.fillMaxWidth().padding(16.dp)) {
                    Text(
                        text = "Заметки по топикам",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold
                    )

                    Spacer(Modifier.height(16.dp))

                    if (state.topicSlices.isEmpty()) {
                        EmptyCardText("Добавьте заметки в альбомы с топиками, чтобы увидеть распределение.")
                    } else {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(
                                modifier = Modifier.weight(1f),
                                verticalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                state.topicSlices.take(5).forEach { slice ->
                                    TopicLegendRow(slice = slice)
                                }
                            }

                            Spacer(Modifier.width(8.dp))

                            TopicDonutChart(
                                slices = state.topicSlices,
                                modifier = Modifier.size(170.dp)
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            AnalyticsCard {
                Column(Modifier.fillMaxWidth().padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.14f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = "AI",
                                color = MaterialTheme.colorScheme.primary,
                                fontWeight = FontWeight.Bold
                            )
                        }

                        Spacer(Modifier.width(12.dp))

                        Column {
                            Text(
                                text = "Анализ от ИИ",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.SemiBold
                            )
                            Text(
                                text = "Рекомендации по текущим заметкам",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }

                    Spacer(Modifier.height(16.dp))

                    when {
                        state.isAiLoading -> {
                            CircularProgressIndicator()
                        }

                        state.aiErrorText != null -> {
                            EmptyCardText(state.aiErrorText)
                        }

                        else -> {
                            state.insights.forEach { insight ->
                                InsightRow(text = insight)
                                Spacer(Modifier.height(10.dp))
                            }
                        }
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            Card(
                shape = RoundedCornerShape(18.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.96f)
                ),
                elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 14.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(18.dp)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.16f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .clip(CircleShape)
                                .background(MaterialTheme.colorScheme.primary)
                        )
                    }
                    Spacer(Modifier.width(10.dp))
                    Text(
                        text = state.updatedAtText,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            if (state.isLoading) {
                Spacer(Modifier.height(16.dp))
                CircularProgressIndicator()
            }

            Spacer(Modifier.height(20.dp))
        }
    }
}

@Composable
private fun AnalyticsCard(
    content: @Composable () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(22.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)
    ) {
        content()
    }
}

@Composable
private fun BadgeLabel(text: String) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.12f))
            .padding(horizontal = 10.dp, vertical = 6.dp)
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.labelMedium,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.primary
        )
    }
}

@Composable
private fun ActivityBarChart(points: List<AnalyticsBarPoint>) {
    val maxCount = (points.maxOfOrNull { it.count } ?: 0).coerceAtLeast(1)

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(190.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalAlignment = Alignment.Bottom
    ) {
        points.forEach { point ->
            val ratio = point.count.toFloat() / maxCount.toFloat()
            val barHeight = (32 + (110 * ratio)).dp

            Column(
                modifier = Modifier.weight(1f),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Bottom
            ) {
                Text(
                    text = point.count.toString(),
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(Modifier.height(8.dp))
                Box(
                    modifier = Modifier
                        .width(28.dp)
                        .height(barHeight)
                        .clip(RoundedCornerShape(topStart = 10.dp, topEnd = 10.dp))
                        .background(
                            if (point.count == maxCount && point.count > 0) {
                                MaterialTheme.colorScheme.primary
                            } else {
                                MaterialTheme.colorScheme.primary.copy(alpha = 0.36f)
                            }
                        )
                )
                Spacer(Modifier.height(10.dp))
                Text(
                    text = point.label,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun TopicLegendRow(slice: AnalyticsTopicSlice) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier = Modifier
                .size(9.dp)
                .clip(CircleShape)
                .background(slice.color)
        )
        Spacer(Modifier.width(8.dp))
        Text(
            text = slice.name,
            modifier = Modifier.weight(1f),
            style = MaterialTheme.typography.bodyMedium
        )
        Spacer(Modifier.width(8.dp))
        Text(
            text = "${slice.percentage}%",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun TopicDonutChart(
    slices: List<AnalyticsTopicSlice>,
    modifier: Modifier = Modifier
) {
    val total = slices.sumOf { it.value.toDouble() }.toFloat().coerceAtLeast(1f)

    Box(modifier = modifier, contentAlignment = Alignment.Center) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val strokeWidth = size.minDimension * 0.22f
            var startAngle = -90f

            slices.forEach { slice ->
                val sweep = 360f * (slice.value / total)
                drawArc(
                    color = slice.color,
                    startAngle = startAngle,
                    sweepAngle = sweep,
                    useCenter = false,
                    style = Stroke(width = strokeWidth, cap = StrokeCap.Butt),
                    size = Size(size.width, size.height)
                )
                startAngle += sweep
            }
        }

        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = "Топики",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = "100%",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
private fun InsightRow(text: String) {
    Row(verticalAlignment = Alignment.Top) {
        Box(
            modifier = Modifier
                .padding(top = 7.dp)
                .size(7.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.primary)
        )
        Spacer(Modifier.width(10.dp))
        Text(
            text = text,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}

@Composable
private fun EmptyCardText(text: String) {
    Text(
        text = text,
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )
}

@Preview(showBackground = true)
@Composable
private fun AnalyticsScreenPreview() {
    EmotionAppTheme {
        AnalyticsScreen(
            state = AnalyticsUiState(
                selectedPeriod = AnalyticsPeriod.WEEK,
                activityPoints = listOf(
                    AnalyticsBarPoint("Пн", 3, "Понедельник"),
                    AnalyticsBarPoint("Вт", 2, "Вторник"),
                    AnalyticsBarPoint("Ср", 1, "Среда"),
                    AnalyticsBarPoint("Чт", 2, "Четверг"),
                    AnalyticsBarPoint("Пт", 4, "Пятница"),
                    AnalyticsBarPoint("Сб", 5, "Суббота"),
                    AnalyticsBarPoint("Вс", 6, "Воскресенье")
                ),
                topicSlices = listOf(
                    AnalyticsTopicSlice(1L, "Работа", androidx.compose.ui.graphics.Color(0xFF7C4DFF), 4f, 36),
                    AnalyticsTopicSlice(2L, "Учёба", androidx.compose.ui.graphics.Color(0xFFB388FF), 3f, 28),
                    AnalyticsTopicSlice(3L, "Идеи", androidx.compose.ui.graphics.Color(0xFFFFD54F), 2f, 19),
                    AnalyticsTopicSlice(4L, "Личное", androidx.compose.ui.graphics.Color(0xFF80CBC4), 1f, 17)
                ),
                insights = listOf(
                    "За неделю вы создали 24 заметки. Это на 7 больше, чем за прошлый период.",
                    "Больше всего заметок относится к теме «Работа» - 36%. Можно вынести её в отдельный фокусный альбом.",
                    "Наиболее продуктивный день - воскресенье. Попробуйте использовать это окно времени для ключевых записей."
                ),
                totalNotesLabel = "24 заметки",
                activityBadgeText = "+7 • Вс",
                updatedAtText = "Обновлено сегодня 12:53"
            ),
            onBack = {},
            onRefresh = {},
            onSelectPeriod = {}
        )
    }
}
