import Charts
import SwiftUI

struct AnalyticsView: View {
    let userId: Int64
    let albumsRepo: AlbumsRepositoryProtocol
    let notesRepo: NotesRepositoryProtocol
    let topicsRepo: TopicsRepositoryProtocol
    let aiRepo: AnalyticsAIRepositoryProtocol

    @StateObject
    private var viewModel: AnalyticsViewModel

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
        _viewModel = StateObject(
            wrappedValue: AnalyticsViewModel(
                userId: userId,
                albumsRepo: albumsRepo,
                notesRepo: notesRepo,
                topicsRepo: topicsRepo,
                aiRepo: aiRepo
            )
        )
    }

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    periodPicker

                    if let errorMessage = viewModel.errorMessage {
                        errorCard(message: errorMessage)
                    }

                    activityCard
                    topicsCard
                    insightsCard
                    updateCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Аналитика")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.retry()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            viewModel.load()
        }
        .overlay {
            if viewModel.isLoading && viewModel.activityPoints.isEmpty {
                ProgressView()
                    .tint(Color(.systemBlue))
            }
        }
    }
}

// MARK: - UI
private extension AnalyticsView {
    var periodPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AnalyticsPeriod.allCases) { period in
                    ChipView(title: period.title, isSelected: viewModel.selectedPeriod == period) {
                        viewModel.selectedPeriod = period
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    var activityCard: some View {
        AnalyticsCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Активность")
                            .font(.headline)
                            .foregroundStyle(Color(.label))

                        Text(viewModel.totalNotesText)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }

                    Spacer(minLength: 0)

                    Text(viewModel.activityBadgeText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                if viewModel.activityPoints.contains(where: { $0.count > 0 }) {
                    Chart(viewModel.activityPoints) { point in
                        BarMark(
                            x: .value("Период", point.label),
                            y: .value("Количество", point.count)
                        )
                        .foregroundStyle(isPeak(point) ? Color.blue : Color.blue.opacity(0.35))
                        .cornerRadius(8)
                    }
                    .chartLegend(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .chartXAxis {
                        AxisMarks(values: viewModel.activityPoints.map(\.label)) { value in
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .frame(height: 190)
                } else {
                    emptyState(
                        title: "Пока нет заметок за этот период",
                        message: "Как только появятся новые записи, здесь отобразится график активности."
                    )
                }
            }
            .padding(16)
        }
    }

    var topicsCard: some View {
        AnalyticsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Заметки по топикам")
                    .font(.headline)
                    .foregroundStyle(Color(.label))

                if viewModel.topicSlices.isEmpty {
                    emptyState(
                        title: "Недостаточно данных по топикам",
                        message: "Добавьте заметки с темами, чтобы увидеть распределение и доли."
                    )
                } else {
                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(viewModel.topicSlices.prefix(5))) { slice in
                                TopicLegendRow(slice: slice)
                            }
                        }

                        Spacer(minLength: 0)

                        Chart(viewModel.topicSlices) { slice in
                            SectorMark(
                                angle: .value("Количество", slice.notesCount),
                                innerRadius: .ratio(0.58),
                                angularInset: 2
                            )
                            .foregroundStyle(Color(hex: slice.colorHex))
                        }
                        .chartLegend(.hidden)
                        .frame(width: 150, height: 150)
                    }
                }
            }
            .padding(16)
        }
    }

    var insightsCard: some View {
        AnalyticsCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Анализ от ИИ")
                            .font(.headline)
                            .foregroundStyle(Color(.label))

                        Text("Выводы из реального ML-сервиса")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                }

                if viewModel.isAiLoading {
                    HStack {
                        ProgressView()
                            .tint(Color.blue)
                        Text("Получаем AI-анализ...")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        if let aiErrorMessage = viewModel.aiErrorMessage {
                            Text(aiErrorMessage)
                                .font(.footnote)
                                .foregroundStyle(Color.orange)
                        }

                        ForEach(viewModel.insights) { insight in
                            InsightRow(text: insight.text)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    var updateCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle")
                .foregroundStyle(Color.teal)

            Text(viewModel.updatedAtText)
                .font(.footnote)
                .foregroundStyle(Color.secondary)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.secondary.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    func errorCard(message: String) -> some View {
        AnalyticsCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Не удалось обновить аналитику")
                    .font(.headline)
                    .foregroundStyle(Color(.label))

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondary)

                Button("Повторить") {
                    viewModel.retry()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(16)
        }
    }

    func emptyState(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.label))

            Text(message)
                .font(.footnote)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }

    func isPeak(_ point: AnalyticsActivityPoint) -> Bool {
        let maxCount = viewModel.activityPoints.map(\.count).max() ?? 0
        return maxCount > 0 && point.count == maxCount
    }
}

private struct AnalyticsCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

private struct TopicLegendRow: View {
    let slice: AnalyticsTopicSlice

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: slice.colorHex))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(slice.name)
                    .font(.subheadline)
                    .foregroundStyle(Color(.label))

                Text("\(slice.percentage)% • \(slice.notesCount)")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

private struct InsightRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.blue.opacity(0.8))
                .frame(width: 6, height: 6)
                .padding(.top, 6)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else {
            self = Color.blue.opacity(0.35)
            return
        }

        let red = Double((value & 0xFF0000) >> 16) / 255
        let green = Double((value & 0x00FF00) >> 8) / 255
        let blue = Double(value & 0x0000FF) / 255

        self = Color(red: red, green: green, blue: blue)
    }
}
