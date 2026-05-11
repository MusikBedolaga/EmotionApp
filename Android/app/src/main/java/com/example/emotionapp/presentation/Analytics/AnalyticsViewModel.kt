package com.example.emotionapp.presentation.Analytics

import androidx.compose.ui.graphics.Color
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.emotionapp.domain.entities.Album
import com.example.emotionapp.domain.entities.AlbumEmotionAnalysis
import com.example.emotionapp.domain.entities.NoteSummary
import com.example.emotionapp.domain.entities.Topic
import com.example.emotionapp.domain.entities.TopicEmotionAnalysis
import com.example.emotionapp.domain.repository.AiRepository
import com.example.emotionapp.domain.repository.AlbumRepository
import com.example.emotionapp.domain.repository.NoteRepository
import com.example.emotionapp.domain.repository.TopicRepository
import com.example.emotionapp.presentation.utils.notesCountText
import com.example.emotionapp.utils.NetworkResult
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.time.Instant
import java.time.LocalDate
import java.time.YearMonth
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.util.Locale
import javax.inject.Inject

enum class AnalyticsPeriod(val title: String, val summaryText: String, val productivityUnit: String) {
    WEEK(title = "Неделя", summaryText = "неделю", productivityUnit = "день"),
    MONTH(title = "Месяц", summaryText = "5 недель", productivityUnit = "неделю"),
    YEAR(title = "Год", summaryText = "год", productivityUnit = "месяц")
}

data class AnalyticsBarPoint(
    val label: String,
    val count: Int,
    val detail: String
)

data class AnalyticsTopicSlice(
    val topicId: Long?,
    val name: String,
    val color: Color,
    val value: Float,
    val percentage: Int
)

data class AnalyticsUiState(
    val selectedPeriod: AnalyticsPeriod = AnalyticsPeriod.WEEK,
    val isLoading: Boolean = false,
    val isAiLoading: Boolean = false,
    val errorText: String? = null,
    val aiErrorText: String? = null,
    val activityPoints: List<AnalyticsBarPoint> = emptyList(),
    val topicSlices: List<AnalyticsTopicSlice> = emptyList(),
    val insights: List<String> = emptyList(),
    val totalNotesLabel: String = notesCountText(0),
    val activityBadgeText: String = "Пока без активности",
    val updatedAtText: String = "Ещё не обновлялось"
)

private data class AnalyticsNote(
    val albumId: Long,
    val albumTitle: String,
    val title: String,
    val date: LocalDate,
    val topicIds: List<Long>
)

private data class AnalyticsRange(
    val periodFrom: Instant,
    val periodTo: Instant,
    val periodType: String
)

