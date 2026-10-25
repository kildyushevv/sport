import SwiftUI

/// Воспроизводит GIF по кадрам с родными задержками. Нужен свой плеер: `Image`/`AsyncImage`
/// показывают только первый кадр, а так можно ставить на паузу.
struct ExerciseGifView: View {
    let animation: GifAnimation
    var isPlaying = true

    /// Скорость воспроизведения GIF: 1 — как в исходнике, больше 1 — быстрее.
    static let gifPlaybackSpeed = 1.4

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startDate = Date()

    var body: some View {
        if reduceMotion {
            // Без движения: один показательный кадр из середины цикла.
            frame(at: animation.frames.count / 2)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !isPlaying)) { context in
                let elapsed = context.date.timeIntervalSince(startDate) * Self.gifPlaybackSpeed
                frame(at: animation.frameIndex(at: elapsed))
            }
        }
    }

    private func frame(at index: Int) -> some View {
        let safeIndex = min(max(0, index), animation.frames.count - 1)
        return Image(uiImage: animation.frames[safeIndex])
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fit)
    }
}

/// Светлая карточка с GIF (у исходных GIF белый фон) и обязательной подписью правообладателя.
struct ExerciseGifCard: View {
    let animation: GifAnimation
    var eyebrow: String? = nil
    var title: String? = nil
    var height: CGFloat = 260
    var isPlaying = true

    private var hasHeader: Bool { eyebrow != nil || title != nil }

    var body: some View {
        let topInset: CGFloat = hasHeader ? 52 : 12
        // Исходник 180×180 px: больше 220 pt не растягиваем, иначе картинка поплывёт.
        let side = max(80, min(220, height - topInset - 24))

        ExerciseGifView(animation: animation, isPlaying: isPlaying)
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, topInset - 12)
            .frame(height: height)
            .background(Color(white: 0.97), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(alignment: .topLeading) {
                if hasHeader {
                    VStack(alignment: .leading, spacing: 2) {
                        if let eyebrow {
                            Text(eyebrow.uppercased())
                                .font(.system(size: 12, weight: .bold))
                                .tracking(1.6)
                                .foregroundStyle(Color.black.opacity(0.5))
                        }
                        if let title {
                            Text(title.uppercased())
                                .font(.sportDisplay(20))
                                .tracking(-0.3)
                                .foregroundStyle(Color.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .padding(16)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Text(ExerciseGifs.attribution)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.45))
                    .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title.map { "Анимация упражнения: \($0)" } ?? "Анимация упражнения")
    }
}

/// Демонстрация упражнения: GIF из датасета, а если его нет, нарисованная анимация.
struct ExerciseDemoCard: View {
    let exerciseID: String
    var eyebrow: String? = nil
    var title: String? = nil
    var height: CGFloat = 280
    var isPlaying = true

    /// Есть ли для упражнения хоть какая-то демонстрация.
    static func isAvailable(_ exerciseID: String) -> Bool {
        GifAnimation.load(exerciseID: exerciseID) != nil || ExerciseAnimations.motions[exerciseID] != nil
    }

    var body: some View {
        if let gif = GifAnimation.load(exerciseID: exerciseID) {
            ExerciseGifCard(animation: gif, eyebrow: eyebrow, title: title, height: height, isPlaying: isPlaying)
        } else if let motion = ExerciseAnimations.motions[exerciseID] {
            ExerciseAnimationCard(motion: motion, eyebrow: eyebrow, title: title, height: height, isPlaying: isPlaying)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ExerciseDemoCard(exerciseID: "push-up", eyebrow: "Грудь", title: "Отжимания")
        ExerciseDemoCard(exerciseID: "plank", eyebrow: "Пресс", title: "Планка")
    }
    .padding(20)
    .sportScreen()
    .preferredColorScheme(.dark)
}
