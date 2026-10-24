import SwiftUI

enum Weekday {
    static let full = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    static let short = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"]
}

enum PlanMode: String, CaseIterable, Hashable {
    case gym
    case home

    var title: String {
        switch self {
        case .gym: return "Зал"
        case .home: return "Дома"
        }
    }
}

/// Какая тренировка открыта на весь экран.
private enum ActiveSession: Identifiable {
    case gym(WorkoutDay)
    case home(HomeProgram)

    var id: String {
        switch self {
        case .gym(let day): return "gym-\(day.weekdayIndex)"
        case .home(let program): return "home-\(program.id)"
        }
    }
}

struct PlanView: View {
    @Environment(AppStore.self) private var store
    @AppStorage("planMode") private var modeRaw = PlanMode.gym.rawValue
    @State private var selectedIndex = AppStore.todayIndex()
    @State private var active: ActiveSession?

    private var mode: Binding<PlanMode> {
        Binding(
            get: { PlanMode(rawValue: modeRaw) ?? .gym },
            set: { modeRaw = $0.rawValue }
        )
    }

    private let calendar = Calendar.sport
    private var todayIndex: Int { AppStore.todayIndex() }

    private var weekStart: Date {
        calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
    }

    private func date(for index: Int) -> Date {
        calendar.date(byAdding: .day, value: index, to: weekStart) ?? weekStart
    }

    private func hasSession(on date: Date) -> Bool {
        store.history.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private var selectedDay: WorkoutDay {
        store.plan.first { $0.weekdayIndex == selectedIndex } ?? store.plan[0]
    }

    private var plannedCount: Int { store.plan.filter { !$0.isRest }.count }
    private var doneThisWeek: Int {
        store.history.filter { $0.location == .gym && $0.date >= weekStart }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ScreenTitle(title: "План", subtitle: Format.dayMonth(.now))
                    PillPicker(options: PlanMode.allCases, selection: mode) { $0.title }

                    if mode.wrappedValue == .gym {
                        weekStrip
                        weekProgress
                        heroCard
                        weekList
                    } else {
                        HomePlanView { active = .home($0) }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .sportScreen()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: WorkoutDay.self) { day in
                WorkoutDayView(dayIndex: day.weekdayIndex) { active = .gym($0) }
            }
            .navigationDestination(for: HomeProgram.self) { program in
                HomeProgramView(program: program) { active = .home($0) }
            }
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
        .fullScreenCover(item: $active) { session in
            switch session {
            case .gym(let day): ActiveWorkoutView(day: day)
            case .home(let program): HomeWorkoutView(program: program)
            }
        }
    }

    // MARK: Неделя

    private var weekStrip: some View {
        HStack(spacing: 6) {
            ForEach(store.plan) { day in
                dayButton(day)
            }
        }
    }

    private func dayButton(_ day: WorkoutDay) -> some View {
        let date = date(for: day.weekdayIndex)
        let isSelected = day.weekdayIndex == selectedIndex
        let isToday = day.weekdayIndex == todayIndex
        let isDone = hasSession(on: date)

        let dotColor: Color = {
            if isDone { return isSelected ? Color.black : Color.sportLime }
            if day.isRest { return Color.clear }
            return isSelected ? Color.black.opacity(0.35) : Color.white.opacity(0.3)
        }()

        return Button {
            withAnimation(.easeOut(duration: 0.15)) { selectedIndex = day.weekdayIndex }
        } label: {
            VStack(spacing: 6) {
                Text(Weekday.short[day.weekdayIndex])
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .opacity(0.7)
                Text("\(calendar.component(.day, from: date))")
                    .font(.sportNumber(20))
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
            }
            .foregroundStyle(isSelected ? Color.black : Color.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ? Color.sportLime : Color.sportCard,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isToday && !isSelected ? Color.sportLime : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var weekProgress: some View {
        let fraction = plannedCount == 0 ? 0 : min(1, Double(doneThisWeek) / Double(plannedCount))
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Eyebrow(text: "Неделя", color: .sportMuted)
                Spacer()
                Text("\(doneThisWeek)")
                    .font(.sportNumber(30))
                    .foregroundStyle(Color.sportLime)
                Text("из \(plannedCount) тренировок")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.sportMuted)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(Color.sportLime)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .frame(height: 8)
        }
        .sportCard()
    }

    // MARK: Выбранный день

    @ViewBuilder
    private var heroCard: some View {
        let day = selectedDay
        let isToday = day.weekdayIndex == todayIndex
        let isDone = isToday && store.isDone(day)

        VStack(spacing: 14) {
            if day.isRest {
                restCard(day)
            } else {
                NavigationLink(value: day) {
                    PhotoCard(
                        url: day.photoURL,
                        symbol: "figure.strengthtraining.traditional",
                        eyebrow: isToday ? "Сегодня" : Weekday.full[day.weekdayIndex],
                        title: day.title,
                        detail: summary(of: day),
                        height: 340,
                        titleSize: 34
                    )
                }
                .buttonStyle(.plain)

                Button(isDone ? "ПОВТОРИТЬ ТРЕНИРОВКУ" : "НАЧАТЬ ТРЕНИРОВКУ") {
                    active = .gym(day)
                }
                .buttonStyle(LimeButtonStyle())
            }
        }
    }

    private func restCard(_ day: WorkoutDay) -> some View {
        PhotoCard(
            url: day.photoURL,
            symbol: "figure.flexibility",
            eyebrow: Weekday.full[day.weekdayIndex],
            title: "День отдыха",
            detail: "Сон, вода и лёгкая растяжка — мышцы растут именно сейчас",
            height: 260,
            titleSize: 34
        )
    }

    private func summary(of day: WorkoutDay) -> String {
        let sets = day.items.reduce(0) { $0 + $1.sets }
        return "\(day.durationMinutes) мин • \(day.items.count) упр. • \(sets) подходов"
    }

    // MARK: Все дни

    private var weekList: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Вся неделя")
            VStack(spacing: 10) {
                ForEach(store.plan) { day in
                    if day.isRest {
                        DayRow(day: day, isToday: day.weekdayIndex == todayIndex, subtitle: "Восстановление")
                    } else {
                        NavigationLink(value: day) {
                            DayRow(day: day, isToday: day.weekdayIndex == todayIndex, subtitle: summary(of: day))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct DayRow: View {
    let day: WorkoutDay
    let isToday: Bool
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            RemotePhoto(url: day.photoURL, symbol: "figure.strengthtraining.traditional")
                .frame(width: 72, height: 72)
                .overlay(Color.black.opacity(day.isRest ? 0.55 : 0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(
                    text: isToday ? "Сегодня" : Weekday.full[day.weekdayIndex],
                    color: isToday ? .sportLime : .sportMuted
                )
                Text(day.title.uppercased())
                    .font(.sportDisplay(19))
                    .tracking(-0.3)
                    .foregroundStyle(day.isRest ? Color.sportMuted : Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.sportMuted)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            if !day.isRest {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.sportMuted)
            }
        }
        .padding(10)
        .padding(.trailing, 6)
        .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isToday ? Color.sportLime.opacity(0.7) : Color.sportLine, lineWidth: 1)
        )
    }
}

#Preview {
    PlanView()
        .environment(AppStore())
        .preferredColorScheme(.dark)
}
