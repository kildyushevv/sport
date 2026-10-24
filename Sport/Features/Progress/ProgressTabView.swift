import SwiftUI
import Charts

/// Вкладка «Прогресс». Назван `ProgressTabView`, чтобы не пересекаться со `SwiftUI.ProgressView`.
struct ProgressTabView: View {
    private enum Period: CaseIterable, Hashable {
        case month, quarter, half

        var weeks: Int {
            switch self {
            case .month: return 4
            case .quarter: return 12
            case .half: return 26
            }
        }

        var title: String {
            switch self {
            case .month: return "4 нед"
            case .quarter: return "12 нед"
            case .half: return "6 мес"
            }
        }

        /// Шаг подписей оси X в неделях.
        var axisStride: Int {
            switch self {
            case .month: return 1
            case .quarter: return 2
            case .half: return 5
            }
        }
    }

    @Environment(AppStore.self) private var store
    @State private var period: Period = .quarter
    @State private var selectedLift = "bench-press"

    private let trackedLifts = ["bench-press", "squat", "deadlift", "ohp", "bent-row", "rdl"]

    // MARK: Данные

    private var volumes: [WeeklyVolume] {
        Analytics.weeklyVolumes(sessions: store.history, weeks: period.weeks)
    }

    private var periodStart: Date {
        volumes.first?.weekStart ?? .now
    }

    private var sessionsInPeriod: [WorkoutSession] {
        store.history.filter { $0.date >= periodStart }
    }

    private var weights: [BodyWeightEntry] {
        store.bodyWeight.filter { $0.date >= periodStart }
    }

    private var liftSeries: [OneRMPoint] {
        Analytics.oneRMSeries(sessions: store.history, exerciseID: selectedLift, since: periodStart)
    }

    private var records: [PersonalRecord] {
        Array(Analytics.personalRecords(sessions: store.history, exercises: store.exercisesByIDMap).prefix(5))
    }

    private func domain(_ values: [Double], padding: Double) -> ClosedRange<Double> {
        guard let low = values.min(), let high = values.max() else { return 0...1 }
        return (low - padding)...(high + padding)
    }

    private func signed(_ value: Double, unit: String) -> String {
        let rounded = (value * 10).rounded() / 10
        let sign = rounded > 0 ? "+" : ""
        return "\(sign)\(Format.number(rounded)) \(unit)"
    }

    // MARK: Экран

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                VStack(alignment: .leading, spacing: 24) {
                    PillPicker(options: Period.allCases, selection: $period) { $0.title }
                    tiles
                    volumeChart
                    weightChart
                    liftChart
                    recordsList
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(edges: .top)
        .sportScreen()
    }

    private var header: some View {
        RemotePhoto(url: PhotoCatalog.url(.progress), symbol: "chart.line.uptrend.xyaxis")
            .frame(height: 230)
            .overlay(PhotoScrim())
            .overlay(alignment: .bottomLeading) {
                ScreenTitle(title: "Прогресс", subtitle: "Силовые, вес тела, рекорды")
                    .padding(20)
            }
    }

    // MARK: Плитки

