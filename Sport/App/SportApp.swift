import SwiftUI
import UIKit

@main
struct SportApp: App {
    @State private var store = AppStore()

    init() {
        Self.configureTabBar()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.dark)
                .tint(Color.sportLime)
        }
    }

    /// Чёрный таб-бар с лаймовой выбранной вкладкой.
    private static func configureTabBar() {
        let lime = UIColor(red: 0.776, green: 1, blue: 0, alpha: 1)
        let inactive = UIColor(white: 1, alpha: 0.5)

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.shadowColor = UIColor(white: 1, alpha: 0.1)

        let layouts = [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance,
        ]
        for layout in layouts {
            layout.selected.iconColor = lime
            layout.selected.titleTextAttributes = [.foregroundColor: lime]
            layout.normal.iconColor = inactive
            layout.normal.titleTextAttributes = [.foregroundColor: inactive]
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct RootView: View {
    private enum Tab: Hashable {
        case plan, catalog, timer, history, progress
    }

    @State private var selection: Tab = .plan

    var body: some View {
        TabView(selection: $selection) {
            PlanView()
                .tabItem { Label("План", systemImage: "calendar") }
                .tag(Tab.plan)

            CatalogView()
                .tabItem { Label("Каталог", systemImage: "square.grid.2x2.fill") }
                .tag(Tab.catalog)

            TimerView()
                .tabItem { Label("Таймер", systemImage: "timer") }
                .tag(Tab.timer)

            HistoryView()
                .tabItem { Label("История", systemImage: "clock.arrow.circlepath") }
                .tag(Tab.history)

            ProgressTabView()
                .tabItem { Label("Прогресс", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(Tab.progress)
        }
        .background(Color.sportBackground.ignoresSafeArea())
    }
}

#Preview {
    RootView()
        .environment(AppStore())
        .preferredColorScheme(.dark)
}
