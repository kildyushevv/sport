import Foundation

struct WeeklyVolume: Identifiable, Hashable {
    let weekStart: Date
    let volume: Double
    let sessions: Int

    var id: Date { weekStart }
}

struct OneRMPoint: Identifiable, Hashable {
    let date: Date
    let value: Double

    var id: Date { date }
}

struct PersonalRecord: Identifiable, Hashable {
    let exerciseID: String
    let weight: Double
    let reps: Int
    let date: Date

    var id: String { exerciseID }
}

/// Чистые функции для графиков и статистики — без UI и состояния.
enum Analytics {

    /// Расчётный максимум на одно повторение по формуле Эпли.
    static func epley(weight: Double, reps: Int) -> Double {
        guard reps > 1 else { return weight }
        return weight * (1 + Double(reps) / 30)
    }

    static func volume(of session: WorkoutSession) -> Double {
        session.exercises.reduce(0) { total, exercise in
            total + exercise.sets.reduce(0) { $0 + $1.weight * Double($1.value) }
        }
    }

    /// Объём (кг × повторения) по неделям; последняя неделя — текущая.
    static func weeklyVolumes(
        sessions: [WorkoutSession],
        weeks: Int,
        now: Date = .now,
        calendar: Calendar = .sport
    ) -> [WeeklyVolume] {
        guard let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return [] }

        var buckets: [Date: (volume: Double, count: Int)] = [:]
        for session in sessions {
            guard let start = calendar.dateInterval(of: .weekOfYear, for: session.date)?.start else { continue }
            var bucket = buckets[start] ?? (0, 0)
            bucket.volume += volume(of: session)
            bucket.count += 1
            buckets[start] = bucket
        }

        return stride(from: weeks - 1, through: 0, by: -1).compactMap { offset in
            guard let start = calendar.date(byAdding: .weekOfYear, value: -offset, to: currentWeekStart) else { return nil }
            let bucket = buckets[start] ?? (0, 0)
            return WeeklyVolume(weekStart: start, volume: bucket.volume, sessions: bucket.count)
        }
    }

    /// Лучший расчётный 1ПМ в каждой тренировке для выбранного упражнения.
    static func oneRMSeries(sessions: [WorkoutSession], exerciseID: String, since: Date? = nil) -> [OneRMPoint] {
        sessions
            .filter { since == nil || $0.date >= since! }
            .compactMap { session -> OneRMPoint? in
                guard let logged = session.exercises.first(where: { $0.exerciseID == exerciseID }) else { return nil }
                let best = logged.sets.map { epley(weight: $0.weight, reps: $0.value) }.max() ?? 0
                return best > 0 ? OneRMPoint(date: session.date, value: best) : nil
            }
            .sorted { $0.date < $1.date }
    }

    /// Максимальный рабочий вес по каждому упражнению с отягощением.
    static func personalRecords(sessions: [WorkoutSession], exercises: [String: Exercise]) -> [PersonalRecord] {
        var best: [String: PersonalRecord] = [:]
        for session in sessions {
            for logged in session.exercises {
                guard exercises[logged.exerciseID]?.isWeighted == true else { continue }
                for set in logged.sets {
                    let current = best[logged.exerciseID]
                    if current == nil || set.weight > current!.weight {
                        best[logged.exerciseID] = PersonalRecord(
                            exerciseID: logged.exerciseID, weight: set.weight, reps: set.value, date: session.date
                        )
                    }
                }
            }
        }
        return best.values.sorted { $0.weight > $1.weight }
    }

    /// Сколько недель подряд (считая от текущей или прошлой) была хотя бы одна тренировка.
    static func streakWeeks(sessions: [WorkoutSession], now: Date = .now, calendar: Calendar = .sport) -> Int {
        let weeks = Set(sessions.compactMap { calendar.dateInterval(of: .weekOfYear, for: $0.date)?.start })
        guard var cursor = calendar.dateInterval(of: .weekOfYear, for: now)?.start else { return 0 }

        // Если на текущей неделе тренировок ещё не было, считаем серию с прошлой недели.
        if !weeks.contains(cursor), let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor) {
            cursor = previous
        }

        var streak = 0
        while weeks.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }
}
