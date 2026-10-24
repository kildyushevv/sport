import SwiftUI

/// Состав тренировки одного дня плана.
struct WorkoutDayView: View {
    let dayIndex: Int
    let onStart: (WorkoutDay) -> Void

    @Environment(AppStore.self) private var store

    private var day: WorkoutDay? {
        store.plan.first { $0.weekdayIndex == dayIndex }
    }

    var body: some View {
        ScrollView {
            if let day {
                VStack(alignment: .leading, spacing: 28) {
                    hero(day)

                    VStack(alignment: .leading, spacing: 28) {
                        metrics(day)
                        exerciseList(day)

                        Button("НАЧАТЬ ТРЕНИРОВКУ") {
                            onStart(day)
                        }
                        .buttonStyle(LimeButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .sportScreen()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func hero(_ day: WorkoutDay) -> some View {
        RemotePhoto(url: day.photoURL, symbol: "figure.strengthtraining.traditional")
            .frame(height: 380)
            .overlay(PhotoScrim())
            .overlay(alignment: .top) {
                LinearGradient(colors: [Color.black.opacity(0.7), Color.clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 120)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    Eyebrow(text: Weekday.full[day.weekdayIndex])
                    Text(day.title.uppercased())
                        .font(.sportDisplay(42))
                        .tracking(-1)
                        .foregroundStyle(Color.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.6)
                    Text(day.focus)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
                .padding(20)
            }
    }

    private func metrics(_ day: WorkoutDay) -> some View {
        let sets = day.items.reduce(0) { $0 + $1.sets }
        return HStack(spacing: 12) {
            StatTile(value: "\(day.durationMinutes)", label: "минут")
            StatTile(value: "\(day.items.count)", label: "упражнений")
            StatTile(value: "\(sets)", label: "подходов", highlighted: true)
        }
    }

    private func exerciseList(_ day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "Упражнения")
            VStack(spacing: 10) {
                ForEach(Array(day.items.enumerated()), id: \.element.id) { offset, item in
                    if let exercise = store.exercise(item.exerciseID) {
                        NavigationLink(value: exercise) {
                            PlannedRow(number: offset + 1, exercise: exercise, item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct PlannedRow: View {
    let number: Int
    let exercise: Exercise
    let item: PlannedExercise

    var body: some View {
        HStack(spacing: 14) {
            Text("\(number)")
                .font(.sportNumber(20))
                .foregroundStyle(Color.sportLime)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                Text(Format.setSummary(sets: item.sets, target: item.target, weight: item.weight, measure: exercise.measure))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.sportMuted)
                Text("Отдых \(item.restSeconds) с")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.sportMuted.opacity(0.8))
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
}

#Preview {
    NavigationStack {
        WorkoutDayView(dayIndex: 0) { _ in }
    }
    .environment(AppStore())
    .preferredColorScheme(.dark)
}
