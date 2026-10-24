import SwiftUI

/// Прохождение тренировки подход за подходом с отдыхом между ними.
struct ActiveWorkoutView: View {
    private enum Phase {
        case work
        case rest
        case summary
    }

    let day: WorkoutDay

    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var phase: Phase = .work
    @State private var exerciseIndex = 0
    @State private var setNumber = 1
    @State private var value = 0
    @State private var weight = 0.0
    @State private var logged: [String: [LoggedSet]] = [:]
    @State private var rest = TimerEngine()
    @State private var startedAt = Date()
    @State private var confirmExit = false

    private let ticker = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var planned: PlannedExercise { day.items[exerciseIndex] }
    private var exercise: Exercise? { store.exercise(planned.exerciseID) }
    private var measure: Measure { exercise?.measure ?? .reps }

    private var totalSets: Int { day.items.reduce(0) { $0 + $1.sets } }
    private var doneSets: Int { logged.values.reduce(0) { $0 + $1.count } }

    var body: some View {
        ZStack {
            Color.sportBackground.ignoresSafeArea()

            switch phase {
            case .work: workView
            case .rest: restView
            case .summary: summaryView
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            rest.onEvent = { Haptics.play($0) }
            prepareInputs()
        }
        .onReceive(ticker) { _ in
            guard phase == .rest else { return }
            rest.tick()
            if rest.isFinished { endRest() }
        }
        .confirmationDialog("Завершить тренировку?", isPresented: $confirmExit, titleVisibility: .visible) {
            if doneSets > 0 {
                Button("Завершить и сохранить") { phase = .summary }
            }
            Button("Выйти без сохранения", role: .destructive) { dismiss() }
            Button("Продолжить", role: .cancel) {}
        }
    }

    // MARK: Рабочий подход

    private var topBar: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    confirmExit = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color.white)
                        .frame(width: 40, height: 40)
                        .background(Color.sportCardRaised, in: Circle())
                }
                Spacer()
                Eyebrow(text: "Упражнение \(exerciseIndex + 1) из \(day.items.count)", color: .sportMuted)
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            ProgressBar(fraction: totalSets == 0 ? 0 : Double(doneSets) / Double(totalSets))
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var workView: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    PhotoCard(
                        url: exercise?.photoURL,
                        symbol: exercise?.group.symbol ?? "figure.strengthtraining.traditional",
                        eyebrow: exercise?.group.rawValue,
                        title: exercise?.name ?? "Упражнение",
                        detail: Format.setSummary(sets: planned.sets, target: planned.target, weight: planned.weight, measure: measure),
                        height: 240,
                        titleSize: 32
                    )

                    HStack(alignment: .firstTextBaseline) {
                        Text("ПОДХОД")
                            .font(.sportDisplay(20))
                            .foregroundStyle(Color.sportMuted)
                        Text("\(setNumber)")
                            .font(.sportNumber(64))
                            .foregroundStyle(Color.sportLime)
                        Text("/ \(planned.sets)")
                            .font(.sportNumber(28))
                            .foregroundStyle(Color.sportMuted)
                    }

                    VStack(spacing: 0) {
                        ValueStepper(
                            title: measure == .seconds ? "Время" : "Повторения",
                            value: $value,
                            range: 1...999,
                            step: measure == .seconds ? 5 : 1,
                            unit: measure == .seconds ? "с" : ""
                        )
                        if exercise?.isWeighted == true || planned.weight > 0 {
                            Divider().overlay(Color.sportLine)
                            WeightStepper(weight: $weight)
                        }
                    }
                    .padding(.horizontal, 16)
                    .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.sportLine, lineWidth: 1))

                    if let sets = logged[planned.exerciseID], !sets.isEmpty {
                        loggedChips(sets)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
            }

            VStack(spacing: 10) {
                Button("ПОДХОД ВЫПОЛНЕН") {
                    completeSet()
                }
                .buttonStyle(LimeButtonStyle())

                Button("Пропустить упражнение") {
                    skipExercise()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.sportMuted)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }

    private func loggedChips(_ sets: [LoggedSet]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Eyebrow(text: "Выполнено", color: .sportMuted)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(sets.enumerated()), id: \.offset) { offset, item in
                        Text("\(offset + 1) • \(setText(item))")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.sportLime)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Color.sportLime.opacity(0.14), in: Capsule())
                    }
                }
            }
        }
    }

    private func setText(_ set: LoggedSet) -> String {
        var text = measure.format(set.value)
        if set.weight > 0 { text += " × \(Format.kilograms(set.weight))" }
        return text
    }

    // MARK: Отдых

    private var upNextText: String {
        if setNumber > 1 || exerciseIndex == 0 {
            return "Следующий подход \(setNumber) из \(planned.sets)"
        }
        return "Дальше: \(exercise?.name ?? "следующее упражнение")"
    }

    private var restView: some View {
        VStack(spacing: 0) {
            topBar

            Spacer()

            VStack(spacing: 18) {
                Eyebrow(text: "Отдых")
                Text(Format.clock(rest.remaining))
                    .font(.sportNumber(120))
                    .foregroundStyle(Color.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(upNextText)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.sportMuted)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)

            Spacer()

            HStack(spacing: 12) {
                Button("+15 С") { rest.add(seconds: 15) }
                    .buttonStyle(GhostButtonStyle(compact: true))
                Button("ПРОПУСТИТЬ") { endRest() }
                    .buttonStyle(LimeButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
    }

    // MARK: Итоги

    private var summaryView: some View {
        let minutes = max(1, Int(Date().timeIntervalSince(startedAt) / 60))
        let sessionVolume = logged.values.reduce(0.0) { total, sets in
            total + sets.reduce(0.0) { $0 + $1.weight * Double($1.value) }
        }

        return ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ScreenTitle(title: "Готово!", subtitle: day.title)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    StatTile(value: "\(minutes)", label: "минут", highlighted: true)
                    StatTile(value: "\(doneSets)", label: "подходов")
                    StatTile(value: Format.number(sessionVolume), label: "объём", unit: "кг")
                    StatTile(value: "\(minutes * 7)", label: "ккал")
                }

                Button("СОХРАНИТЬ В ИСТОРИЮ") {
                    save(minutes: minutes)
                }
                .buttonStyle(LimeButtonStyle())

                Button("Не сохранять") { dismiss() }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
        }
    }

    // MARK: Логика

    private func prepareInputs() {
        guard day.items.indices.contains(exerciseIndex) else { return }
        let lastSet = logged[planned.exerciseID]?.last
        value = lastSet?.value ?? planned.target
        weight = lastSet?.weight ?? planned.weight
    }

    private func completeSet() {
        Haptics.tap()
        logged[planned.exerciseID, default: []].append(LoggedSet(value: value, weight: weight))

        if setNumber < planned.sets {
            setNumber += 1
            startRest(seconds: planned.restSeconds)
        } else if exerciseIndex < day.items.count - 1 {
            let restSeconds = planned.restSeconds
            exerciseIndex += 1
            setNumber = 1
            startRest(seconds: restSeconds)
        } else {
            phase = .summary
        }
    }

    private func skipExercise() {
        if exerciseIndex < day.items.count - 1 {
            exerciseIndex += 1
            setNumber = 1
            prepareInputs()
        } else {
            phase = doneSets > 0 ? .summary : .work
            if doneSets == 0 { confirmExit = true }
        }
    }

    private func startRest(seconds: Int) {
        rest.load(TimerEngine.rest(seconds: seconds))
        rest.start()
        phase = .rest
    }

    private func endRest() {
        rest.reset()
        prepareInputs()
        phase = .work
    }

    private func save(minutes: Int) {
        let exercises = day.items.compactMap { item -> LoggedExercise? in
            guard let sets = logged[item.exerciseID], !sets.isEmpty else { return nil }
            return LoggedExercise(exerciseID: item.exerciseID, sets: sets)
        }
        store.finish(WorkoutSession(
            id: UUID(),
            date: Date(),
            title: day.title,
            focus: day.focus,
            durationMinutes: minutes,
            calories: minutes * 7,
            photo: day.photo,
            exercises: exercises
        ))
        dismiss()
    }
}

/// Строка «Вес — − 82,5 кг +» с шагом 2,5 кг.
private struct WeightStepper: View {
    @Binding var weight: Double

    var body: some View {
        HStack {
            Eyebrow(text: "Вес", color: .sportMuted)
            Spacer()
            button(systemName: "minus", delta: -2.5)
            Text(Format.kilograms(weight))
                .font(.sportNumber(22))
                .foregroundStyle(Color.white)
                .frame(minWidth: 96)
            button(systemName: "plus", delta: 2.5)
        }
        .padding(.vertical, 10)
    }

    private func button(systemName: String, delta: Double) -> some View {
        Button {
            weight = max(0, weight + delta)
            Haptics.tap()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(Color.sportLime)
                .frame(width: 36, height: 36)
                .background(Color.sportCardRaised, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ActiveWorkoutView(day: DemoData.weekPlan[0])
        .environment(AppStore())
}
