import Foundation

enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .week:
            return "Неделя"
        case .month:
            return "Месяц"
        case .year:
            return "Год"
        }
    }

    var summaryText: String {
        switch self {
        case .week:
            return "неделю"
        case .month:
            return "последние 5 недель"
        case .year:
            return "последний год"
        }
    }

    var productivityUnit: String {
        switch self {
        case .week:
            return "день"
        case .month:
            return "неделя"
        case .year:
            return "месяц"
        }
    }
}

struct AnalyticsActivityPoint: Identifiable, Equatable {
    let bucketStart: Date
    let label: String
    let badgeLabel: String
    let detailText: String
    let count: Int

    var id: Date {
        bucketStart
    }
}

struct AnalyticsTopicSlice: Identifiable, Equatable {
    let id: String
    let topicId: Int64?
    let name: String
    let colorHex: String
    let notesCount: Int
    let percentage: Int
}

struct AnalyticsInsight: Identifiable, Equatable {
    let id: String
    let text: String
}

@MainActor
final class AnalyticsViewModel: ObservableObject {
    private let userId: Int64
    private let albumsRepo: AlbumsRepositoryProtocol
    private let notesRepo: NotesRepositoryProtocol
    private let topicsRepo: TopicsRepositoryProtocol
    private let aiRepo: AnalyticsAIRepositoryProtocol

    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.timeZone = .current
        calendar.firstWeekday = 2
        return calendar
    }()

    @Published var isLoading: Bool = false
    @Published var isAiLoading: Bool = false
    @Published var errorMessage: String?
    @Published var aiErrorMessage: String?
    @Published var selectedPeriod: AnalyticsPeriod = .week {
        didSet {
            guard oldValue != selectedPeriod else { return }
            rebuildPresentation()
        }
    }

    @Published private(set) var activityPoints: [AnalyticsActivityPoint] = []
    @Published private(set) var topicSlices: [AnalyticsTopicSlice] = []
    @Published private(set) var insights: [AnalyticsInsight] = []
    @Published private(set) var totalNotesText: String = "0 заметок"
    @Published private(set) var activityBadgeText: String = "Пока без активности"
    @Published private(set) var updatedAtText: String = "Ещё не обновлялось"

    private var allAlbums: [Album] = []
    private var allTopics: [Topic] = []
    private var allNotes: [Note] = []
    private var lastUpdatedAt: Date?
    private var aiRefreshTask: Task<Void, Never>?
    private var aiRequestID: Int = 0

    init(
        userId: Int64,
        albumsRepo: AlbumsRepositoryProtocol,
        notesRepo: NotesRepositoryProtocol,
        topicsRepo: TopicsRepositoryProtocol,
        aiRepo: AnalyticsAIRepositoryProtocol
    ) {
        self.userId = userId
        self.albumsRepo = albumsRepo
        self.notesRepo = notesRepo
        self.topicsRepo = topicsRepo
        self.aiRepo = aiRepo
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task { [weak self] in
            guard let self else { return }

            do {
                async let albumsTask = albumsRepo.fetchAlbums(userId: userId)
                async let topicsTask = topicsRepo.fetchTopics()

                let (albums, topics) = try await (albumsTask, topicsTask)
                let notes = try await fetchNotes(for: albums)

                allAlbums = albums
                allTopics = topics
                allNotes = notes
                lastUpdatedAt = Date()
                rebuildPresentation()
                isLoading = false
            } catch {
                errorMessage = "Не удалось загрузить аналитику"
                isLoading = false
            }
        }
    }

    func retry() {
        load()
    }
}

private extension AnalyticsViewModel {
    struct AnalyticsRange {
        let interval: DateInterval
        let periodType: String
    }

    struct AggregatedEmotionSnapshot {
        let analyzedAlbumCount: Int
        let analyzedNoteCount: Int
        let topWords: [String]
        let dominantEmotion: String
        let valence: String
        let confidence: Double
        let noteEmotionCounts: EmotionCountsDTO
    }

    func fetchNotes(for albums: [Album]) async throws -> [Note] {
        var loadedNotes: [Note] = []

        try await withThrowingTaskGroup(of: [Note].self) { group in
            for album in albums {
                group.addTask { [userId, notesRepo] in
                    try await notesRepo.fetchNotes(userId: userId, albumId: album.id)
                }
            }

            for try await notes in group {
                loadedNotes.append(contentsOf: notes)
            }
        }

        return loadedNotes.sorted { $0.createdAt < $1.createdAt }
    }