    private var tiles: some View {
        let streak = Analytics.streakWeeks(sessions: store.history)
        let total = sessionsInPeriod.reduce(0.0) { $0 + Analytics.volume(of: $1) }
        let perWeek = period.weeks == 0 ? 0 : total / Double(period.weeks)

        return LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            StatTile(value: "\(streak)", label: "недель подряд", highlighted: true)
            StatTile(value: "\(sessionsInPeriod.count)", label: "тренировок")
            StatTile(value: Format.number((perWeek / 100).rounded() / 10), label: "тонн в неделю")
            StatTile(
                value: Format.number(Double(sessionsInPeriod.reduce(0) { $0 + $1.durationMinutes }) / 60),
                label: "часов в зале"
            )
        }
    }

    // MARK: Объём

    private var volumeChart: some View {
        let average = volumes.isEmpty ? 0 : volumes.reduce(0) { $0 + $1.volume } / Double(volumes.count)

        return ChartCard(title: "Недельный объём", value: "\(Format.number((average / 100).rounded() / 10)) т", caption: "в среднем за неделю") {
            Chart(volumes) { item in
                BarMark(
                    x: .value("Неделя", item.weekStart, unit: .weekOfYear),
                    y: .value("Объём, кг", item.volume)
                )
                .foregroundStyle(Color.sportLime)
                .cornerRadius(4)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear, count: period.axisStride)) { _ in
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        .foregroundStyle(Color.sportMuted)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel {
                        if let kilograms = value.as(Double.self) {
                            Text("\(Int(kilograms / 1000)) т")
                                .foregroundStyle(Color.sportMuted)
                        }
                    }
                }
            }
            .environment(\.calendar, .sport)
            .environment(\.locale, Locale(identifier: "ru_RU"))
            .frame(height: 200)
        }
    }

    // MARK: Вес тела

    private var weightChart: some View {
        let values = weights.map(\.kilograms)
        let range = domain(values, padding: 1)
        let change = (weights.last?.kilograms ?? 0) - (weights.first?.kilograms ?? 0)

        return ChartCard(
            title: "Вес тела",
            value: Format.kilograms(weights.last?.kilograms ?? 0),
            caption: "\(signed(change, unit: "кг")) за период"
        ) {
            Chart(weights) { entry in
                AreaMark(
                    x: .value("Дата", entry.date),
                    yStart: .value("Минимум", range.lowerBound),
                    yEnd: .value("Вес, кг", entry.kilograms)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.sportLime.opacity(0.35), Color.sportLime.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Дата", entry.date),
                    y: .value("Вес, кг", entry.kilograms)
                )
                .foregroundStyle(Color.sportLime)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: range)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        .foregroundStyle(Color.sportMuted)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel().foregroundStyle(Color.sportMuted)
                }
            }
            .environment(\.calendar, .sport)
            .environment(\.locale, Locale(identifier: "ru_RU"))
            .frame(height: 200)
        }
    }

    // MARK: Силовые

    private var availableLifts: [Exercise] {
        trackedLifts.compactMap { store.exercise($0) }
    }

    private var liftChart: some View {
        let series = liftSeries
        let range = domain(series.map(\.value), padding: 5)
        let change = (series.last?.value ?? 0) - (series.first?.value ?? 0)

        return VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Силовые")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableLifts) { lift in
                        Button {
                            selectedLift = lift.id
                        } label: {
                            Chip(title: lift.name, isSelected: selectedLift == lift.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)

            ChartCard(
                title: "Расчётный 1ПМ",
                value: Format.kilograms((series.last?.value ?? 0).rounded()),
                caption: "\(signed(change.rounded(), unit: "кг")) за период"
            ) {
                if series.isEmpty {
                    Text("Нет данных за выбранный период")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.sportMuted)
                        .frame(maxWidth: .infinity, minHeight: 120)
                } else {
                    Chart(series) { point in
                        LineMark(
                            x: .value("Дата", point.date),
                            y: .value("1ПМ, кг", point.value)
                        )
                        .foregroundStyle(Color.sportLime)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Дата", point.date),
                            y: .value("1ПМ, кг", point.value)
                        )
                        .foregroundStyle(Color.sportLime)
                        .symbolSize(28)
                    }
                    .chartYScale(domain: range)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                                .foregroundStyle(Color.sportMuted)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                            AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                            AxisValueLabel().foregroundStyle(Color.sportMuted)
                        }
                    }
                    .environment(\.calendar, .sport)
                    .environment(\.locale, Locale(identifier: "ru_RU"))
                    .frame(height: 200)
                }
            }
        }
    }

    // MARK: Рекорды

    private var recordsList: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Личные рекорды")
            VStack(spacing: 0) {
                ForEach(Array(records.enumerated()), id: \.element.id) { offset, record in
                    if let exercise = store.exercise(record.exerciseID) {
                        HStack(spacing: 14) {
                            Text("\(offset + 1)")
                                .font(.sportNumber(20))
                                .foregroundStyle(offset == 0 ? Color.sportLime : Color.sportMuted)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.white)
                                Text(Format.dayMonth(record.date))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.sportMuted)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(Format.kilograms(record.weight))
                                    .font(.sportNumber(20))
                                    .foregroundStyle(Color.white)
                                Text("× \(record.reps)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color.sportMuted)
                            }
                        }
                        .padding(.vertical, 12)
                        if offset < records.count - 1 {
                            Divider().overlay(Color.sportLine)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.sportLine, lineWidth: 1)
            )
        }
    }
}

/// Карточка с заголовком, крупным значением и графиком.
private struct ChartCard<Content: View>: View {
    let title: String
    let value: String
    let caption: String
    let content: Content

    init(title: String, value: String, caption: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.caption = caption
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: title, color: .sportMuted)
                Text(value)
                    .font(.sportNumber(38))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(caption)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.sportLime)
            }
            content
        }
        .sportCard()
    }
}

#Preview {
    ProgressTabView()
        .environment(AppStore())
        .preferredColorScheme(.dark)
}
