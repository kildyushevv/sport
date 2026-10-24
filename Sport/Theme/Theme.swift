import SwiftUI

// MARK: - Цвета

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    static let sportBackground = Color.black
    static let sportCard = Color(hex: 0x121212)
    static let sportCardRaised = Color(hex: 0x1C1C1E)
    static let sportLime = Color(hex: 0xC6FF00)
    static let sportMuted = Color.white.opacity(0.6)
    static let sportLine = Color.white.opacity(0.12)
}

// MARK: - Шрифты

extension Font {
    /// Крупные заголовки: плотный чёрный гротеск.
    static func sportDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black)
    }

    /// Цифры таймера и статистики: округлые, моноширинные.
    static func sportNumber(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded).monospacedDigit()
    }
}

// MARK: - Базовые элементы текста

/// Крупный заголовок экрана с подзаголовком.
struct ScreenTitle: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let subtitle {
                Eyebrow(text: subtitle)
            }
            Text(title.uppercased())
                .font(.sportDisplay(48))
                .tracking(-1)
                .foregroundStyle(Color.white)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Маленькая подпись капслоком, по умолчанию лаймовая.
struct Eyebrow: View {
    let text: String
    var color: Color = .sportLime

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .bold))
            .tracking(1.6)
            .foregroundStyle(color)
    }
}

/// Заголовок секции с необязательным действием справа.
struct SectionHeader: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title.uppercased())
                .font(.sportDisplay(22))
                .tracking(-0.3)
                .foregroundStyle(Color.white)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.sportMuted)
            }
        }
    }
}

// MARK: - Кнопки

struct LimeButtonStyle: ButtonStyle {
    var compact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: compact ? 15 : 18, weight: .heavy))
            .tracking(0.6)
            .foregroundStyle(Color.black)
            .padding(.vertical, compact ? 10 : 17)
            .padding(.horizontal, compact ? 18 : 24)
            .frame(maxWidth: compact ? nil : .infinity)
            .background(Color.sportLime, in: Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    var compact = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: compact ? 15 : 18, weight: .heavy))
            .tracking(0.6)
            .foregroundStyle(Color.white)
            .padding(.vertical, compact ? 10 : 17)
            .padding(.horizontal, compact ? 18 : 24)
            .frame(maxWidth: compact ? nil : .infinity)
            .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1.5))
            .opacity(configuration.isPressed ? 0.6 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Модификаторы

extension View {
    /// Фон экрана — чёрный, на всю область, включая безопасные зоны.
    func sportScreen() -> some View {
        background(Color.sportBackground.ignoresSafeArea())
    }

    /// Тёмная скруглённая карточка.
    func sportCard(padding: CGFloat = 16, radius: CGFloat = 20) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.sportCard, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.sportLine, lineWidth: 1)
            )
    }
}

// MARK: - Форматирование

enum Format {
    private static let ruLocale = Locale(identifier: "ru_RU")

    private static func makeFormatter(_ template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = ruLocale
        formatter.calendar = .sport
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter
    }

    private static let dayMonthFormatter = makeFormatter("d MMMM")
    private static let dayMonthShortFormatter = makeFormatter("d MMM")
    private static let weekdayShortFormatter = makeFormatter("EEE")
    private static let monthYearFormatter = makeFormatter("LLLL yyyy")
    private static let timeFormatter = makeFormatter("HH:mm")

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = ruLocale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter
    }()

    static func dayMonth(_ date: Date) -> String { dayMonthFormatter.string(from: date) }
    static func dayMonthShort(_ date: Date) -> String { dayMonthShortFormatter.string(from: date) }
    static func weekdayShort(_ date: Date) -> String { weekdayShortFormatter.string(from: date) }
    static func time(_ date: Date) -> String { timeFormatter.string(from: date) }

    static func monthYear(_ date: Date) -> String {
        monthYearFormatter.string(from: date).capitalized(with: ruLocale)
    }

    /// 12 450 или 82,5 — без лишних нулей, с разделителем тысяч.
    static func number(_ value: Double) -> String {
        numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func kilograms(_ value: Double) -> String {
        "\(number(value)) кг"
    }

    private static func twoDigits(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }

    /// 1 ч 05 мин / 45 мин
    static func duration(minutes: Int) -> String {
        guard minutes >= 60 else { return "\(minutes) мин" }
        return "\(minutes / 60) ч \(twoDigits(minutes % 60)) мин"
    }

    /// 03:25 — для таймера и обратного отсчёта.
    static func clock(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded(.up)))
        return "\(twoDigits(total / 60)):\(twoDigits(total % 60))"
    }

    /// 03:25.4 — для секундомера.
    static func stopwatch(_ seconds: TimeInterval) -> String {
        let clamped = max(0, seconds)
        let total = Int(clamped)
        let tenths = Int((clamped - Double(total)) * 10)
        return "\(twoDigits(total / 60)):\(twoDigits(total % 60)).\(tenths)"
    }

    /// «4 × 8 • 80 кг» или «4 × 60 с».
    static func setSummary(sets: Int, target: Int, weight: Double, measure: Measure) -> String {
        var text = "\(sets) × \(measure.format(target))"
        if weight > 0 { text += " • \(kilograms(weight))" }
        return text
    }
}