    func rebuildPresentation() {
        aiRefreshTask?.cancel()
        let now = Date()
        let currentRange = makeCurrentRange(relativeTo: now)
        let previousRange = makePreviousRange(from: currentRange.interval)
        let currentNotes = allNotes.filter { contains($0.createdAt, in: currentRange.interval) }
        let previousNotes = allNotes.filter { contains($0.createdAt, in: previousRange) }
        let activityPoints = makeActivityPoints(for: currentNotes, range: currentRange.interval)
        let topicSlices = makeTopicSlices(for: currentNotes)

        self.activityPoints = activityPoints
        self.topicSlices = topicSlices
        self.totalNotesText = Self.notesCountText(currentNotes.count)
        self.activityBadgeText = makeActivityBadgeText(
            currentCount: currentNotes.count,
            previousCount: previousNotes.count,
            peakPoint: activityPoints.max { lhs, rhs in lhs.count < rhs.count }
        )
        self.updatedAtText = Self.updatedAtText(from: lastUpdatedAt ?? now)

        guard !currentNotes.isEmpty else {
            isAiLoading = false
            aiErrorMessage = nil
            insights = Self.emptyInsights
            return
        }

        isAiLoading = true
        aiErrorMessage = nil
        insights = []
        refreshAIInsights(currentNotes: currentNotes, range: currentRange, topicSlices: topicSlices)
    }

