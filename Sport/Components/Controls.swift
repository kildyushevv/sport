import SwiftUI

/// Чип-фильтр: лаймовый, когда выбран.
struct Chip: View {
    let title: String
    var isSelected: Bool

    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(isSelected ? Color.black : Color.white)
            .padding(.vertical, 9)
            .padding(.horizontal, 16)
            .background(isSelected ? Color.sportLime : Color.sportCardRaised, in: Capsule())
    }
}

/// Сегментированный переключатель в виде капсул на всю ширину.
struct PillPicker<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    withAnimation(.easeOut(duration: 0.18)) { selection = option }
                } label: {
                    Text(label(option))
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(isSelected ? Color.black : Color.white.opacity(0.75))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isSelected ? Color.sportLime : Color.clear, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.sportCardRaised, in: Capsule())
    }
}

/// Плитка со значением и подписью.
struct StatTile: View {
    let value: String
    let label: String
    var unit: String? = nil
    var highlighted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.sportNumber(34))
                    .foregroundStyle(highlighted ? Color.black : Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if let unit {
                    Text(unit)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(highlighted ? Color.black.opacity(0.65) : Color.sportMuted)
                }
            }
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(highlighted ? Color.black.opacity(0.65) : Color.sportMuted)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            highlighted ? Color.sportLime : Color.sportCard,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(highlighted ? Color.clear : Color.sportLine, lineWidth: 1)
        )
    }
}

/// Индикатор сложности из трёх делений.
struct DifficultyDots: View {
    let difficulty: Difficulty

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...3, id: \.self) { index in
                Capsule()
                    .fill(index <= difficulty.level ? Color.sportLime : Color.white.opacity(0.2))
                    .frame(width: 14, height: 5)
            }
        }
    }
}

/// Тонкая лаймовая полоса прогресса.
struct ProgressBar: View {
    let fraction: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(Color.sportLime)
                    .frame(width: proxy.size.width * min(1, max(0, fraction)))
                    .animation(.easeOut(duration: 0.25), value: fraction)
            }
        }
        .frame(height: 6)
    }
}
