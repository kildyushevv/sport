import SwiftUI

struct CatalogView: View {
    @Environment(AppStore.self) private var store
    @State private var query = ""
    @State private var group: MuscleGroup? = nil
    @State private var homeOnly = false

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    private var filtered: [Exercise] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return store.exercises.filter { exercise in
            let matchesGroup = group == nil || exercise.group == group
            let matchesHome = !homeOnly || exercise.isHomeFriendly
            let matchesQuery = needle.isEmpty
                || exercise.name.lowercased().contains(needle)
                || exercise.equipment.lowercased().contains(needle)
                || exercise.secondary.lowercased().contains(needle)
            return matchesGroup && matchesHome && matchesQuery
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenTitle(title: "Каталог", subtitle: "\(store.exercises.count) упражнений")
                    searchField
                    groupChips

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filtered) { exercise in
                            NavigationLink(value: exercise) {
                                ExerciseTile(exercise: exercise)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if filtered.isEmpty {
                        emptyState
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .sportScreen()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.sportMuted)
            TextField("Поиск упражнения", text: $query)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(Color.white)
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.sportMuted)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.sportCardRaised, in: Capsule())
    }

    private var groupChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    group = nil
                    homeOnly = false
                } label: {
                    Chip(title: "Все", isSelected: group == nil && !homeOnly)
                }
                Button {
                    homeOnly.toggle()
                } label: {
                    Chip(title: "Без инвентаря", isSelected: homeOnly)
                }
                ForEach(MuscleGroup.allCases) { item in
                    Button {
                        group = (group == item) ? nil : item
                    } label: {
                        Chip(title: item.rawValue, isSelected: group == item)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal, -20)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color.sportLime.opacity(0.6))
            Text("Ничего не найдено")
                .font(.sportDisplay(22))
                .foregroundStyle(Color.white)
            Text("Попробуйте изменить запрос или выбрать другую группу мышц.")
                .font(.system(size: 15))
                .foregroundStyle(Color.sportMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ExerciseTile: View {
    let exercise: Exercise

    var body: some View {
        PhotoCard(
            url: exercise.photoURL,
            symbol: exercise.group.symbol,
            eyebrow: exercise.group.rawValue,
            title: exercise.name,
            detail: exercise.difficulty.rawValue,
            height: 200,
            titleSize: 18
        )
    }
}

#Preview {
    CatalogView()
        .environment(AppStore())
        .preferredColorScheme(.dark)
}
