import SwiftUI

struct SessionDetailView: View {
    let session: WorkoutSession
    @Environment(AppStore.self) private var store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                hero

                VStack(alignment: .leading, spacing: 28) {
                    HStack(spacing: 12) {
                        StatTile(value: "\(session.durationMinutes)", label: "минут", highlighted: true)
                        StatTile(value: "\(session.calories)", label: "ккал")
                        if session.location == .home {
                            StatTile(value: "\(session.totalSets)", label: "интервалов")
                        } else {
                            StatTile(value: Format.number(Analytics.volume(of: session)), label: "объём, кг")
                        }
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader(title: "Упражнения", trailing: "\(session.totalSets) подходов")
                        VStack(spacing: 10) {
                            ForEach(session.exercises) { logged in
                                if let exercise = store.exercise(logged.exerciseID) {
                                    ExerciseLogCard(exercise: exercise, logged: logged)
                                }
                            }
                        }
                    }
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
        RemotePhoto(url: session.photoURL, symbol: "figure.strengthtraining.traditional")
            .frame(height: 340)
            .overlay(PhotoScrim())
            .overlay(alignment: .top) {
                LinearGradient(colors: [Color.black.opacity(0.7), Color.clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 120)
                    .allowsHitTesting(false)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 8) {
                    Eyebrow(text: "\(Format.dayMonth(session.date)) • \(Format.time(session.date))")
                    Text(session.title.uppercased())
                        .font(.sportDisplay(40))
                        .tracking(-1)
                        .foregroundStyle(Color.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.6)
                    Text(session.focus)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
                .padding(20)
            }
    }
}

private struct ExerciseLogCard: View {
    let exercise: Exercise
    let logged: LoggedExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.white)
                Spacer()
                Eyebrow(text: exercise.group.rawValue, color: .sportMuted)
            }
            VStack(spacing: 0) {
                ForEach(Array(logged.sets.enumerated()), id: \.offset) { offset, set in
                    HStack {
                        Text("\(offset + 1)")
                            .font(.sportNumber(16))
                            .foregroundStyle(Color.sportLime)
                            .frame(width: 28, alignment: .leading)
                        Text((logged.measureOverride ?? exercise.measure).format(set.value))
                            .font(.sportNumber(16))
                            .foregroundStyle(Color.white)
                        Spacer()
                        if set.weight > 0 {
                            Text(Format.kilograms(set.weight))
                                .font(.sportNumber(16))
                                .foregroundStyle(Color.sportMuted)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .sportCard()
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: DemoData.makeHistory().first ?? WorkoutSession(
            id: UUID(), date: .now, title: "Тест", focus: "", durationMinutes: 60, calories: 400,
            photo: .hero, exercises: []
        ))
    }
    .environment(AppStore())
    .preferredColorScheme(.dark)
}
