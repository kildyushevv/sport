import SwiftUI

/// Анимированная фигура, показывающая технику упражнения, с подписью текущей фазы.
struct ExerciseAnimationView: View {
    let motion: ExerciseMotion
    var isPlaying = true
    /// Свободное место под заголовок поверх анимации.
    var topInset: CGFloat = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startDate = Date()

    private let stepSeconds = 1.6

    /// Скорость воспроизведения: 1 — как заданы длительности поз, меньше 1 — медленнее.
    static let playbackSpeed = 0.65

    var body: some View {
        if reduceMotion {
            // Без плавного движения: ключевые позы сменяют друг друга по таймеру.
            TimelineView(.periodic(from: startDate, by: stepSeconds)) { context in
                let step = Int(max(0, context.date.timeIntervalSince(startDate)) / stepSeconds)
                let index = motion.keys.isEmpty ? 0 : step % motion.keys.count
                content(time: motion.startTime(ofKey: index))
            }
        } else {
            TimelineView(.animation(minimumInterval: nil, paused: !isPlaying)) { context in
                content(time: context.date.timeIntervalSince(startDate) * Self.playbackSpeed)
            }
        }
    }

    private func content(time: Double) -> some View {
        let sample = motion.sample(at: time)
        let captionHeight: CGFloat = 54

        return ZStack(alignment: .bottom) {
            Canvas { context, size in
                let area = CGRect(
                    x: 0, y: topInset,
                    width: size.width, height: max(1, size.height - topInset - captionHeight)
                )
                FigureRenderer.draw(in: context, area: area, motion: motion, pose: sample.pose)
            }

            VStack(spacing: 8) {
                Text(motion.keys.indices.contains(sample.index) ? motion.keys[sample.index].caption : "")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(height: 22)

                HStack(spacing: 5) {
                    ForEach(motion.keys.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == sample.index ? Color.sportLime : Color.white.opacity(0.2))
                            .frame(width: index == sample.index ? 18 : 6, height: 5)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }
}

/// Карточка с анимацией: тёмный фон, необязательный заголовок в углу.
struct ExerciseAnimationCard: View {
    let motion: ExerciseMotion
    var eyebrow: String? = nil
    var title: String? = nil
    var height: CGFloat = 260
    var isPlaying = true

    private var hasHeader: Bool { eyebrow != nil || title != nil }

    var body: some View {
        ExerciseAnimationView(motion: motion, isPlaying: isPlaying, topInset: hasHeader ? 52 : 8)
            .frame(height: height)
            .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(alignment: .topLeading) {
                if hasHeader {
                    VStack(alignment: .leading, spacing: 2) {
                        if let eyebrow {
                            Eyebrow(text: eyebrow)
                        }
                        if let title {
                            Text(title.uppercased())
                                .font(.sportDisplay(20))
                                .tracking(-0.3)
                                .foregroundStyle(Color.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .padding(16)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.sportLine, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title.map { "Анимация упражнения: \($0)" } ?? "Анимация упражнения")
    }
}

/// Рисует фигуру в заданной области.
enum FigureRenderer {
    private static let farLimb = Color.sportLime.opacity(0.42)
    private static let body = Color.white.opacity(0.92)

    static func draw(in context: GraphicsContext, area: CGRect, motion: ExerciseMotion, pose: Pose) {
        let bounds = motion.bounds
        let padding: CGFloat = 14
        let usableWidth = max(1, area.width - padding * 2)
        let usableHeight = max(1, area.height - padding * 2)
        let scale = min(usableWidth / CGFloat(bounds.width), usableHeight / CGFloat(bounds.height))

        // Центрируем область движения в доступном прямоугольнике.
        let centerX = CGFloat(bounds.minX + bounds.maxX) / 2
        let centerY = CGFloat(bounds.minY + bounds.maxY) / 2
        let originX = area.midX - centerX * scale
        let originY = area.midY - centerY * scale

        func screen(_ point: FigurePoint) -> CGPoint {
            CGPoint(x: originX + CGFloat(point.x) * scale, y: originY + CGFloat(point.y) * scale)
        }

        let skeleton = FigureGeometry.skeleton(for: pose, camera: motion.camera, anchor: motion.anchor)
        let floorY = originY

        // Пол и тень.
        var floor = Path()
        floor.move(to: CGPoint(x: area.minX + padding, y: floorY))
        floor.addLine(to: CGPoint(x: area.maxX - padding, y: floorY))
        context.stroke(floor, with: .color(Color.white.opacity(0.14)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))

        let shadowWidth: CGFloat = 0.30 * scale * max(0.4, 1 - CGFloat(pose.air) * 2.5)
        let shadowCenter = screen(skeleton.hip)
        let shadow = Path(ellipseIn: CGRect(
            x: shadowCenter.x - shadowWidth / 2, y: floorY - 2, width: shadowWidth, height: 4
        ))
        context.fill(shadow, with: .color(Color.white.opacity(0.08)))

        let limbStyle = StrokeStyle(lineWidth: CGFloat(FigureGeometry.limbWidth) * scale, lineCap: .round, lineJoin: .round)
        let torsoStyle = StrokeStyle(lineWidth: CGFloat(FigureGeometry.torsoWidth) * scale, lineCap: .round, lineJoin: .round)

        func line(_ points: [FigurePoint]) -> Path {
            var path = Path()
            guard let first = points.first else { return path }
            path.move(to: screen(first))
            for point in points.dropFirst() {
                path.addLine(to: screen(point))
            }
            return path
        }

        // Дальние конечности, торс, голова, ближние конечности.
        context.stroke(line(skeleton.armFar), with: .color(farLimb), style: limbStyle)
        context.stroke(line(skeleton.legFar), with: .color(farLimb), style: limbStyle)
        context.stroke(line([skeleton.hip, skeleton.mid, skeleton.neck]), with: .color(body), style: torsoStyle)

        let headCenter = screen(skeleton.head)
        let headRadius = CGFloat(FigureGeometry.headRadius) * scale
        context.fill(
            Path(ellipseIn: CGRect(
                x: headCenter.x - headRadius, y: headCenter.y - headRadius,
                width: headRadius * 2, height: headRadius * 2
            )),
            with: .color(body)
        )

        context.stroke(line(skeleton.legNear), with: .color(Color.sportLime), style: limbStyle)
        context.stroke(line(skeleton.armNear), with: .color(Color.sportLime), style: limbStyle)
    }
}

#Preview {
    if let motion = ExerciseAnimations.motions["air-squat"] {
        ExerciseAnimationCard(motion: motion, eyebrow: "Ноги", title: "Приседания без веса")
            .padding(20)
            .sportScreen()
            .preferredColorScheme(.dark)
    }
}
