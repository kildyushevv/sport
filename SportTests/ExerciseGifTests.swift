import XCTest
@testable import Sport

final class ExerciseGifTests: XCTestCase {

    func testFrameIndexHonorsVariableDelays() {
        // Кадры: 0 — 0,1 с; 1 — 1,0 с; 2 — 0,5 с. Цикл 1,6 с. Проверяем середины интервалов.
        let delays = [0.1, 1.0, 0.5]
        XCTAssertEqual(GifAnimation.frameIndex(delays: delays, at: 0.05), 0)
        XCTAssertEqual(GifAnimation.frameIndex(delays: delays, at: 0.6), 1)
        XCTAssertEqual(GifAnimation.frameIndex(delays: delays, at: 1.35), 2)
        // Цикл повторяется, в том числе для отрицательного времени.
        XCTAssertEqual(GifAnimation.frameIndex(delays: delays, at: 1.6 + 0.05), 0)
        XCTAssertEqual(GifAnimation.frameIndex(delays: delays, at: 1.6 * 5 + 0.6), 1)
        XCTAssertEqual(GifAnimation.frameIndex(delays: delays, at: -0.25), 2)
        XCTAssertEqual(GifAnimation.frameIndex(delays: [], at: 3), 0)
    }

    func testEveryGifDecodesFromBundle() {
        let bundle = Bundle(for: GifAnimation.self)
        XCTAssertFalse(ExerciseGifs.sources.isEmpty)

        for (id, source) in ExerciseGifs.sources {
            guard let gif = GifAnimation.load(exerciseID: id, bundle: bundle) else {
                XCTFail("GIF не найден или не декодируется: \(id) (\(source.name))")
                continue
            }
            XCTAssertGreaterThanOrEqual(gif.frames.count, 2, id)
            XCTAssertEqual(gif.frames.count, gif.delays.count, id)
            XCTAssertTrue(gif.delays.allSatisfy { $0 > 0 }, id)
            XCTAssertGreaterThan(gif.duration, 1, id)
        }
    }

    func testGifSourcesBelongToHomeExercises() {
        for id in ExerciseGifs.sources.keys {
            guard let exercise = DemoData.exercisesByID[id] else {
                XCTFail("GIF для неизвестного упражнения: \(id)")
                continue
            }
            XCTAssertTrue(exercise.isHomeFriendly, id)
        }
    }

    func testEveryHomeExerciseHasSomeDemonstration() {
        let bundle = Bundle(for: GifAnimation.self)
        for exercise in DemoData.exercises where exercise.isHomeFriendly {
            let hasGif = GifAnimation.load(exerciseID: exercise.id, bundle: bundle) != nil
            let hasDrawing = ExerciseAnimations.motions[exercise.id] != nil
            XCTAssertTrue(hasGif || hasDrawing, "Нет демонстрации: \(exercise.id)")
        }
    }

    func testAttributionIsPresent() {
        XCTAssertTrue(ExerciseGifs.attribution.contains("Gym visual"))
        XCTAssertTrue(ExerciseGifs.attribution.contains("https://gymvisual.com/"))
    }
}
