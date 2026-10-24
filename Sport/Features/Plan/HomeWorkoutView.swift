import SwiftUI
import UIKit

/// Домашняя круговая тренировка на таймере: подготовка → работа/отдых → итоги.
struct HomeWorkoutView: View {
    let program: HomeProgram

    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var engine = TimerEngine()
    @State private var showSummary = false
    @State private var confirmExit = false
    @State private var startedAt = Date()

    private let ticker = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    private var current: TimerSegment? { engine.current }
    private var currentExercise: Exercise? {
        current?.exerciseID.flatMap { store.exercise($0) }
    }

    private var isWork: Bool { current?.kind == .work }
    private var isPrepare: Bool { engine.index == 0 && current?.kind == .rest }

    /// Сколько рабочих интервалов дошло до конца.
    private var completedWork: Int {
        engine.completedSegments.filter { engine.segments.indices.contains($0) && engine.segments[$0].kind == .work }.count
    }

    private var totalWork: Int {
        engine.segments.filter { $0.kind == .work }.count
    }

    var body: some View {
        ZStack {
            Color.sportBackground.ignoresSafeArea()

            if showSummary {
                summaryView
            } else {
                workoutView
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            engine.onEvent = { Haptics.play($0) }
            engine.load(program.segments)
            startedAt = Date()
            engine.start()
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .onReceive(ticker) { _ in
            guard !showSummary else { return }
            engine.tick()
            if engine.isFinished { showSummary = true }
        }
        .confirmationDialog("Завершить тренировку?", isPresented: $confirmExit, titleVisibility: .visible) {
            if completedWork > 0 {
                Button("Завершить и сохранить") {
                    engine.pause()
                    showSummary = true
                }
            }
            Button("Выйти без сохранения", role: .destructive) { dismiss() }
            Button("Продолжить", role: .cancel) { engine.start() }
        }
    }

    // MARK: Тренировка

    private var workoutView: some View {
        VStack(spacing: 0) {
            topBar

            Spacer(minLength: 8)

            VStack(spacing: 16) {
                phaseBadge
                exerciseCard
                countdown
                hint
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 8)

            controls
        }
    }

    private var topBar: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    engine.pause()
                    confirmExit = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Color.white)
                        .frame(width: 40, height: 40)
                        .background(Color.sportCardRaised, in: Circle())
                }
                Spacer()
                VStack(spacing: 2) {
                    Eyebrow(text: program.title, color: .sportMuted)
                    if let current, !isPrepare {
                        Text("Раунд \(current.round) из \(current.totalRounds)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            ProgressBar(fraction: engine.elapsedFraction)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var phaseBadge: some View {
        let title: String
        if isPrepare {
            title = "Приготовьтесь"
        } else if isWork {
            title = "Работа"
        } else {
            title = "Отдых"
        }
        let color: Color = isWork ? .sportLime : .white
        return Text(title.uppercased())
            .font(.system(size: 13, weight: .black))
            .tracking(1.8)
            .foregroundStyle(isWork ? Color.black : Color.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 14)
            .background(isWork ? color : Color.white.opacity(0.14), in: Capsule())
    }

    @ViewBuilder
    private var exerciseCard: some View {
        if let exercise = currentExercise, let motion = ExerciseAnimations.motions[exercise.id] {
            ExerciseAnimationCard(
                motion: motion,
                eyebrow: isWork ? exercise.group.rawValue : "Дальше",
                title: exercise.name,
                height: 240,
                isPlaying: engine.isRunning
            )
            .id(exercise.id)
        } else {
            photoCard
        }
    }

    private var photoCard: some View {
        PhotoCard(
            url: currentExercise?.photoURL,
            symbol: currentExercise?.group.symbol ?? "figure.strengthtraining.traditional",
            eyebrow: isWork ? nil : "Дальше",
            title: currentExercise?.name ?? "Тренировка",
            detail: currentExercise?.secondary,
            height: 220,
            titleSize: 28
        )
    }

    private var countdown: some View {
        VStack(spacing: 8) {
            Text(Format.clock(engine.remaining))
                .font(.sportNumber(104))
                .foregroundStyle(isWork ? Color.sportLime : Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                    Capsule()
                        .fill(isWork ? Color.sportLime : Color.white)
                        .frame(width: proxy.size.width * engine.fractionRemaining)
                        .animation(.linear(duration: 0.1), value: engine.fractionRemaining)
                }
            }
            .frame(height: 8)
        }
    }

    @ViewBuilder
    private var hint: some View {
        if let tip = currentExercise?.tips.first {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.sportLime)
                    .padding(.top, 3)
                Text(tip)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button(engine.isRunning ? "ПАУЗА" : "ПРОДОЛЖИТЬ") {
                engine.toggle()
                Haptics.tap()
            }
            .buttonStyle(LimeButtonStyle())

            Button("ДАЛЕЕ") {
                engine.skip()
                if engine.isFinished { showSummary = true }
            }
            .buttonStyle(GhostButtonStyle(compact: true))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // MARK: Итоги

    private var elapsedMinutes: Int {
        max(1, Int(Date().timeIntervalSince(startedAt) / 60))
    }

    private var summaryView: some View {
        let minutes = elapsedMinutes
        let kcal = Int((Double(minutes) * program.kcalPerMinute).rounded())

        return ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ScreenTitle(title: "Готово!", subtitle: program.title)

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    StatTile(value: "\(minutes)", label: "минут", highlighted: true)
                    StatTile(value: "≈\(kcal)", label: "ккал")
                    StatTile(value: "\(completedWork)", label: "из \(totalWork) интервалов")
                    StatTile(value: "\(program.exerciseIDs.count)", label: "упражнений")
                }

                Text("Калории — ориентировочная оценка по времени и интенсивности программы.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.sportMuted)

                Button("СОХРАНИТЬ В ИСТОРИЮ") {
                    save(minutes: minutes, kcal: kcal)
                }
                .buttonStyle(LimeButtonStyle())

                Button("Не сохранять") { dismiss() }
                    .buttonStyle(GhostButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
        }
    }

    private func save(minutes: Int, kcal: Int) {
        // Сколько интервалов реально выполнено по каждому упражнению.
        var counts: [String: Int] = [:]
        for index in engine.completedSegments {
            guard engine.segments.indices.contains(index) else { continue }
            let segment = engine.segments[index]
            guard segment.kind == .work, let id = segment.exerciseID else { continue }
            counts[id, default: 0] += 1
        }

        let logged = program.exerciseIDs.compactMap { id -> LoggedExercise? in
            guard let count = counts[id], count > 0 else { return nil }
            return LoggedExercise(
                exerciseID: id,
                sets: Array(repeating: LoggedSet(value: program.workSeconds, weight: 0), count: count),
                measureOverride: .seconds
            )
        }

        store.finish(WorkoutSession(
            id: UUID(),
            date: Date(),
            title: program.title,
            focus: "Дома • \(program.goal)",
            durationMinutes: minutes,
            calories: kcal,
            photo: program.photo,
            exercises: logged,
            location: .home
        ))
        dismiss()
    }
}

#Preview {
    HomeWorkoutView(program: DemoData.homePrograms[0])
        .environment(AppStore())
}
