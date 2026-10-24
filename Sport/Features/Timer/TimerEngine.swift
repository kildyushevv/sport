import Foundation
import Observation

struct TimerSegment: Equatable {
    enum Kind: Equatable {
        case work
        case rest
    }

    let kind: Kind
    let duration: TimeInterval
    /// Номер раунда, начиная с 1.
    let round: Int
    let totalRounds: Int
}

enum TimerEvent: Equatable {
    case started
    case segmentChanged(TimerSegment.Kind)
    case countdown
    case finished
}

/// Таймер из последовательности сегментов (работа/отдых). Время считается по метке окончания,
/// поэтому точность не страдает, если экран гас или приложение было в фоне.
@Observable
final class TimerEngine {
    private(set) var segments: [TimerSegment] = []
    private(set) var index = 0
    /// Сколько осталось до конца текущего сегмента.
    private(set) var remaining: TimeInterval = 0
    private(set) var isRunning = false
    private(set) var isFinished = false

    @ObservationIgnored var onEvent: ((TimerEvent) -> Void)?
    @ObservationIgnored private var segmentEnd: Date?
    @ObservationIgnored private var lastCountdownSecond: Int?

    // MARK: Состояние

    var current: TimerSegment? {
        segments.indices.contains(index) ? segments[index] : nil
    }

    /// Доля времени, оставшаяся в текущем сегменте (1 → 0).
    var fractionRemaining: Double {
        guard let current, current.duration > 0 else { return 0 }
        return min(1, max(0, remaining / current.duration))
    }

    /// Таймер ещё не запускался или был сброшен.
    var isIdle: Bool {
        guard let first = segments.first else { return true }
        return !isRunning && !isFinished && index == 0 && remaining >= first.duration
    }

    var totalDuration: TimeInterval {
        segments.reduce(0) { $0 + $1.duration }
    }

    // MARK: Управление

    func load(_ newSegments: [TimerSegment]) {
        isRunning = false
        isFinished = false
        segmentEnd = nil
        lastCountdownSecond = nil
        segments = newSegments
        index = 0
        remaining = newSegments.first?.duration ?? 0
    }

    func start(now: Date = .now) {
        if isFinished { load(segments) }
        guard !isRunning, current != nil else { return }
        if isIdle { onEvent?(.started) }
        segmentEnd = now.addingTimeInterval(remaining)
        lastCountdownSecond = nil
        isRunning = true
    }

    func pause(now: Date = .now) {
        guard isRunning, let end = segmentEnd else { return }
        remaining = max(0, end.timeIntervalSince(now))
        segmentEnd = nil
        isRunning = false
    }

    func toggle(now: Date = .now) {
        isRunning ? pause(now: now) : start(now: now)
    }

    func reset() {
        load(segments)
    }

    /// Перейти к следующему сегменту (или завершить таймер).
    func skip(now: Date = .now) {
        guard !isFinished, current != nil else { return }
        if index + 1 < segments.count {
            index += 1
            remaining = segments[index].duration
            lastCountdownSecond = nil
            if isRunning { segmentEnd = now.addingTimeInterval(remaining) }
            onEvent?(.segmentChanged(segments[index].kind))
        } else {
            finishAll()
        }
    }

    /// Добавить время к текущему сегменту.
    func add(seconds: TimeInterval, now: Date = .now) {
        guard !isFinished, current != nil else { return }
        remaining += seconds
        if isRunning { segmentEnd = now.addingTimeInterval(remaining) }
    }

    /// Вызывается несколько раз в секунду из интерфейса.
    func tick(now: Date = .now) {
        guard isRunning, var end = segmentEnd else { return }
        var left = end.timeIntervalSince(now)

        while left <= 0 {
            guard index + 1 < segments.count else {
                finishAll()
                return
            }
            index += 1
            end = end.addingTimeInterval(segments[index].duration)
            left = end.timeIntervalSince(now)
            lastCountdownSecond = nil
            onEvent?(.segmentChanged(segments[index].kind))
        }

        segmentEnd = end
        remaining = left

        let second = Int(left.rounded(.up))
        if second <= 3, second != lastCountdownSecond {
            lastCountdownSecond = second
            onEvent?(.countdown)
        }
    }

    private func finishAll() {
        remaining = 0
        segmentEnd = nil
        isRunning = false
        isFinished = true
        onEvent?(.finished)
    }

    // MARK: Конструкторы последовательностей

    /// Раунды «работа → отдых». После последнего раунда отдыха нет.
    static func intervals(work: Int, rest: Int, rounds: Int) -> [TimerSegment] {
        guard work > 0, rounds > 0 else { return [] }
        var result: [TimerSegment] = []
        for round in 1...rounds {
            result.append(TimerSegment(kind: .work, duration: TimeInterval(work), round: round, totalRounds: rounds))
            if rest > 0, round < rounds {
                result.append(TimerSegment(kind: .rest, duration: TimeInterval(rest), round: round, totalRounds: rounds))
            }
        }
        return result
    }

    static func rest(seconds: Int) -> [TimerSegment] {
        guard seconds > 0 else { return [] }
        return [TimerSegment(kind: .rest, duration: TimeInterval(seconds), round: 1, totalRounds: 1)]
    }
}

/// Секундомер с отсечками кругов.
@Observable
final class Stopwatch {
    private(set) var elapsed: TimeInterval = 0
    private(set) var isRunning = false
    /// Время каждого круга, последний круг — первый в списке.
    private(set) var laps: [TimeInterval] = []

    @ObservationIgnored private var startedAt: Date?
    @ObservationIgnored private var accumulated: TimeInterval = 0
    @ObservationIgnored private var lastLapMark: TimeInterval = 0

    var isIdle: Bool { !isRunning && elapsed == 0 }

    func start(now: Date = .now) {
        guard !isRunning else { return }
        startedAt = now
        isRunning = true
    }

    func pause(now: Date = .now) {
        guard isRunning, let startedAt else { return }
        accumulated += now.timeIntervalSince(startedAt)
        elapsed = accumulated
        self.startedAt = nil
        isRunning = false
    }

    func toggle(now: Date = .now) {
        isRunning ? pause(now: now) : start(now: now)
    }

    func tick(now: Date = .now) {
        guard isRunning, let startedAt else { return }
        elapsed = accumulated + now.timeIntervalSince(startedAt)
    }

    func lap(now: Date = .now) {
        guard isRunning else { return }
        tick(now: now)
        laps.insert(elapsed - lastLapMark, at: 0)
        lastLapMark = elapsed
    }

    func reset() {
        isRunning = false
        startedAt = nil
        accumulated = 0
        lastLapMark = 0
        elapsed = 0
        laps = []
    }
}
