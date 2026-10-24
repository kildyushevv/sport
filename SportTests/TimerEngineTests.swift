import XCTest
@testable import Sport

final class TimerEngineTests: XCTestCase {

    func testCircuitStructure() {
        let segments = TimerEngine.circuit(
            exerciseIDs: ["a", "b"], work: 40, rest: 20, rounds: 2, roundRest: 45, prepare: 10
        )

        XCTAssertEqual(segments.map(\.kind), [.rest, .work, .rest, .work, .rest, .work, .rest, .work])
        XCTAssertEqual(segments.map(\.duration), [10, 40, 20, 40, 45, 40, 20, 40])
        // Отдых и подготовка указывают на следующее упражнение.
        XCTAssertEqual(segments[0].exerciseID, "a")
        XCTAssertEqual(segments[2].exerciseID, "b")
        XCTAssertEqual(segments[4].exerciseID, "a")
        // После последней работы отдыха нет.
        XCTAssertEqual(segments.last?.kind, .work)
    }

    func testCircuitRejectsEmptyInput() {
        XCTAssertTrue(TimerEngine.circuit(exerciseIDs: [], work: 30, rest: 10, rounds: 3, roundRest: 30).isEmpty)
        XCTAssertTrue(TimerEngine.circuit(exerciseIDs: ["a"], work: 0, rest: 10, rounds: 3, roundRest: 30).isEmpty)
        XCTAssertTrue(TimerEngine.circuit(exerciseIDs: ["a"], work: 30, rest: 10, rounds: 0, roundRest: 30).isEmpty)
    }

    func testNaturalProgressMarksSegmentsCompleted() {
        let engine = TimerEngine()
        engine.load(TimerEngine.circuit(exerciseIDs: ["a"], work: 10, rest: 5, rounds: 2, roundRest: 5, prepare: 0))
        let start = Date(timeIntervalSince1970: 1_000)
        engine.start(now: start)

        engine.tick(now: start.addingTimeInterval(10.5))
        XCTAssertEqual(engine.index, 1)
        XCTAssertEqual(engine.completedSegments, [0])

        engine.tick(now: start.addingTimeInterval(16))
        XCTAssertEqual(engine.index, 2)
        XCTAssertEqual(engine.completedSegments, [0, 1])

        engine.tick(now: start.addingTimeInterval(26))
        XCTAssertTrue(engine.isFinished)
        XCTAssertEqual(engine.completedSegments, [0, 1, 2])
    }

    func testSkipDoesNotCountSegmentAsCompleted() {
        let engine = TimerEngine()
        engine.load(TimerEngine.circuit(exerciseIDs: ["a"], work: 10, rest: 5, rounds: 2, roundRest: 5, prepare: 0))
        let start = Date(timeIntervalSince1970: 1_000)
        engine.start(now: start)

        engine.skip(now: start.addingTimeInterval(1))
        XCTAssertEqual(engine.index, 1)
        XCTAssertTrue(engine.completedSegments.isEmpty)
    }

    func testElapsedFractionGrowsToOne() {
        let engine = TimerEngine()
        engine.load(TimerEngine.intervals(work: 10, rest: 10, rounds: 2))
        let start = Date(timeIntervalSince1970: 1_000)
        XCTAssertEqual(engine.elapsedFraction, 0, accuracy: 0.001)

        engine.start(now: start)
        engine.tick(now: start.addingTimeInterval(15))
        // Всего 10 + 10 + 10 = 30 с, прошло 15.
        XCTAssertEqual(engine.elapsedFraction, 0.5, accuracy: 0.01)

        engine.tick(now: start.addingTimeInterval(40))
        XCTAssertEqual(engine.elapsedFraction, 1, accuracy: 0.001)
    }
}

final class DemoDataTests: XCTestCase {

    func testIdentifiersAreUnique() {
        let exerciseIDs = DemoData.exercises.map(\.id)
        XCTAssertEqual(Set(exerciseIDs).count, exerciseIDs.count)

        let programIDs = DemoData.homePrograms.map(\.id)
        XCTAssertEqual(Set(programIDs).count, programIDs.count)
    }

    func testHomeProgramsUseOnlyBodyweightExercises() {
        for program in DemoData.homePrograms {
            XCTAssertGreaterThan(program.durationMinutes, 0, program.id)
            XCTAssertFalse(program.exerciseIDs.isEmpty, program.id)
            for id in program.exerciseIDs {
                guard let exercise = DemoData.exercisesByID[id] else {
                    XCTFail("\(program.id): нет упражнения \(id)")
                    continue
                }
                XCTAssertTrue(exercise.isHomeFriendly, "\(program.id): \(id) требует инвентарь")
            }
        }
    }

    func testHistoryContainsGymAndHomeSessions() {
        let history = DemoData.makeHistory()
        XCTAssertTrue(history.contains { $0.location == .gym })
        XCTAssertTrue(history.contains { $0.location == .home })
    }
}
