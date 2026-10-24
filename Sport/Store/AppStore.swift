import Foundation
import Observation

/// Единое хранилище состояния приложения. Данные живут только в памяти (демо-режим).
@Observable
final class AppStore {
    let exercises: [Exercise]
    private(set) var plan: [WorkoutDay]
    private(set) var history: [WorkoutSession]
    let bodyWeight: [BodyWeightEntry]
    let homePrograms: [HomeProgram]

    private let exercisesByID: [String: Exercise]

    init(
        exercises: [Exercise] = DemoData.exercises,
        plan: [WorkoutDay] = DemoData.weekPlan,
        history: [WorkoutSession] = DemoData.makeHistory(),
        bodyWeight: [BodyWeightEntry] = DemoData.makeBodyWeight(),
        homePrograms: [HomeProgram] = DemoData.homePrograms
    ) {
        self.exercises = exercises
        self.plan = plan
        self.history = history
        self.bodyWeight = bodyWeight
        self.homePrograms = homePrograms
        self.exercisesByID = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })
    }

    func exercise(_ id: String) -> Exercise? {
        exercisesByID[id]
    }

    var exercisesByIDMap: [String: Exercise] { exercisesByID }

    // MARK: План

    /// Индекс сегодняшнего дня недели: 0 — понедельник … 6 — воскресенье.
    static func todayIndex(now: Date = .now, calendar: Calendar = .sport) -> Int {
        (calendar.component(.weekday, from: now) + 5) % 7
    }

    /// Выполнена ли тренировка этого дня плана сегодня.
    func isDone(_ day: WorkoutDay, now: Date = .now, calendar: Calendar = .sport) -> Bool {
        guard day.weekdayIndex == Self.todayIndex(now: now, calendar: calendar) else { return false }
        return history.contains { calendar.isDate($0.date, inSameDayAs: now) && $0.title == day.title }
    }

    /// Добавляет упражнение в конец указанного дня плана.
    func addToPlan(exercise: Exercise, dayIndex: Int) {
        guard let position = plan.firstIndex(where: { $0.weekdayIndex == dayIndex }) else { return }
        let day = plan[position]
        guard !day.items.contains(where: { $0.exerciseID == exercise.id }) else { return }

        let item = PlannedExercise(
            exerciseID: exercise.id,
            sets: 3,
            target: exercise.measure == .seconds ? 45 : 10,
            weight: 0,
            restSeconds: 60
        )
        plan[position] = WorkoutDay(
            weekdayIndex: day.weekdayIndex,
            title: day.isRest ? "Свободная тренировка" : day.title,
            focus: day.isRest ? exercise.group.rawValue : day.focus,
            durationMinutes: day.durationMinutes + 8,
            photo: day.isRest ? exercise.group.photo : day.photo,
            items: day.items + [item]
        )
    }

    func isInPlan(_ exercise: Exercise, dayIndex: Int) -> Bool {
        plan.first(where: { $0.weekdayIndex == dayIndex })?.items.contains { $0.exerciseID == exercise.id } ?? false
    }

    // MARK: Дома

    /// Программа, рекомендованная на сегодня: ротация по дням недели.
    func recommendedHomeProgram(now: Date = .now) -> HomeProgram? {
        guard !homePrograms.isEmpty else { return nil }
        return homePrograms[Self.todayIndex(now: now) % homePrograms.count]
    }

    func homeSessions(since date: Date) -> [WorkoutSession] {
        history.filter { $0.location == .home && $0.date >= date }
    }

    // MARK: История

    func finish(_ session: WorkoutSession) {
        history.insert(session, at: 0)
        history.sort { $0.date > $1.date }
    }
}
