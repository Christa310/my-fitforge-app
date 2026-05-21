import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var store: AppStore

    var race: Race? { allRaces.first { $0.id == store.character?.race } }
    var pc: PhysiqueClass? { allPhysiqueClasses.first { $0.id == store.character?.physiqueClass } }
    var goal: FitnessGoal? { allGoals.first { $0.id == store.character?.goal } }

    var body: some View {
        VStack(spacing: 0) {
            SkyTitle(icon: "🏰", label: "Character Sheet")

            // Character card
            SkyPanel {
                HStack(spacing: 14) {
                    Text(race?.icon ?? "⚔️").font(.system(size: 52))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.character?.name ?? "Dragonborn")
                            .font(.system(.title2, design: .serif))
                            .foregroundColor(Theme.goldPale)
                        Text("\(race?.name ?? "") • \(pc?.label ?? "")")
                            .font(.caption).tracking(1).foregroundColor(Theme.goldDim)
                        Text(goal?.label ?? "").font(.caption).foregroundColor(Theme.muted)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("🔥 \(store.streak)").font(.subheadline).foregroundColor(Theme.gold)
                        Text("day streak").font(.caption2).foregroundColor(Theme.muted)
                    }
                }
                OrnamentDivider()
                if let race = race {
                    HStack {
                        Text("BONUS:").font(.system(size: 9)).tracking(2).foregroundColor(Theme.muted)
                        Text(race.bonus).font(.system(size: 11, design: .serif)).foregroundColor(Theme.goldDim)
                    }
                }
            }

            // Today's macros
            SkyPanel {
                Text("◈ TODAY'S CHRONICLE")
                    .font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 8)
                MacroBar(label: "Calories", current: store.totals.cal, goal: store.macroGoals.calories, color: Theme.gold)
                MacroBar(label: "Protein",  current: store.totals.pro, goal: store.macroGoals.protein,  color: Color(hex: "#4a90d4"))
                MacroBar(label: "Fiber",    current: store.totals.fib, goal: store.macroGoals.fiber,    color: Theme.greenHi)
            }

            // Achievements
            SkyPanel {
                Text("◈ ACHIEVEMENTS")
                    .font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 8)
                let unlocked = allAchievements.filter { store.unlockedAchievements.contains($0.id) }
                if unlocked.isEmpty {
                    Text("No achievements yet. Begin your legend.")
                        .font(.caption).italic().foregroundColor(Theme.dimmed)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                        ForEach(unlocked.prefix(8)) { ach in
                            VStack(spacing: 3) {
                                Text(ach.icon).font(.title2)
                                Text(ach.title).font(.system(size: 8)).multilineTextAlignment(.center).foregroundColor(Theme.muted).lineLimit(2)
                            }
                        }
                    }
                }
                Text("\(store.unlockedAchievements.count)/\(allAchievements.count) unlocked")
                    .font(.caption2).foregroundColor(Theme.dimmed).padding(.top, 4)
            }
        }
    }
}
