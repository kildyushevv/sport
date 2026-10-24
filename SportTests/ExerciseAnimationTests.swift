import XCTest
@testable import Sport

final class ExerciseAnimationTests: XCTestCase {

    func testEveryHomeExerciseHasAnimation() {
        for exercise in DemoData.exercises where exercise.isHomeFriendly {
            XCTAssertNotNil(ExerciseAnimations.motions[exercise.id], "Нет анимации: \(exercise.id)")
        }
    }

    func testAnimationsBelongToKnownExercises() {
        for id in ExerciseAnimations.motions.keys {
            XCTAssertNotNil(DemoData.exercisesByID[id], "Анимация для неизвестного упражнения: \(id)")
        }
    }

    func testKeyframesAreValid() {
        for (id, motion) in ExerciseAnimations.motions {
            XCTAssertGreaterThanOrEqual(motion.keys.count, 2, id)
            XCTAssertGreaterThan(motion.period, 0.5, id)
            for key in motion.keys {
                XCTAssertGreaterThan(key.seconds, 0, id)
            }
        }
    }

    func testSampleLoopsBackToFirstPose() {
        for (id, motion) in ExerciseAnimations.motions {
            let start = motion.sample(at: 0)
            XCTAssertEqual(start.index, 0, id)
            XCTAssertEqual(start.pose, motion.keys[0].pose, id)

            let wrapped = motion.sample(at: motion.period)
            XCTAssertEqual(wrapped.pose.torso, motion.keys[0].pose.torso, accuracy: 0.001, id)
            XCTAssertEqual(wrapped.pose.ln1, motion.keys[0].pose.ln1, accuracy: 0.001, id)

            // Отрицательное время тоже даёт корректную позу.
            XCTAssertEqual(motion.sample(at: -motion.period).index, 0, id)
        }
    }

    func testSkeletonStaysInsideBoundsAndOnFloor() {
        for (id, motion) in ExerciseAnimations.motions {
            for step in 0..<40 {
                let time = motion.period * Double(step) / 40
                let pose = motion.sample(at: time).pose
                let skeleton = FigureGeometry.skeleton(for: pose, camera: motion.camera, anchor: motion.anchor)
                for point in skeleton.allPoints {
                    XCTAssertTrue(point.x.isFinite && point.y.isFinite, id)
                    XCTAssertGreaterThanOrEqual(point.x, motion.bounds.minX - 0.03, id)
                    XCTAssertLessThanOrEqual(point.x, motion.bounds.maxX + 0.03, id)
                    XCTAssertGreaterThanOrEqual(point.y, motion.bounds.minY - 0.03, id)
                    // Ниже пола фигура не уходит.
                    XCTAssertLessThanOrEqual(point.y, 0.001, id)
                }
            }
        }
    }

    /// Эталонные значения посчитаны в tools/anim_core.py: Swift-геометрия должна с ними совпадать.
    func testGeometryMatchesPythonReference() {
        let pose = Pose(
            torso: 30, head: 10, spine: 12, an1: 90, an2: 45, af1: 20, af2: 10,
            ln1: 20, ln2: -10, lf1: -15, lf2: -30, fn: 70, ff: 80, air: 0.05, x: 0.1
        )

        let side = FigureGeometry.skeleton(for: pose, camera: .side, anchor: .footN)
        assertPoint(side.hip, -0.0045, -0.5386)
        assertPoint(side.neck, 0.1447, -0.7970)
        assertPoint(side.head, 0.1993, -0.8621)
        assertPoint(side.armNear[2], 0.3937, -0.6980)
        assertPoint(side.armFar[2], 0.2203, -0.5181)
        assertPoint(side.legNear[3], 0.1000, -0.0720)
        assertPoint(side.legFar[3], -0.1101, -0.1051)

        let front = FigureGeometry.skeleton(for: pose, camera: .front, anchor: .none)
        assertPoint(front.hip, 0.1000, -0.5396)
        assertPoint(front.neck, 0.2492, -0.7980)
        assertPoint(front.head, 0.3038, -0.8631)
        assertPoint(front.armNear[2], 0.5761, -0.6540)
        assertPoint(front.armFar[2], 0.2468, -0.5642)
        assertPoint(front.legNear[3], 0.1820, -0.0720)
        assertPoint(front.legFar[3], -0.1178, -0.1433)
    }

    private func assertPoint(_ point: FigurePoint, _ x: Double, _ y: Double,
                             file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(point.x, x, accuracy: 0.001, file: file, line: line)
        XCTAssertEqual(point.y, y, accuracy: 0.001, file: file, line: line)
    }
}
