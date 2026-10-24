import SwiftUI

/// Детали домашней программы: схема интервалов и список упражнений.
struct HomeProgramView: View {
    let program: HomeProgram
    let onStart: (HomeProgram) -> Void

    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                hero

                VStack(alignment: .leading, spacing: 28) {
                    HStack(spacing: 12) {
                        StatTile(value: "\(program.durationMinutes)", label: "минут", highlighted: true)
                        StatTile(value: "≈\(program.estimatedKcal)", label: "ккал")
                        StatTile(value: "\(program.rounds)", label: "раунда")
                    }

                    scheme
                    exerciseList

                    Button("НАЧАТЬ ТРЕНИРОВКУ") {
                        onStart(program)
                    }
                    .buttonStyle(LimeButtonStyle())

                    Text("Инвентарь не нужен. Калории — ориентировочная оценка.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.sportMuted)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .top)
        .sportScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var hero: some View {
        RemotePhoto(url: program.photoURL, symbol: "figure.highintensity.intervaltraining")
            .frame(height: 380)
            .overlay(PhotoScrim())
            .overlay(alignment: .top) {
                LinearGradient(colors: [Color.black.opacity(0.7), Color.clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 120)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    Eyebrow(text: "\(program.goal) • дома")
                    Text(program.title.uppercased())
                        .font(.sportDisplay(42))
                        .tracking(-1)
                        .foregroundStyle(Color.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.6)
                    Text(program.tagline)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
                .padding(20)
            }
    }

    private var scheme: some View {
        VStack(spacing: 0) {
            row(title: "Интервал", value: program.schemeText)
            Divider().overlay(Color.sportLine)
            row(title: "Между раундами", value: "\(program.roundRestSeconds) с отдыха")
            Divider().overlay(Color.sportLine)
            HStack {
                Eyebrow(text: "Уровень", color: .sportMuted)
                Spacer()
                Text(program.level.rawValue)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.white)
                DifficultyDots(difficulty: program.level)
            }
            .padding(.vertical, 14)
            if program.lowImpact {
                Divider().overlay(Color.sportLine)
                row(title: "Нагрузка", value: "Без прыжков")
            }
        }
        .padding(.horizontal, 16)
        .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.sportLine, lineWidth: 1)
        )
    }

    private func row(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Eyebrow(text: title, color: .sportMuted)
            Spacer(minLength: 16)
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 14)
    }

    private var exerciseList: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Упражнения", trailing: "×\(program.rounds) раунда")
            VStack(spacing: 10) {
                ForEach(Array(program.exerciseIDs.enumerated()), id: \.offset) { offset, id in
                    if let exercise = store.exercise(id) {
                        NavigationLink(value: exercise) {
                            HStack(spacing: 14) {
                                Text("\(offset + 1)")
                                    .font(.sportNumber(20))
                                    .foregroundStyle(Color.sportLime)
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exercise.name)
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(Color.white)
                                        .lineLimit(2)
                                    Text("\(program.workSeconds) с • \(exercise.group.rawValue)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.sportMuted)
                                }
                                Spacer(minLength: 0)
                                RemotePhoto(url: exercise.photoURL, symbol: exercise.group.symbol)
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 14)
                            .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.sportLine, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeProgramView(program: DemoData.homePrograms[0]) { _ in }
    }
    .environment(AppStore())
    .preferredColorScheme(.dark)
}
