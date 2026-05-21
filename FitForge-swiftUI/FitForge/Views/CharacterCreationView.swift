import SwiftUI

struct CharacterCreationView: View {
    @EnvironmentObject var store: AppStore
    @State private var step = 0
    @State private var name = ""
    @State private var selectedRace = ""
    @State private var selectedClass = ""
    @State private var selectedGoal = ""
    @State private var selectedStyle = ""

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 6) {
                        Text("🐉").font(.system(size: 48))
                        Text("FITFORGE").font(.system(.title, design: .serif)).tracking(6).foregroundColor(Theme.goldPale)
                        Text("FORGE YOUR LEGEND").font(.caption).tracking(4).foregroundColor(Theme.goldDim)
                        OrnamentDivider()
                    }
                    .padding(.top, 40).padding(.bottom, 20)

                    // Step indicator
                    HStack(spacing: 6) {
                        ForEach(0..<4, id: \.self) { i in
                            Circle()
                                .fill(i <= step ? Theme.gold : Theme.border)
                                .frame(width: 8, height: 8)
                        }
                    }.padding(.bottom, 24)

                    switch step {
                    case 0: nameStep
                    case 1: raceStep
                    case 2: classStep
                    case 3: goalStep
                    default: EmptyView()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Step 0: Name
    var nameStep: some View {
        VStack(spacing: 16) {
            SkyTitle(icon: "⚔️", label: "Name Your Dragonborn")
            SkyPanel {
                Text("What is your name, warrior?")
                    .font(.caption).foregroundColor(Theme.muted).padding(.bottom, 6)
                SkyTextField(placeholder: "Enter your name...", text: $name)
            }
            SkyButton(title: "CONTINUE →", variant: .primary, disabled: name.trimmingCharacters(in: .whitespaces).isEmpty) {
                withAnimation { step = 1 }
            }
        }
    }

    // MARK: - Step 1: Race
    var raceStep: some View {
        VStack(spacing: 16) {
            SkyTitle(icon: "🌍", label: "Choose Your Race")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(allRaces) { race in
                    Button {
                        selectedRace = race.id
                    } label: {
                        VStack(spacing: 6) {
                            Text(race.icon).font(.system(size: 28))
                            Text(race.name).font(.system(.caption, design: .serif)).tracking(1).foregroundColor(Theme.goldPale)
                            Text(race.bonus).font(.system(size: 9)).tracking(0.5).foregroundColor(Theme.muted).lineLimit(1)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(selectedRace == race.id ? Theme.red.opacity(0.3) : Theme.panel)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(selectedRace == race.id ? Theme.gold : Theme.border, lineWidth: selectedRace == race.id ? 2 : 1))
                        .cornerRadius(2)
                    }
                }
            }
            if !selectedRace.isEmpty, let race = allRaces.first(where: { $0.id == selectedRace }) {
                SkyPanel {
                    Text(race.desc).font(.caption).foregroundColor(Theme.parchment).italic()
                }
            }
            HStack {
                SkyButton(title: "← BACK") { withAnimation { step = 0 } }
                Spacer()
                SkyButton(title: "CONTINUE →", variant: .primary, disabled: selectedRace.isEmpty) {
                    withAnimation { step = 2 }
                }
            }
        }
    }

    // MARK: - Step 2: Class
    var classStep: some View {
        VStack(spacing: 16) {
            SkyTitle(icon: "🛡️", label: "Choose Your Class")
            ForEach(allPhysiqueClasses) { pc in
                Button {
                    selectedClass = pc.id
                } label: {
                    HStack(spacing: 12) {
                        Text(pc.icon).font(.title2).frame(width: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pc.label).font(.system(.subheadline, design: .serif)).foregroundColor(Theme.goldPale)
                            Text(pc.desc).font(.caption).foregroundColor(Theme.muted)
                        }
                        Spacer()
                        if selectedClass == pc.id {
                            Image(systemName: "checkmark").foregroundColor(Theme.gold)
                        }
                    }
                    .padding(12)
                    .background(selectedClass == pc.id ? Theme.red.opacity(0.2) : Theme.panel)
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(selectedClass == pc.id ? Theme.gold : Theme.border, lineWidth: 1))
                    .cornerRadius(2)
                }
            }
            HStack {
                SkyButton(title: "← BACK") { withAnimation { step = 1 } }
                Spacer()
                SkyButton(title: "CONTINUE →", variant: .primary, disabled: selectedClass.isEmpty) {
                    withAnimation { step = 3 }
                }
            }
        }
    }

    // MARK: - Step 3: Goal
    var goalStep: some View {
        VStack(spacing: 16) {
            SkyTitle(icon: "🎯", label: "Your Quest")
            ForEach(allGoals) { goal in
                Button {
                    selectedGoal = goal.id
                } label: {
                    HStack(spacing: 12) {
                        Text(goal.icon).font(.title2).frame(width: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(goal.label).font(.system(.subheadline, design: .serif)).foregroundColor(Theme.goldPale)
                            Text(goal.desc).font(.caption).foregroundColor(Theme.muted)
                        }
                        Spacer()
                        if selectedGoal == goal.id {
                            Image(systemName: "checkmark").foregroundColor(Theme.gold)
                        }
                    }
                    .padding(12)
                    .background(selectedGoal == goal.id ? Theme.red.opacity(0.2) : Theme.panel)
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(selectedGoal == goal.id ? Theme.gold : Theme.border, lineWidth: 1))
                    .cornerRadius(2)
                }
            }

            // Workout style
            SkyTitle(icon: "🏋️", label: "Training Ground")
            HStack(spacing: 10) {
                ForEach(allWorkoutStyles) { style in
                    Button {
                        selectedStyle = style.id
                    } label: {
                        VStack(spacing: 4) {
                            Text(style.icon).font(.title2)
                            Text(style.label).font(.system(size: 10, design: .serif)).multilineTextAlignment(.center).foregroundColor(Theme.parchment)
                        }
                        .frame(maxWidth: .infinity).padding(10)
                        .background(selectedStyle == style.id ? Theme.red.opacity(0.3) : Theme.panel)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(selectedStyle == style.id ? Theme.gold : Theme.border, lineWidth: 1))
                        .cornerRadius(2)
                    }
                }
            }

            HStack {
                SkyButton(title: "← BACK") { withAnimation { step = 2 } }
                Spacer()
                SkyButton(title: "⚔️ BEGIN QUEST", variant: .primary,
                          disabled: selectedGoal.isEmpty || selectedStyle.isEmpty) {
                    let char = Character(
                        name: name,
                        race: selectedRace,
                        physiqueClass: selectedClass,
                        goal: selectedGoal,
                        workoutStyle: selectedStyle
                    )
                    store.character = char
                    store.unlockedAchievements.insert("char_born")
                }
            }
        }
    }
}
