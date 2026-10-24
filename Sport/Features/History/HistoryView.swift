import SwiftUI

struct HistoryView: View {
    @Environment(AppStore.self) private var store

    private struct MonthGroup: Identifiable {
        let month: Date
        let sessions: [WorkoutSession]
        var id: Date { month }
    }

    private var months: [MonthGroup] {
        let calendar = Calendar.sport
        let grouped = Dictionary(grouping: store.history) { session in
            calendar.dateInterval(of: .month, for: session.date)?.start ?? session.date
        }
        return grouped.keys.sorted(by: >).map { month in
            MonthGroup(month: month, sessions: (grouped[month] ?? []).sorted { $0.date > $1.date })
        }
    }

    private var thisMonth: [WorkoutSession] {
        let calendar = Calendar.sport
        return store.history.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    header

                    VStack(alignment: .leading, spacing: 28) {
                        summary

                        if store.history.isEmpty {
                            emptyState
                        }

                        LazyVStack(alignment: .leading, spacing: 28) {
                            ForEach(months) { group in
                                VStack(alignment: .leading, spacing: 14) {
                                    SectionHeader(
                                        title: Format.monthYear(group.month),
                                        trailing: "\(group.sessions.count) трен."
                                    )
                                    VStack(spacing: 10) {
                                        ForEach(group.sessions) { session in
                                            NavigationLink(value: session) {
                                                SessionRow(session: session)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .ignoresSafeArea(edges: .top)
            .sportScreen()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: WorkoutSession.self) { session in
                SessionDetailView(session: session)
            }
        }
    }

    private var header: some View {
        RemotePhoto(url: PhotoCatalog.url(.history), symbol: "clock.arrow.circlepath")
            .frame(height: 230)
            .overlay(PhotoScrim())
            .overlay(alignment: .bottomLeading) {
                ScreenTitle(title: "История", subtitle: "\(store.history.count) тренировок за всё время")
                    .padding(20)
            }
    }

    private var summary: some View {
        let minutes = thisMonth.reduce(0) { $0 + $1.durationMinutes }
        let volume = thisMonth.reduce(0.0) { $0 + Analytics.volume(of: $1) }

        return VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Этот месяц")
            HStack(spacing: 12) {
                StatTile(value: "\(thisMonth.count)", label: "тренировок", highlighted: true)
                StatTile(value: Format.number(Double(minutes) / 60), label: "часов")
                StatTile(value: Format.number((volume / 1000 * 10).rounded() / 10), label: "тонн")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color.sportLime.opacity(0.6))
            Text("Пока пусто")
                .font(.sportDisplay(22))
                .foregroundStyle(Color.white)
            Text("Завершите первую тренировку — она появится здесь.")
                .font(.system(size: 15))
                .foregroundStyle(Color.sportMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

private struct SessionRow: View {
    let session: WorkoutSession

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 0) {
                Text("\(Calendar.sport.component(.day, from: session.date))")
                    .font(.sportNumber(28))
                    .foregroundStyle(Color.sportLime)
                Text(Format.weekdayShort(session.date).uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Color.sportMuted)
            }
            .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.title.uppercased())
                    .font(.sportDisplay(18))
                    .tracking(-0.3)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(Format.duration(minutes: session.durationMinutes)) • \(Format.number(Analytics.volume(of: session))) кг")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.sportMuted)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)

            RemotePhoto(url: session.photoURL, symbol: "figure.strengthtraining.traditional")
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(10)
        .padding(.leading, 4)
        .background(Color.sportCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.sportLine, lineWidth: 1)
        )
    }
}

#Preview {
    HistoryView()
        .environment(AppStore())
        .preferredColorScheme(.dark)
}
