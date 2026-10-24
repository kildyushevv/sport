import Foundation

// Модель анимации упражнения: поза задаётся углами суставов, фигура строится прямой кинематикой.
// Математика зеркально повторяет tools/anim_core.py — менять нужно в обоих местах.
//
// Углы в градусах. Для конечностей: 0 — вниз, +90 — вперёд (вправо).
// Для торса: 0 — вертикально вверх, +90 — горизонтально вправо.

struct Pose: Hashable {
    var torso = 0.0
    /// Наклон головы относительно торса.
    var head = 0.0
    /// Изгиб позвоночника: > 0 — спина выгнута вверх, < 0 — прогиб.
    var spine = 0.0
    // Ближние и дальние руки: плечо и предплечье (абсолютные углы).
    var an1 = 0.0
    var an2 = 0.0
    var af1 = 0.0
    var af2 = 0.0
    // Ближняя и дальняя ноги: бедро и голень (абсолютные углы).
    var ln1 = 0.0
    var ln2 = 0.0
    var lf1 = 0.0
    var lf2 = 0.0
    // Углы стоп.
    var fn = 90.0
    var ff = 90.0
    /// Отрыв от пола в долях роста (прыжки).
    var air = 0.0
    /// Сдвиг по горизонтали.
    var x = 0.0

    func lerped(to other: Pose, _ t: Double) -> Pose {
        func mix(_ a: Double, _ b: Double) -> Double { a + (b - a) * t }
        return Pose(
            torso: mix(torso, other.torso), head: mix(head, other.head), spine: mix(spine, other.spine),
            an1: mix(an1, other.an1), an2: mix(an2, other.an2),
            af1: mix(af1, other.af1), af2: mix(af2, other.af2),
            ln1: mix(ln1, other.ln1), ln2: mix(ln2, other.ln2),
            lf1: mix(lf1, other.lf1), lf2: mix(lf2, other.lf2),
            fn: mix(fn, other.fn), ff: mix(ff, other.ff),
            air: mix(air, other.air), x: mix(x, other.x)
        )
    }
}

enum MotionCamera {
    case side
    case front
}

/// Какая точка остаётся неподвижной по горизонтали (стопа или ладонь на полу).
enum MotionAnchor {
    case none
    case footN
    case footF
    case handN
}

struct MotionBounds: Hashable {
    let minX: Double
    let maxX: Double
    let minY: Double
    let maxY: Double

    var width: Double { maxX - minX }
    var height: Double { maxY - minY }
}

struct MotionKey: Hashable {
    let pose: Pose
    /// Сколько секунд занимает переход от этой позы к следующей.
    let seconds: Double
    /// Подсказка, пока идёт переход от этой позы к следующей.
    let caption: String

    init(_ pose: Pose, seconds: Double, caption: String) {
        self.pose = pose
        self.seconds = seconds
        self.caption = caption
    }
}

struct ExerciseMotion: Hashable {
    let camera: MotionCamera
    let anchor: MotionAnchor
    let bounds: MotionBounds
    let keys: [MotionKey]

    /// Длительность полного цикла (после последней позы идёт возврат к первой).
    var period: Double {
        keys.reduce(0) { $0 + $1.seconds }
    }

    /// Поза в момент `time` (секунды, цикл повторяется) и индекс текущего перехода.
    func sample(at time: Double) -> (pose: Pose, index: Int) {
        guard let first = keys.first else { return (Pose(), 0) }
        let total = period
        guard total > 0 else { return (first.pose, 0) }

        var t = time.truncatingRemainder(dividingBy: total)
        if t < 0 { t += total }

        for (index, key) in keys.enumerated() {
            if t < key.seconds || index == keys.count - 1 {
                let next = keys[(index + 1) % keys.count]
                let u = min(1, max(0, t / key.seconds))
                let eased = u * u * (3 - 2 * u)
                return (key.pose.lerped(to: next.pose, eased), index)
            }
            t -= key.seconds
        }
        return (first.pose, 0)
    }

    /// Время начала перехода с указанным индексом.
    func startTime(ofKey index: Int) -> Double {
        keys.prefix(index).reduce(0) { $0 + $1.seconds }
    }
}

// MARK: - Геометрия фигуры

struct FigurePoint: Hashable {
    var x: Double
    var y: Double
}

struct FigureSkeleton {
    var hip: FigurePoint
    var mid: FigurePoint
    var neck: FigurePoint
    var head: FigurePoint
    /// Плечо, локоть, кисть.
    var armNear: [FigurePoint]
    var armFar: [FigurePoint]
    /// Таз, колено, лодыжка, носок.
    var legNear: [FigurePoint]
    var legFar: [FigurePoint]

    var allPoints: [FigurePoint] {
        let r = FigureGeometry.headRadius
        var result = [
            hip, mid, neck,
            FigurePoint(x: head.x, y: head.y + r),
            FigurePoint(x: head.x, y: head.y - r),
        ]
        result += armNear
        result += armFar
        result += legNear
        result += legFar
        return result
    }