    func makeCurrentRange(relativeTo date: Date) -> AnalyticsRange {
        switch selectedPeriod {
        case .week:
            let todayStart = calendar.startOfDay(for: date)
            let start = calendar.date(byAdding: .day, value: -6, to: todayStart) ?? todayStart
            let end = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? date
            return AnalyticsRange(interval: DateInterval(start: start, end: end), periodType: "week")

        case .month:
            let currentWeek = calendar.dateInterval(of: .weekOfYear, for: date) ?? DateInterval(start: date, duration: 1)
            let start = calendar.date(byAdding: .weekOfYear, value: -4, to: currentWeek.start) ?? currentWeek.start
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek.start) ?? currentWeek.end
            return AnalyticsRange(interval: DateInterval(start: start, end: end), periodType: "month")

        case .year:
            let currentMonth = calendar.dateInterval(of: .month, for: date) ?? DateInterval(start: date, duration: 1)
            let start = calendar.date(byAdding: .month, value: -11, to: currentMonth.start) ?? currentMonth.start
            let end = calendar.date(byAdding: .month, value: 1, to: currentMonth.start) ?? currentMonth.end
            return AnalyticsRange(interval: DateInterval(start: start, end: end), periodType: "custom")
        }
    }

    func makePreviousRange(from currentRange: DateInterval) -> DateInterval {
        let duration = currentRange.end.timeIntervalSince(currentRange.start)
        let start = currentRange.start.addingTimeInterval(-duration)
        return DateInterval(start: start, end: currentRange.start)
    }

    func contains(_ date: Date, in interval: DateInterval) -> Bool {
        date >= interval.start && date < interval.end
    }

    func makeActivityPoints(for notes: [Note], range: DateInterval) -> [AnalyticsActivityPoint] {
        switch selectedPeriod {
        case .week:
            return makeDailyPoints(for: notes, start: range.start, numberOfDays: 7)
        case .month:
            return makeWeeklyPoints(for: notes, start: range.start, numberOfWeeks: 5)
        case .year:
            return makeMonthlyPoints(for: notes, start: range.start, numberOfMonths: 12)
        }
    }

    func makeDailyPoints(for notes: [Note], start: Date, numberOfDays: Int) -> [AnalyticsActivityPoint] {
        (0..<numberOfDays).compactMap { offset in
            guard let dayStart = calendar.date(byAdding: .day, value: offset, to: start),
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                return nil
            }

            let count = notes.filter { contains($0.createdAt, in: DateInterval(start: dayStart, end: dayEnd)) }.count

            return AnalyticsActivityPoint(
                bucketStart: dayStart,
                label: Self.shortWeekdayLabel(for: dayStart, calendar: calendar),
                badgeLabel: Self.weekBadgeFormatter.string(from: dayStart).capitalized,
                detailText: Self.weekDetailFormatter.string(from: dayStart),
                count: count
            )
        }
    }

    func makeWeeklyPoints(for notes: [Note], start: Date, numberOfWeeks: Int) -> [AnalyticsActivityPoint] {
        (0..<numberOfWeeks).compactMap { offset in
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: start),
                  let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart),
                  let lastDay = calendar.date(byAdding: .day, value: -1, to: weekEnd) else {
                return nil
            }

            let interval = DateInterval(start: weekStart, end: weekEnd)
            let count = notes.filter { contains($0.createdAt, in: interval) }.count

            return AnalyticsActivityPoint(
                bucketStart: weekStart,
                label: Self.dayMonthFormatter.string(from: weekStart),
                badgeLabel: "с \(Self.dayMonthFormatter.string(from: weekStart))",
                detailText: "Неделя \(Self.dayMonthFormatter.string(from: weekStart)) - \(Self.dayMonthFormatter.string(from: lastDay))",
                count: count
            )
        }
    }

    func makeMonthlyPoints(for notes: [Note], start: Date, numberOfMonths: Int) -> [AnalyticsActivityPoint] {
        (0..<numberOfMonths).compactMap { offset in
            guard let monthStart = calendar.date(byAdding: .month, value: offset, to: start),
                  let monthInterval = calendar.dateInterval(of: .month, for: monthStart) else {
                return nil
            }

            let count = notes.filter { contains($0.createdAt, in: monthInterval) }.count
            let monthName = Self.monthFormatter.string(from: monthStart)

            return AnalyticsActivityPoint(
                bucketStart: monthStart,
                label: String(monthName.prefix(3)).capitalized,
                badgeLabel: monthName.capitalized,
                detailText: monthName.capitalized,
                count: count
            )
        }
    }

    func makeTopicSlices(for notes: [Note]) -> [AnalyticsTopicSlice] {
        guard !notes.isEmpty else {
            return []
        }

        let topicsById = Dictionary(uniqueKeysWithValues: allTopics.map { ($0.id, $0) })
        var counts: [Int64: Int] = [:]
        var noTopicCount = 0

        for note in notes {
            if let topicId = note.topicId, let topic = topicsById[topicId] {
                counts[topic.id, default: 0] += 1
            } else {
                noTopicCount += 1
            }
        }

        var slices = counts
            .compactMap { topicId, count -> AnalyticsTopicSlice? in
                guard let topic = topicsById[topicId] else { return nil }
                let percentage = Int((Double(count) / Double(notes.count) * 100).rounded())
                return AnalyticsTopicSlice(
                    id: "topic-\(topicId)",
                    topicId: topicId,
                    name: topic.name,
                    colorHex: topic.colorHex,
                    notesCount: count,
                    percentage: percentage
                )
            }
            .sorted { lhs, rhs in
                if lhs.notesCount == rhs.notesCount {
                    return lhs.name < rhs.name
                }
                return lhs.notesCount > rhs.notesCount
            }

        if noTopicCount > 0 {
            slices.append(
                AnalyticsTopicSlice(
                    id: "topic-none",
                    topicId: nil,
                    name: "Без темы",
                    colorHex: "#CBD5E1",
                    notesCount: noTopicCount,
                    percentage: Int((Double(noTopicCount) / Double(notes.count) * 100).rounded())
                )
            )
        }

        return slices
    }

    func makeActivityBadgeText(
        currentCount: Int,
        previousCount: Int,
        peakPoint: AnalyticsActivityPoint?
    ) -> String {
        guard currentCount > 0, let peakPoint, peakPoint.count > 0 else {
            return "Пока без активности"
        }

        let delta = currentCount - previousCount
        let deltaPrefix = delta > 0 ? "+\(delta)" : "\(delta)"

        if previousCount == 0 {
            return "\(Self.notesCountText(currentCount)) • \(peakPoint.badgeLabel)"
        }

        return "\(deltaPrefix) • \(peakPoint.badgeLabel)"
    }

    func refreshAIInsights(
        currentNotes: [Note],
        range: AnalyticsRange,
        topicSlices: [AnalyticsTopicSlice]
    ) {
        aiRequestID += 1
        let requestID = aiRequestID
        let albumIdsInRange = Array(Set(currentNotes.map(\.albumId))).sorted()
        let topTopicId = topicSlices.first(where: { $0.topicId != nil })?.topicId

        aiRefreshTask = Task { [weak self] in
            guard let self else { return }

            var aggregatedEmotion: AggregatedEmotionSnapshot?
            var topicAnalysis: TopicEmotionAnalysis?
            var partialFailure = false

            if !albumIdsInRange.isEmpty {
                var albumAnalyses: [AlbumEmotionAnalysis] = []

                for albumId in albumIdsInRange {
                    do {
                        let analysis = try await aiRepo.analyzeAlbumPeriod(
                            userId: userId,
                            albumId: albumId,
                            periodFrom: range.interval.start,
                            periodTo: range.interval.end,
                            periodType: range.periodType
                        )
                        albumAnalyses.append(analysis)
                    } catch {
                        partialFailure = true
                    }
                }

                aggregatedEmotion = Self.aggregateEmotionAnalyses(albumAnalyses)
            }

            if let topTopicId {
                do {
                    topicAnalysis = try await aiRepo.getTopicEmotion(
                        userId: userId,
                        topicId: topTopicId,
                        periodFrom: range.interval.start,
                        periodTo: range.interval.end
                    )
                } catch {
                    partialFailure = true
                }
            }

            guard !Task.isCancelled, requestID == aiRequestID else {
                return
            }

            let generatedInsights = makeAIInsights(
                aggregatedEmotion: aggregatedEmotion,
                topicAnalysis: topicAnalysis
            )

            isAiLoading = false
            aiErrorMessage = generatedInsights.isEmpty
                ? "Не удалось получить AI-анализ для выбранного периода."
                : (partialFailure ? "Часть AI-анализа сейчас недоступна." : nil)
            insights = generatedInsights.isEmpty
                ? [AnalyticsInsight(id: "ai-unavailable", text: "AI-анализ временно недоступен. Проверьте соединение с ML-сервисом.")]
                : generatedInsights
        }
    }

    func makeAIInsights(
        aggregatedEmotion: AggregatedEmotionSnapshot?,
        topicAnalysis: TopicEmotionAnalysis?
    ) -> [AnalyticsInsight] {
        var items: [AnalyticsInsight] = []

        if let aggregatedEmotion {
            items.append(
                AnalyticsInsight(
                    id: "emotion-dominant",
                    text: "За \(selectedPeriod.summaryText) по всем заметкам преобладает \(Self.emotionLabel(aggregatedEmotion.dominantEmotion)) (\(Self.percentText(aggregatedEmotion.confidence))). Общий эмоциональный окрас: \(Self.valenceLabel(aggregatedEmotion.valence))."
                )
            )

            if !aggregatedEmotion.topWords.isEmpty {
                items.append(
                    AnalyticsInsight(
                        id: "emotion-words",
                        text: "Проанализировано \(Self.notesCountText(aggregatedEmotion.analyzedNoteCount)) из \(aggregatedEmotion.analyzedAlbumCount) \(Self.pluralForm(aggregatedEmotion.analyzedAlbumCount, one: "альбома", few: "альбомов", many: "альбомов")). Часто встречаются слова: \(aggregatedEmotion.topWords.prefix(3).joined(separator: ", "))."
                    )
                )
            }

            if let dominantCount = Self.dominantEmotionCount(from: aggregatedEmotion.noteEmotionCounts) {
                items.append(
                    AnalyticsInsight(
                        id: "emotion-counts",
                        text: "Сервис чаще всего относил заметки к эмоции «\(Self.emotionLabel(dominantCount.label))»: \(dominantCount.count) \(Self.pluralForm(dominantCount.count, one: "раз", few: "раза", many: "раз"))."
                    )
                )
            }
        }

        if let topicAnalysis {
            items.append(
                AnalyticsInsight(
                    id: "topic-emotion",
                    text: "По теме «\(topicAnalysis.name)» сильнее всего выражена \(Self.emotionLabel(topicAnalysis.dominantEmotion)) (\(Self.percentText(topicAnalysis.confidence))). По этой теме проанализировано \(Self.notesCountText(topicAnalysis.noteCount))."
                )
            )
        }

        return Array(items.prefix(3))
    }
}

