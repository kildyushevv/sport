import SwiftUI

/// Содержимое режима «Дома» на вкладке «План».
struct HomePlanView: View {
    let onStart: (HomeProgram) -> Void

    @Environment(AppStore.self) private var store

    private var weekStart: Date {
        Calendar.sport.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            weekCard

            if let recommended = store.recommendedHomeProgram() {
                recommendedCard(recommended)
            }

            allPrograms
        }
    }

    // MARK: Неделя

    private var weekCard: some View {
        let sessions = store.homeSessions(since: weekStart)
        let minutes = sessions.reduce(0) { $0 + $1.durationMinutes }
        let kcal = sessions.reduce(0) { $0 + $1.calories }

        return VStack(alignment: .leading, spacing: 12) {
            Eyebrow(text: "Дома на этой неделе", color: .sportMuted)
            HStack(spacing: 12) {
                StatTile(value: "\(sessions.count)", label: "тренировок", highlighted: true)
                StatTile(value: "\(minutes)", label: "минут")
                StatTile(value: "\(kcal)", label: "ккал")
            }
        }
    }

    // MARK: Рекомендация

    private func recommendedCard(_ program: HomeProgram) -> some View {
        VStack(spacing: 14) {
            NavigationLink(value: program) {
                PhotoCard(
                    url: program.photoURL,
                    symbol: "figure.highintensity.intervaltraining",
                    eyebrow: "Рекомендуем сегодня",
                    title: program.title,
                    detail: "\(program.durationMinutes) мин • ≈\(program.estimatedKcal) ккал • \(program.level.rawValue)",
                    height: 320,
                    titleSize: 34
                )
            }
            .buttonStyle(.plain)

            Button("НАЧАТЬ ТРЕНИРОВКУ") {
                onStart(program)
            }
            .buttonStyle(LimeButtonStyle())
        }
    }

    // MARK: Все программы

    private var allPrograms: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Все программы", trailing: "\(store.homePrograms.count)")
            VStack(spacing: 10) {
                ForEach(store.homePrograms) { program in
                    NavigationLink(value: program) {
                        ProgramRow(program: program)
                    }
                    .buttonStyle(.plain)
                }
            }
            Text("Без инвентаря: только вес тела. Калории — ориентировочная оценка, не измерение.")
                .font(.system(size: 13))
                .foregroundStyle(Color.sportMuted)
        }
    }
}

private struct ProgramRow: View {
    let program: HomeProgram

    var body: some View {
        HStack(spacing: 14) {
            RemotePhoto(url: program.photoURL, symbol: "figure.highintensity.intervaltraining")
                .frame(width: 72, height: 72)
                .overlay(Color.black.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: program.lowImpact ? "\(program.goal) • без прыжков" : program.goal)
                Text(program.title.uppercased())
                    .font(.sportDisplay(19))
                    .tracking(-0.3)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(program.durationMinutes) мин • ≈\(program.estimatedKcal) ккал • \(program.level.rawValue)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.sportMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.sportMuted)
        }
        .padding(10)
        .padding(.trailing, 6)
        .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.sportLine, lineWidth: 1)
        )
    }
}

#Preview {
    ScrollView {
        HomePlanView { _ in }
            .padding(20)
    }
    .sportScreen()
    .environment(AppStore())
    .preferredColorScheme(.dark)
}
