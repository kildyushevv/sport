import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(AppStore.self) private var store

    private var todayIndex: Int { AppStore.todayIndex() }
    private var isInPlan: Bool { store.isInPlan(exercise, dayIndex: todayIndex) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                hero

                VStack(alignment: .leading, spacing: 28) {
                    Text(exercise.summary)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .fixedSize(horizontal: false, vertical: true)

                    animation
                    facts
                    steps
                    tips
                    addButton
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

    @ViewBuilder
    private var animation: some View {
        if ExerciseDemoCard.isAvailable(exercise.id) {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Как выполнять")
                ExerciseDemoCard(exerciseID: exercise.id, height: 280)
            }
        }
    }

    private var hero: some View {
        RemotePhoto(url: exercise.photoURL, symbol: exercise.group.symbol)
            .frame(height: 400)
            .overlay(PhotoScrim())
            .overlay(alignment: .top) {
                LinearGradient(colors: [Color.black.opacity(0.7), Color.clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 120)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    Eyebrow(text: exercise.group.rawValue)
                    Text(exercise.name.uppercased())
                        .font(.sportDisplay(40))
                        .tracking(-1)
                        .foregroundStyle(Color.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.6)
                }
                .padding(20)
            }
    }

    private var facts: some View {
        VStack(spacing: 0) {
            factRow(title: "Инвентарь", value: exercise.equipment)
            Divider().overlay(Color.sportLine)
            factRow(title: "Также работают", value: exercise.secondary)
            Divider().overlay(Color.sportLine)
            HStack {
                Eyebrow(text: "Сложность", color: .sportMuted)
                Spacer()
                Text(exercise.difficulty.rawValue)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.white)
                DifficultyDots(difficulty: exercise.difficulty)
            }
            .padding(.vertical, 14)
        }
        .padding(.horizontal, 16)
        .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.sportLine, lineWidth: 1)
        )
    }

    private func factRow(title: String, value: String) -> some View {
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

    private var steps: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Техника")
            ForEach(Array(exercise.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 14) {
                    Text("\(index + 1)")
                        .font(.sportNumber(18))
                        .foregroundStyle(Color.black)
                        .frame(width: 34, height: 34)
                        .background(Color.sportLime, in: Circle())
                    Text(step)
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 5)
                }
            }
        }
    }

    private var tips: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Советы")
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(exercise.tips.enumerated()), id: \.offset) { _, tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.sportLime)
                            .padding(.top, 3)
                        Text(tip)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .sportCard()
        }
    }

    private var addButton: some View {
        Button {
            store.addToPlan(exercise: exercise, dayIndex: todayIndex)
        } label: {
            if isInPlan {
                Label("В плане на сегодня", systemImage: "checkmark")
            } else {
                Text("ДОБАВИТЬ В ПЛАН НА СЕГОДНЯ")
            }
        }
        .buttonStyle(LimeButtonStyle())
        .disabled(isInPlan)
        .opacity(isInPlan ? 0.6 : 1)
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(exercise: DemoData.exercises[0])
    }
    .environment(AppStore())
    .preferredColorScheme(.dark)
}