class AnalyticsViewModel @Inject constructor(
    private val albumRepository: AlbumRepository,
    private val noteRepository: NoteRepository,
    private val topicRepository: TopicRepository,
    private val aiRepository: AiRepository
) : ViewModel() {

    private val zoneId: ZoneId = ZoneId.systemDefault()
    private var rawTopics: List<Topic> = emptyList()
    private var rawNotes: List<AnalyticsNote> = emptyList()
    private var aiRequestVersion: Long = 0

    private val _uiState = MutableStateFlow(AnalyticsUiState())
    val uiState: StateFlow<AnalyticsUiState> = _uiState.asStateFlow()

    fun load() {
        if (_uiState.value.isLoading) return

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorText = null) }

            when (val payload = loadAnalyticsPayload()) {
                is AnalyticsPayloadResult.Error -> {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            errorText = payload.message
                        )
                    }
                }

                is AnalyticsPayloadResult.Success -> {
                    rawTopics = payload.topics
                    rawNotes = payload.notes
                    rebuildPresentation()
                }
            }
        }
    }

    fun retry() = load()

    fun onSelectPeriod(period: AnalyticsPeriod) {
        if (_uiState.value.selectedPeriod == period) return
        _uiState.update { it.copy(selectedPeriod = period) }
        rebuildPresentation()
    }

    private suspend fun loadAnalyticsPayload(): AnalyticsPayloadResult {
        val albumsResult = albumRepository.getAllAlbums()
        val topicsResult = topicRepository.getAllTopics()

        val albums = (albumsResult as? NetworkResult.Ok)?.data
            ?: return AnalyticsPayloadResult.Error(albumsResult.toErrorText("альбомы"))

        val topics = (topicsResult as? NetworkResult.Ok)?.data
            ?: return AnalyticsPayloadResult.Error(topicsResult.toErrorText("топики"))

        val notes = coroutineScope {
            albums.map { album ->
                async {
                    when (val summaryResult = noteRepository.getNotesByAlbum(album.id)) {
                        is NetworkResult.Ok -> summaryResult.data.mapNotNull { summary ->
                            summary.toAnalyticsNote(album)
                        }

                        is NetworkResult.Error -> emptyList()
                    }
                }
            }.flatMap { it.await() }
        }

        return AnalyticsPayloadResult.Success(
            topics = topics,
            notes = notes
        )
    }

    private fun rebuildPresentation() {
        val period = _uiState.value.selectedPeriod
        val anchorDate = rawNotes.maxByOrNull { it.date }?.date ?: LocalDate.now(zoneId)
        val currentNotes = notesForSelectedPeriod(period, anchorDate)
        val previousNotes = notesForPreviousPeriod(period, anchorDate)
        val activityPoints = buildActivityPoints(period, currentNotes, anchorDate)
        val topicSlices = buildTopicSlices(currentNotes)
        val peakPoint = activityPoints.maxByOrNull { it.count }

        _uiState.update {
            it.copy(
                isLoading = false,
                errorText = null,
                isAiLoading = currentNotes.isNotEmpty(),
                aiErrorText = null,
                activityPoints = activityPoints,
                topicSlices = topicSlices,
                insights = if (currentNotes.isEmpty()) {
                    listOf(
                        "За выбранный период нет заметок, поэтому AI-анализ пока не строится.",
                        "Добавьте записи в альбомы, чтобы сервис оценил эмоциональный окрас текста.",
                        "Когда появятся заметки с топиками, здесь появятся реальные выводы от ML."
                    )
                } else {
                    emptyList()
                },
                totalNotesLabel = notesCountText(currentNotes.size),
                activityBadgeText = buildBadgeText(currentNotes.size, previousNotes.size, peakPoint),
                updatedAtText = "Обновлено сегодня ${timeFormatter.format(Instant.now().atZone(zoneId))}"
            )
        }

        if (currentNotes.isNotEmpty()) {
            refreshAiInsights(period, anchorDate, currentNotes, topicSlices)
        }
    }

    private fun refreshAiInsights(
        period: AnalyticsPeriod,
        anchorDate: LocalDate,
        currentNotes: List<AnalyticsNote>,
        topicSlices: List<AnalyticsTopicSlice>
    ) {
        val requestVersion = ++aiRequestVersion
        val range = buildAiRange(period, anchorDate)
        val topAlbum = currentNotes
            .groupBy { it.albumId }
            .maxByOrNull { it.value.size }
            ?.let { (albumId, notes) -> albumId to (notes.firstOrNull()?.albumTitle ?: "Альбом") }
        val topTopic = topicSlices.firstOrNull { it.topicId != null }

        viewModelScope.launch {
            val albumResult = topAlbum?.let {
                aiRepository.analyzeAlbumPeriod(
                    albumId = it.first,
                    periodFrom = range.periodFrom,
                    periodTo = range.periodTo,
                    periodType = range.periodType
                )
            }
            val topicResult = topTopic?.topicId?.let {
                aiRepository.getTopicEmotion(
                    topicId = it,
                    periodFrom = range.periodFrom,
                    periodTo = range.periodTo
                )
            }

            if (requestVersion != aiRequestVersion || _uiState.value.selectedPeriod != period) {
                return@launch
            }

            val insights = buildAiInsightTexts(
                period = period,
                albumTitle = topAlbum?.second,
                albumResult = albumResult,
                topicResult = topicResult
            )

            _uiState.update {
                it.copy(
                    isAiLoading = false,
                    aiErrorText = if (insights.isEmpty()) "Не удалось получить AI-анализ для выбранного периода." else null,
                    insights = if (insights.isEmpty()) {
                        listOf("AI-анализ временно недоступен. Проверьте соединение с ML-сервисом.")
                    } else {
                        insights
                    }
                )
            }
        }
    }

    private fun notesForSelectedPeriod(
        period: AnalyticsPeriod,
        anchorDate: LocalDate
    ): List<AnalyticsNote> = rawNotes.filter { note ->
        when (period) {
            AnalyticsPeriod.WEEK -> note.date >= anchorDate.minusDays(6)
            AnalyticsPeriod.MONTH -> note.date >= anchorDate.minusWeeks(4).with(java.time.DayOfWeek.MONDAY)
            AnalyticsPeriod.YEAR -> note.date >= anchorDate.minusMonths(11).withDayOfMonth(1)
        }
    }

    private fun notesForPreviousPeriod(
        period: AnalyticsPeriod,
        anchorDate: LocalDate
    ): List<AnalyticsNote> {
        val currentStart = when (period) {
            AnalyticsPeriod.WEEK -> anchorDate.minusDays(6)
            AnalyticsPeriod.MONTH -> anchorDate.minusWeeks(4).with(java.time.DayOfWeek.MONDAY)
            AnalyticsPeriod.YEAR -> anchorDate.minusMonths(11).withDayOfMonth(1)
        }

        return rawNotes.filter { note ->
            when (period) {
                AnalyticsPeriod.WEEK -> note.date in currentStart.minusDays(7)..currentStart.minusDays(1)
                AnalyticsPeriod.MONTH -> note.date in currentStart.minusWeeks(5)..currentStart.minusDays(1)
                AnalyticsPeriod.YEAR -> note.date in currentStart.minusMonths(12)..currentStart.minusDays(1)
            }
        }
    }

    private fun buildActivityPoints(
        period: AnalyticsPeriod,
        notes: List<AnalyticsNote>,
        anchorDate: LocalDate
    ): List<AnalyticsBarPoint> {
        return when (period) {
            AnalyticsPeriod.WEEK -> {
                (0..6).map { offset ->
                    val day = anchorDate.minusDays((6 - offset).toLong())
                    val count = notes.count { it.date == day }
                    AnalyticsBarPoint(
                        label = shortWeekdayFormatter.format(day),
                        count = count,
                        detail = fullDateFormatter.format(day)
                    )
                }
            }

            AnalyticsPeriod.MONTH -> {
                (0..4).map { offset ->
                    val weekStart = anchorDate.minusWeeks((4 - offset).toLong()).with(java.time.DayOfWeek.MONDAY)
                    val weekEnd = weekStart.plusDays(6)
                    val count = notes.count { it.date in weekStart..weekEnd }
                    AnalyticsBarPoint(
                        label = dayMonthFormatter.format(weekStart),
                        count = count,
                        detail = "${dayMonthFormatter.format(weekStart)} - ${dayMonthFormatter.format(weekEnd)}"
                    )
                }
            }

            AnalyticsPeriod.YEAR -> {
                (0..11).map { offset ->
                    val month = YearMonth.from(anchorDate.minusMonths((11 - offset).toLong()))
                    val count = notes.count { YearMonth.from(it.date) == month }
                    AnalyticsBarPoint(
                        label = monthShortFormatter.format(month.atDay(1)),
                        count = count,
                        detail = monthTitleFormatter.format(month.atDay(1))
                    )
                }
            }
        }
    }

    private fun buildTopicSlices(notes: List<AnalyticsNote>): List<AnalyticsTopicSlice> {
        if (notes.isEmpty()) return emptyList()

        val topicWeights = linkedMapOf<Long, Float>()
        var noTopicWeight = 0f

        notes.forEach { note ->
            val ids = note.topicIds.distinct()
            if (ids.isEmpty()) {
                noTopicWeight += 1f
            } else {
                val portion = 1f / ids.size
                ids.forEach { topicId ->
                    topicWeights[topicId] = (topicWeights[topicId] ?: 0f) + portion
                }
            }
        }

        val total = topicWeights.values.sum() + noTopicWeight
        if (total <= 0f) return emptyList()

        val topicsById = rawTopics.associateBy { it.id }
        val slices = mutableListOf<AnalyticsTopicSlice>()

        topicWeights
            .toList()
            .sortedByDescending { it.second }
            .forEach { (topicId, value) ->
                val topic = topicsById[topicId] ?: return@forEach
                slices += AnalyticsTopicSlice(
                    topicId = topicId,
                    name = topic.name.replaceFirstChar {
                        if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
                    },
                    color = topic.color.toComposeColor(),
                    value = value,
                    percentage = ((value / total) * 100).toInt().coerceAtLeast(1)
                )
            }

        if (noTopicWeight > 0f) {
            slices += AnalyticsTopicSlice(
                topicId = null,
                name = "Без темы",
                color = Color(0xFFB0BEC5),
                value = noTopicWeight,
                percentage = ((noTopicWeight / total) * 100).toInt().coerceAtLeast(1)
            )
        }

        return slices
    }

    private fun buildBadgeText(
        currentCount: Int,
        previousCount: Int,
        peakPoint: AnalyticsBarPoint?
    ): String {
        if (currentCount == 0) return "Пока без активности"
        if (previousCount == 0 || peakPoint == null || peakPoint.count == 0) {
            return "${notesCountText(currentCount)} • ${peakPoint?.label ?: "старт"}"
        }

        val delta = currentCount - previousCount
        val deltaPrefix = if (delta > 0) "+$delta" else "$delta"
        return "$deltaPrefix • ${peakPoint.label}"
    }

    private fun buildAiRange(period: AnalyticsPeriod, anchorDate: LocalDate): AnalyticsRange {
        val startDate = when (period) {
            AnalyticsPeriod.WEEK -> anchorDate.minusDays(6)
            AnalyticsPeriod.MONTH -> anchorDate.minusWeeks(4).with(java.time.DayOfWeek.MONDAY)
            AnalyticsPeriod.YEAR -> anchorDate.minusMonths(11).withDayOfMonth(1)
        }
        val endDateExclusive = when (period) {
            AnalyticsPeriod.WEEK -> anchorDate.plusDays(1)
            AnalyticsPeriod.MONTH -> anchorDate.plusWeeks(1).with(java.time.DayOfWeek.MONDAY)
            AnalyticsPeriod.YEAR -> anchorDate.plusMonths(1).withDayOfMonth(1)
        }
        return AnalyticsRange(
            periodFrom = startDate.atStartOfDay(zoneId).toInstant(),
            periodTo = endDateExclusive.atStartOfDay(zoneId).toInstant(),
            periodType = when (period) {
                AnalyticsPeriod.WEEK -> "week"
                AnalyticsPeriod.MONTH -> "month"
                AnalyticsPeriod.YEAR -> "custom"
            }
        )
    }

    private fun buildAiInsightTexts(
        period: AnalyticsPeriod,
        albumTitle: String?,
        albumResult: NetworkResult<AlbumEmotionAnalysis>?,
        topicResult: NetworkResult<TopicEmotionAnalysis>?
    ): List<String> {
        val items = mutableListOf<String>()

        if (albumResult is NetworkResult.Ok) {
            val album = albumResult.data
            items += "За ${period.summaryText} в альбоме «${albumTitle ?: "Альбом"}» преобладает ${emotionLabel(album.dominantEmotion)} (${percentText(album.confidence)}). Общий эмоциональный окрас: ${valenceLabel(album.valence)}."
            if (album.topWords.isNotEmpty()) {
                items += "Чаще всего в текстах этого периода встречаются: ${album.topWords.take(3).joinToString(", ")}."
            }
            val dominantCount = dominantEmotionCount(album)
            if (dominantCount != null) {
                items += "Сервис чаще всего относил заметки к эмоции «${emotionLabel(dominantCount.first)}»: ${dominantCount.second} ${notesCountText(dominantCount.second).substringAfter(' ')}."
            }
        }

        if (topicResult is NetworkResult.Ok) {
            val topic = topicResult.data
            items += "По теме «${topic.name}» сейчас сильнее всего выражена ${emotionLabel(topic.dominantEmotion)} (${percentText(topic.confidence)}). По этой теме проанализировано ${notesCountText(topic.noteCount)}."
        }

        return items.distinct().take(3)
    }

    private fun dominantEmotionCount(album: AlbumEmotionAnalysis): Pair<String, Int>? {
        val counts = listOf(
            "joy" to album.noteEmotionCounts.joy,
            "sadness" to album.noteEmotionCounts.sadness,
            "anger" to album.noteEmotionCounts.anger,
            "fear" to album.noteEmotionCounts.fear,
            "surprise" to album.noteEmotionCounts.surprise,
            "neutral" to album.noteEmotionCounts.neutral
        )
        return counts.maxByOrNull { it.second }?.takeIf { it.second > 0 }
    }

    private fun emotionLabel(code: String): String = when (code) {
        "joy" -> "радость"
        "sadness" -> "грусть"
        "anger" -> "злость"
        "fear" -> "страх"
        "surprise" -> "удивление"
        else -> "нейтральность"
    }

    private fun valenceLabel(code: String): String = when (code) {
        "positive" -> "позитивный"
        "negative" -> "негативный"
        else -> "нейтральный"
    }

    private fun percentText(value: Double): String = "${(value * 100).toInt()}%"

    private fun NetworkResult<*>.toErrorText(what: String): String = when (this) {
        is NetworkResult.Error.Http -> "Ошибка HTTP (${code}) при загрузке $what"
        is NetworkResult.Error.Network -> "Ошибка сети при загрузке $what"
        is NetworkResult.Error.Unknown -> "Неизвестная ошибка при загрузке $what"
        is NetworkResult.Ok -> ""
    }

    private fun NoteSummary.toAnalyticsNote(album: Album): AnalyticsNote? {
        val parsedDate = parseDate(createdAt) ?: return null
        return AnalyticsNote(
            albumId = album.id,
            albumTitle = album.title,
            title = title,
            date = parsedDate,
            topicIds = album.topics.map { it.id }
        )
    }

    private fun parseDate(value: String): LocalDate? {
        return runCatching {
            Instant.parse(value).atZone(zoneId).toLocalDate()
        }.getOrNull() ?: runCatching {
            LocalDate.parse(value.take(10))
        }.getOrNull()
    }

    private sealed interface AnalyticsPayloadResult {
        data class Success(
            val topics: List<Topic>,
            val notes: List<AnalyticsNote>
        ) : AnalyticsPayloadResult

        data class Error(val message: String) : AnalyticsPayloadResult
    }

    private companion object {
        val locale: Locale = Locale.forLanguageTag("ru")
        val shortWeekdayFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("EE", locale)
        val fullDateFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMMM", locale)
        val dayMonthFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("d MMM", locale)
        val monthShortFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("LLL", locale)
        val monthTitleFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("LLLL", locale)
        val timeFormatter: DateTimeFormatter = DateTimeFormatter.ofPattern("HH:mm", locale)
    }
}

private fun String.toComposeColor(): Color {
    val cleaned = removePrefix("#")
    val parsed = cleaned.toLongOrNull(16) ?: return Color(0xFF4E7BFF)
    return when (cleaned.length) {
        6 -> Color(
            red = ((parsed shr 16) and 0xFF) / 255f,
            green = ((parsed shr 8) and 0xFF) / 255f,
            blue = (parsed and 0xFF) / 255f,
            alpha = 1f
        )

        8 -> Color(
            alpha = ((parsed shr 24) and 0xFF) / 255f,
            red = ((parsed shr 16) and 0xFF) / 255f,
            green = ((parsed shr 8) and 0xFF) / 255f,
            blue = (parsed and 0xFF) / 255f
        )

        else -> Color(0xFF4E7BFF)
    }
}