    func shifted(dx: Double, dy: Double) -> FigureSkeleton {
        func move(_ p: FigurePoint) -> FigurePoint { FigurePoint(x: p.x + dx, y: p.y + dy) }
        return FigureSkeleton(
            hip: move(hip), mid: move(mid), neck: move(neck), head: move(head),
            armNear: armNear.map(move), armFar: armFar.map(move),
            legNear: legNear.map(move), legFar: legFar.map(move)
        )
    }
}

enum FigureGeometry {
    static let torso = 0.30
    static let headDistance = 0.085
    static let headRadius = 0.055
    static let upperArm = 0.15
    static let forearm = 0.14
    static let thigh = 0.23
    static let shank = 0.23
    static let foot = 0.07
    static let shoulderHalf = 0.09
    static let hipHalf = 0.05
    static let limbWidth = 0.044
    static let torsoWidth = 0.085

    private static func radians(_ degrees: Double) -> Double {
        degrees * Double.pi / 180
    }

    /// Единичный вектор конечности: 0° — вниз, +90° — вправо.
    private static func limbDirection(_ degrees: Double) -> FigurePoint {
        FigurePoint(x: sin(radians(degrees)), y: cos(radians(degrees)))
    }

    /// Единичный вектор торса: 0° — вверх, +90° — вправо.
    private static func torsoDirection(_ degrees: Double) -> FigurePoint {
        FigurePoint(x: sin(radians(degrees)), y: -cos(radians(degrees)))
    }

    private static func advance(_ p: FigurePoint, _ direction: FigurePoint, _ length: Double) -> FigurePoint {
        FigurePoint(x: p.x + direction.x * length, y: p.y + direction.y * length)
    }

    /// Скелет относительно таза (таз в нуле), без привязки к полу.
    static func rawSkeleton(for pose: Pose, camera: MotionCamera) -> FigureSkeleton {
        let hip = FigurePoint(x: 0, y: 0)
        let mid = advance(hip, torsoDirection(pose.torso - pose.spine / 2), torso / 2)
        let neck = advance(mid, torsoDirection(pose.torso + pose.spine / 2), torso / 2)
        let head = advance(neck, torsoDirection(pose.torso + pose.head), headDistance)

        let shoulderNear: FigurePoint
        let shoulderFar: FigurePoint
        let hipNear: FigurePoint
        let hipFar: FigurePoint
        switch camera {
        case .front:
            let perpendicular = FigurePoint(x: cos(radians(pose.torso)), y: sin(radians(pose.torso)))
            shoulderNear = advance(neck, perpendicular, shoulderHalf)
            shoulderFar = advance(neck, perpendicular, -shoulderHalf)
            hipNear = advance(hip, perpendicular, hipHalf)
            hipFar = advance(hip, perpendicular, -hipHalf)
        case .side:
            shoulderNear = neck
            shoulderFar = neck
            hipNear = hip
            hipFar = hip
        }

        func armChain(_ shoulder: FigurePoint, _ upper: Double, _ lower: Double) -> [FigurePoint] {
            let elbow = advance(shoulder, limbDirection(upper), upperArm)
            let hand = advance(elbow, limbDirection(lower), forearm)
            return [shoulder, elbow, hand]
        }

        func legChain(_ hipPoint: FigurePoint, _ upper: Double, _ lower: Double, _ footAngle: Double) -> [FigurePoint] {
            let knee = advance(hipPoint, limbDirection(upper), thigh)
            let ankle = advance(knee, limbDirection(lower), shank)
            let toe = camera == .side ? advance(ankle, limbDirection(footAngle), foot) : ankle
            return [hipPoint, knee, ankle, toe]
        }

        return FigureSkeleton(
            hip: hip, mid: mid, neck: neck, head: head,
            armNear: armChain(shoulderNear, pose.an1, pose.an2),
            armFar: armChain(shoulderFar, pose.af1, pose.af2),
            legNear: legChain(hipNear, pose.ln1, pose.ln2, pose.fn),
            legFar: legChain(hipFar, pose.lf1, pose.lf2, pose.ff)
        )
    }

    /// Скелет в «мировых» координатах: пол — y = 0, вверх — отрицательные y,
    /// якорная точка стоит на месте по x.
    static func skeleton(for pose: Pose, camera: MotionCamera, anchor: MotionAnchor) -> FigureSkeleton {
        let raw = rawSkeleton(for: pose, camera: camera)

        let limbLow = (raw.allPoints.map(\.y).max() ?? 0) + limbWidth / 2
        let torsoLow = max(raw.hip.y, raw.mid.y, raw.neck.y) + torsoWidth / 2
        let low = max(limbLow, torsoLow)

        var anchorX = 0.0
        switch anchor {
        case .footN: anchorX = raw.legNear[3].x
        case .footF: anchorX = raw.legFar[3].x
        case .handN: anchorX = raw.armNear[2].x
        case .none: anchorX = 0
        }

        return raw.shifted(dx: -anchorX + pose.x, dy: -low - pose.air)
    }
}
