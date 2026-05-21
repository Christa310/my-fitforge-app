import SwiftUI

struct MealsView: View {
    @EnvironmentObject var store: AppStore
    @State private var showAddMeal = false
    @State private var selectedCategory = "breakfast"

    var filteredMeals: [Meal] { store.meals.filter { $0.category == selectedCategory } }

    var body: some View {
        VStack(spacing: 0) {
            SkyTitle(icon: "🍖", label: "Daily Rations")

            // Category picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(mealCategories, id: \.0) { cat in
                        Button {
                            selectedCategory = cat.0
                        } label: {
                            HStack(spacing: 4) {
                                Text(cat.2).font(.caption)
                                Text(cat.1).font(.system(.caption, design: .serif)).tracking(1)
                            }
                            .foregroundColor(selectedCategory == cat.0 ? Theme.goldPale : Theme.muted)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(selectedCategory == cat.0 ? Theme.red.opacity(0.3) : Theme.panel)
                            .overlay(RoundedRectangle(cornerRadius: 1).stroke(selectedCategory == cat.0 ? Theme.gold : Theme.border, lineWidth: 1))
                            .cornerRadius(1)
                        }
                    }
                }
            }.padding(.bottom, 12)

            // Macro summary
            SkyPanel {
                Text("◈ TODAY'S TOTALS").font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 8)
                HStack {
                    ForEach([
                        ("⚡", "\(Int(store.totals.cal))", "kcal"),
                        ("💪", "\(Int(store.totals.pro))g", "protein"),
                        ("🌿", "\(Int(store.totals.fib))g", "fiber"),
                    ], id: \.0) { item in
                        VStack(spacing: 2) {
                            Text(item.0).font(.title3)
                            Text(item.1).font(.system(.subheadline, design: .serif)).foregroundColor(Theme.goldPale)
                            Text(item.2).font(.caption2).foregroundColor(Theme.muted)
                        }.frame(maxWidth: .infinity)
                    }
                }
            }

            // Meals list
            if filteredMeals.isEmpty {
                SkyPanel {
                    Text("No rations logged for this meal yet.")
                        .font(.caption).italic().foregroundColor(Theme.dimmed)
                        .frame(maxWidth: .infinity, alignment: .center).padding(.vertical, 12)
                }
            } else {
                ForEach(filteredMeals) { meal in
                    MealRow(meal: meal)
                }
            }

            // Add button
            SkyButton(title: "+ ADD RATION", variant: .primary) {
                showAddMeal = true
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .sheet(isPresented: $showAddMeal) {
            AddMealView(category: selectedCategory)
                .environmentObject(store)
        }
    }
}

struct MealRow: View {
    @EnvironmentObject var store: AppStore
    let meal: Meal

    var body: some View {
        SkyPanel {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name).font(.system(.subheadline, design: .serif)).foregroundColor(Theme.parchment)
                    Text(meal.time).font(.caption2).foregroundColor(Theme.muted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(meal.calories)) kcal").font(.caption).foregroundColor(Theme.gold)
                    HStack(spacing: 8) {
                        Text("P: \(Int(meal.protein))g").font(.caption2).foregroundColor(Color(hex: "#4a90d4"))
                        Text("F: \(Int(meal.fiber))g").font(.caption2).foregroundColor(Theme.greenHi)
                    }
                }
                Button {
                    store.meals.removeAll { $0.id == meal.id }
                } label: {
                    Text("✕").font(.caption).foregroundColor(Theme.redHi).padding(.leading, 8)
                }
            }
        }
    }
}

struct AddMealView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    let category: String

    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var fiber = ""

    var canSave: Bool { !name.isEmpty && !calories.isEmpty }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("ADD RATION").font(.system(.headline, design: .serif)).tracking(4).foregroundColor(Theme.goldPale).padding(.top, 20)
                OrnamentDivider()

                Group {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MEAL NAME").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                        SkyTextField(placeholder: "e.g. Grilled Chicken & Rice", text: $name)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CALORIES").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                        SkyTextField(placeholder: "e.g. 520", text: $calories, keyboardType: .decimalPad)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PROTEIN (g)").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                        SkyTextField(placeholder: "e.g. 45", text: $protein, keyboardType: .decimalPad)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FIBER (g)").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                        SkyTextField(placeholder: "e.g. 5", text: $fiber, keyboardType: .decimalPad)
                    }
                }.padding(.horizontal, 20)

                HStack(spacing: 12) {
                    SkyButton(title: "CANCEL") { dismiss() }
                    SkyButton(title: "⚔️ LOG RATION", variant: .primary, disabled: !canSave) {
                        let meal = Meal(
                            name: name,
                            calories: Double(calories) ?? 0,
                            protein: Double(protein) ?? 0,
                            fiber: Double(fiber) ?? 0,
                            category: category,
                            time: currentTime()
                        )
                        store.logMeal(meal)
                        dismiss()
                    }
                }.padding(.horizontal, 20)

                Spacer()
            }
        }
    }

    private func currentTime() -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"
        return f.string(from: Date())
    }
}
