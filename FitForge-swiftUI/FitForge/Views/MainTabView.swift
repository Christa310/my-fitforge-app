import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: AppStore
    @State private var selectedTab = "dashboard"

    var body: some View {
        ZStack(alignment: .top) {
            Theme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Content
                TabContent(selectedTab: $selectedTab)
                    .environmentObject(store)

                // Bottom Nav
                BottomNav(selectedTab: $selectedTab)
            }

            // Achievement banner overlay
            if let ach = store.pendingAchievement {
                AchievementBanner(achievement: ach) {
                    withAnimation { store.pendingAchievement = nil }
                }
                .zIndex(100)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                        withAnimation { store.pendingAchievement = nil }
                    }
                }
            }
        }
    }
}

struct TabContent: View {
    @EnvironmentObject var store: AppStore
    @Binding var selectedTab: String

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                switch selectedTab {
                case "dashboard":  DashboardView().environmentObject(store)
                case "meals":      MealsView().environmentObject(store)
                case "nutrition":  NutritionView().environmentObject(store)
                case "workout":    WorkoutView().environmentObject(store)
                case "history":    WorkoutHistoryView().environmentObject(store)
                case "weight":     WeightView().environmentObject(store)
                case "recovery":   RecoveryView().environmentObject(store)
                case "coach":      CoachView().environmentObject(store)
                default:           DashboardView().environmentObject(store)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 80)
        }
    }
}

struct BottomNav: View {
    @Binding var selectedTab: String

    let items: [(id: String, icon: String, label: String)] = [
        ("dashboard", "🏰", "Character"),
        ("meals",     "🍖", "Rations"),
        ("workout",   "⚔️", "Training"),
        ("weight",    "⚖️", "Vitals"),
        ("recovery",  "🌙", "Recovery"),
        ("coach",     "🐉", "Coach"),
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(items, id: \.id) { item in
                    Button {
                        selectedTab = item.id
                    } label: {
                        VStack(spacing: 3) {
                            Text(item.icon).font(.system(size: 18))
                            Text(item.label)
                                .font(.system(size: 9, design: .serif))
                                .tracking(0.5)
                                .foregroundColor(selectedTab == item.id ? Theme.goldPale : Theme.muted)
                        }
                        .frame(width: 70)
                        .padding(.vertical, 8)
                        .background(
                            selectedTab == item.id
                                ? Theme.red.opacity(0.2)
                                : Color.clear
                        )
                        .overlay(
                            VStack {
                                Rectangle()
                                    .fill(selectedTab == item.id ? Theme.gold : Color.clear)
                                    .frame(height: 2)
                                Spacer()
                            }
                        )
                    }
                }
            }
        }
        .background(Theme.panel)
        .overlay(
            VStack {
                Rectangle().fill(Theme.border).frame(height: 1)
                Spacer()
            }
        )
        .frame(height: 60)
    }
}