private extension AnalyticsViewModel {
    static func aggregateEmotionAnalyses(_ analyses: [AlbumEmotionAnalysis]) -> AggregatedEmotionSnapshot? {
        guard !analyses.isEmpty else {
            return nil
        }

        var joy = 0
        var sadness = 0
        var anger = 0
        var fear = 0
        var surprise = 0
        var neutral = 0
        var wordFrequency: [String: Int] = [:]

        for analysis in analyses {
            joy += analysis.noteEmotionCounts.joy
            sadness += analysis.noteEmotionCounts.sadness
            anger += analysis.noteEmotionCounts.anger
            fear += analysis.noteEmotionCounts.fear
            surprise += analysis.noteEmotionCounts.surprise
            neutral += analysis.noteEmotionCounts.neutral

            for word in analysis.topWords {
                let cleanedWord = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                guard !cleanedWord.isEmpty else { continue }
                wordFrequency[cleanedWord, default: 0] += 1
            }
        }

        let aggregatedCounts = EmotionCountsDTO(
            joy: joy,
            sadness: sadness,
            anger: anger,
            fear: fear,
            surprise: surprise,
            neutral: neutral
        )
        let emotionPairs: [(String, Int)] = [
            ("joy", joy),
            ("sadness", sadness),
            ("anger", anger),
            ("fear", fear),
            ("surprise", surprise),
            ("neutral", neutral)
        ]
        guard let dominantPair = emotionPairs.max(by: { lhs, rhs in lhs.1 < rhs.1 }) else {
            return nil
        }

        let totalCount = emotionPairs.map(\.1).reduce(0, +)
        let confidence = totalCount > 0 ? Double(dominantPair.1) / Double(totalCount) : 0
        let negativeCount = sadness + anger + fear
        let valence: String

        if joy > max(negativeCount, neutral + surprise) {
            valence = "positive"
        } else if negativeCount > max(joy, neutral + surprise) {
            valence = "negative"
        } else {
            valence = "neutral"
        }

        let topWords = wordFrequency
            .sorted { lhs, rhs in
                if lhs.value == rhs.value {
                    return lhs.key < rhs.key
                }
                return lhs.value > rhs.value
            }
            .map(\.key)
            .prefix(5)

        return AggregatedEmotionSnapshot(
            analyzedAlbumCount: analyses.count,
            analyzedNoteCount: totalCount,
            topWords: Array(topWords),
            dominantEmotion: dominantPair.0,
            valence: valence,
            confidence: confidence,
            noteEmotionCounts: aggregatedCounts
        )
    }

