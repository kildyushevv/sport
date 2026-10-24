import Foundation

// MARK: - Каталог

enum MuscleGroup: String, CaseIterable, Identifiable, Hashable {
    case chest = "Грудь"
    case back = "Спина"
    case legs = "Ноги"
    case shoulders = "Плечи"
    case arms = "Руки"
    case core = "Пресс"
    case cardio = "Кардио"
    case mobility = "Мобильность"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .chest, .back, .shoulders, .arms: return "figure.strengthtraining.traditional"
        case .legs: return "figure.step.training"
        case .core: return "figure.core.training"
        case .cardio: return "figure.run"
        case .mobility: return "figure.flexibility"
        }
    }

    var photo: PhotoCatalog.Key {
        switch self {
        case .chest: return .chest
        case .back: return .back
        case .legs: return .legs
        case .shoulders: return .shoulders
        case .arms: return .arms
        case .core: return .core
        case .cardio: return .cardio
        case .mobility: return .mobility
        }
    }
}

enum Difficulty: String, Hashable {
    case beginner = "Новичок"
    case intermediate = "Средний"
    case advanced = "Продвинутый"

    /// Число заполненных делений в индикаторе сложности (из 3).
    var level: Int {
        switch self {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        }
    }
}

/// Чем измеряется подход: повторениями или секундами.
enum Measure: Hashable {
    case reps
    case seconds

    func format(_ value: Int) -> String {
        switch self {
        case .reps: return "\(value)"
        case .seconds: return "\(value) с"
        }
    }
}

struct Exercise: Identifiable, Hashable {
    let id: String
    let name: String
    let group: MuscleGroup
    let secondary: String
    let equipment: String
    let difficulty: Difficulty
    let measure: Measure
    /// Упражнение с отягощением: для него считается расчётный 1ПМ и рекорды.
    let isWeighted: Bool
    let summary: String
    let steps: [String]
    let tips: [String]

    var photoURL: URL? { PhotoCatalog.url(group.photo) }

    /// Можно делать дома без инвентаря: со своим весом или на коврике.
    var isHomeFriendly: Bool { equipment == "Свой вес" || equipment == "Коврик" }
}

// MARK: - План

struct PlannedExercise: Identifiable, Hashable {
    let exerciseID: String
    let sets: Int
    /// Целевое число повторений или секунд (см. `Exercise.measure`).
    let target: Int
    /// Рабочий вес в кг, 0 — без отягощения.
    let weight: Double
    let restSeconds: Int

    var id: String { exerciseID }
}

struct WorkoutDay: Identifiable, Hashable {
    /// 0 — понедельник … 6 — воскресенье.
    let weekdayIndex: Int
    let title: String
    let focus: String
    let durationMinutes: Int
    let photo: PhotoCatalog.Key
    let items: [PlannedExercise]

    var id: Int { weekdayIndex }
    var isRest: Bool { items.isEmpty }
    var photoURL: URL? { PhotoCatalog.url(photo) }
}

// MARK: - История

struct LoggedSet: Hashable {
    let value: Int
    let weight: Double
}

struct LoggedExercise: Identifiable, Hashable {
    let exerciseID: String
    let sets: [LoggedSet]
    /// Если задано, подходы записаны в этой единице (домашние тренировки идут по времени).
    var measureOverride: Measure? = nil

    var id: String { exerciseID }
}

enum SessionLocation: Hashable {
    case gym
    case home
}

struct WorkoutSession: Identifiable, Hashable {
    let id: UUID
    let date: Date
    let title: String
    let focus: String
    let durationMinutes: Int
    let calories: Int
    let photo: PhotoCatalog.Key
    let exercises: [LoggedExercise]
    var location: SessionLocation = .gym

    var photoURL: URL? { PhotoCatalog.url(photo) }
    var totalSets: Int { exercises.reduce(0) { $0 + $1.sets.count } }
}

// MARK: - Домашние программы

/// Круговая интервальная тренировка со своим весом: работа/отдых по времени.
struct HomeProgram: Identifiable, Hashable {
    let id: String
    let title: String
    let tagline: String
    let goal: String
    let level: Difficulty
    let workSeconds: Int
    let restSeconds: Int
    let rounds: Int
    let roundRestSeconds: Int
    let exerciseIDs: [String]
    let photo: PhotoCatalog.Key
    /// Ориентировочный расход энергии, ккал в минуту.
    let kcalPerMinute: Double
    /// Без прыжков и шума — подходит для квартиры.
    let lowImpact: Bool

    var photoURL: URL? { PhotoCatalog.url(photo) }

    var segments: [TimerSegment] {
        TimerEngine.circuit(
            exerciseIDs: exerciseIDs,
            work: workSeconds,
            rest: restSeconds,
            rounds: rounds,
            roundRest: roundRestSeconds
        )
    }

    var durationMinutes: Int {
        let total = segments.reduce(0) { $0 + $1.duration }
        return max(1, Int((total / 60).rounded()))
    }

    var estimatedKcal: Int {
        Int((Double(durationMinutes) * kcalPerMinute).rounded())
    }

    var schemeText: String {
        restSeconds > 0 ? "\(workSeconds) с работа / \(restSeconds) с отдых" : "\(workSeconds) с работа"
    }
}

struct BodyWeightEntry: Identifiable, Hashable {
    let date: Date
    let kilograms: Double

    var id: Date { date }
}
