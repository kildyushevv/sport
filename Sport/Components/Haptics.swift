import UIKit

/// Вибро-отклик для событий таймера.
enum Haptics {
    static func play(_ event: TimerEvent) {
        switch event {
        case .started:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .countdown:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .segmentChanged:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .finished:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