    static let emptyInsights: [AnalyticsInsight] = [
        AnalyticsInsight(id: "empty-1", text: "За выбранный период заметок пока нет. Создайте несколько записей, чтобы увидеть динамику."),
        AnalyticsInsight(id: "empty-2", text: "Как только появятся записи, ML-сервис оценит эмоциональный окрас заметок и тем."),
        AnalyticsInsight(id: "empty-3", text: "Добавляйте заметки в разные топики, чтобы AI-анализ был точнее и полезнее.")
    ]

    static let weekBadgeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = .current
        formatter.dateFormat = "E, d MMM"
        return formatter
    }()

    static let weekDetailFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = .current
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter
    }()

    static let dayMonthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = .current
        formatter.dateFormat = "d MMM"
        return formatter
    }()

    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = .current
        formatter.dateFormat = "LLLL"
        return formatter
    }()

    static let updatedFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static func shortWeekdayLabel(for date: Date, calendar: Calendar) -> String {
        let symbols = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
        let index = calendar.component(.weekday, from: date) - 1
        guard symbols.indices.contains(index) else {
            return ""
        }
        return symbols[index]
    }

    static func notesCountText(_ count: Int) -> String {
        "\(count) \(pluralForm(count, one: "заметка", few: "заметки", many: "заметок"))"
    }

    static func updatedAtText(from date: Date) -> String {
        "Обновлено сегодня \(updatedFormatter.string(from: date))"
    }

    static func emotionLabel(_ code: String) -> String {
        switch code {
        case "joy":
            return "радость"
        case "sadness":
            return "грусть"
        case "anger":
            return "злость"
        case "fear":
            return "страх"
        case "surprise":
            return "удивление"
        default:
            return "нейтральность"
        }
    }

    static func valenceLabel(_ code: String) -> String {
        switch code {
        case "positive":
            return "позитивный"
        case "negative":
            return "негативный"
        default:
            return "нейтральный"
        }
    }

    static func percentText(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    static func dominantEmotionCount(from counts: EmotionCountsDTO) -> (label: String, count: Int)? {
        [
            ("joy", counts.joy),
            ("sadness", counts.sadness),
            ("anger", counts.anger),
            ("fear", counts.fear),
            ("surprise", counts.surprise),
            ("neutral", counts.neutral)
        ]
        .max { lhs, rhs in lhs.1 < rhs.1 }
        .flatMap { $0.1 > 0 ? (label: $0.0, count: $0.1) : nil }
    }

    static func pluralForm(_ count: Int, one: String, few: String, many: String) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100

        if remainder10 == 1 && remainder100 != 11 {
            return one
        }
        if (2...4).contains(remainder10) && !(12...14).contains(remainder100) {
            return few
        }
        return many
    }
}
