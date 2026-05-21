import SwiftUI
import Charts

// MARK: - Weight View
struct WeightView: View {
    @EnvironmentObject var store: AppStore
    @State private var newWeight = ""

    var minW: Double { store.weights.map(\.weight).min() ?? 0 }
    var maxW: Double { store.weights.map(\.weight).max() ?? 1 }

    var body: some View {
        VStack(spacing: 0) {
            SkyTitle(icon: "⚖️", label: "Vitals & Essence")

            SkyPanel {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CURRENT").font(.system(size: 10)).tracking(2).foregroundColor(Theme.muted)
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(store.weights.last?.weight ?? 0, specifier: "%.1f")")
                                .font(.system(.largeTitle, design: .serif)).foregroundColor(Theme.gold)
                            Text("lbs").font(.caption).foregroundColor(Theme.muted)
                        }
                    }
                    Spacer()
                    if store.weights.count > 1 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("7-DAY").font(.system(size: 10)).tracking(2).foregroundColor(Theme.muted)
                            let diff = (store.weights.first?.weight ?? 0) - (store.weights.last?.weight ?? 0)
                            Text("\(diff >= 0 ? "↓" : "↑")\(abs(diff), specifier: "%.1f") lbs")
                                .font(.title3).foregroundColor(diff >= 0 ? Theme.greenHi : Theme.redHi)
                        }
                    }
                }

                // Chart
                if store.weights.count > 1 {
                    Chart {
                        ForEach(store.weights) { entry in
                            LineMark(
                                x: .value("Date", entry.date),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(Theme.gold)
                            PointMark(
                                x: .value("Date", entry.date),
                                y: .value("Weight", entry.weight)
                            )
                            .foregroundStyle(Theme.gold)
                        }
                    }
                    .chartYScale(domain: (minW - 2)...(maxW + 2))
                    .frame(height: 140)
                    .chartXAxis {
                        AxisMarks(values: .automatic) {
                            AxisValueLabel().foregroundStyle(Theme.muted)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic) {
                            AxisValueLabel().foregroundStyle(Theme.muted)
                            AxisGridLine().foregroundStyle(Theme.border.opacity(0.5))
                        }
                    }
                    .padding(.top, 12)
                }
            }

            // Log weight
            SkyPanel {
                Text("◈ RECORD VITALS").font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 8)
                HStack(spacing: 8) {
                    SkyTextField(placeholder: "e.g. 179.0", text: $newWeight, keyboardType: .decimalPad)
                    SkyButton(title: "RECORD", variant: .primary) {
                        guard let w = Double(newWeight) else { return }
                        store.logWeight(w)
                        newWeight = ""
                    }
                }
            }

            // History
            SkyPanel {
                Text("◈ CHRONICLES").font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 8)
                ForEach(store.weights.reversed()) { entry in
                    HStack {
                        Text(entry.date).font(.caption).foregroundColor(Theme.muted)
                        Spacer()
                        Text("\(entry.weight, specifier: "%.1f") lbs").font(.system(.subheadline, design: .serif)).foregroundColor(Theme.parchment)
                    }
                    .padding(.vertical, 4)
                    Divider().background(Theme.border.opacity(0.4))
                }
            }
        }
    }
}

// MARK: - Nutrition View
struct NutritionView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        VStack(spacing: 0) {
            SkyTitle(icon: "📊", label: "Macro Chronicle")

            // Macro bars
            SkyPanel {
                Text("◈ MACRO TARGETS").font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 8)
                MacroBar(label: "Calories", current: store.totals.cal, goal: store.macroGoals.calories, color: Theme.gold)
                MacroBar(label: "Protein",  current: store.totals.pro, goal: store.macroGoals.protein,  color: Color(hex: "#4a90d4"))
                MacroBar(label: "Fiber",    current: store.totals.fib, goal: store.macroGoals.fiber,    color: Theme.greenHi)
            }

            // Goal editor
            SkyPanel {
                Text("◈ DAILY TARGETS").font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 8)
                GoalEditor()
            }
        }
    }
}

struct GoalEditor: View {
    @EnvironmentObject var store: AppStore
    @State private var calories = ""
    @State private var protein = ""
    @State private var fiber = ""
    @State private var editing = false

    var body: some View {
        if editing {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CALORIES").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                        SkyTextField(placeholder: "\(Int(store.macroGoals.calories))", text: $calories, keyboardType: .numberPad)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PROTEIN").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                        SkyTextField(placeholder: "\(Int(store.macroGoals.protein))", text: $protein, keyboardType: .numberPad)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FIBER").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                        SkyTextField(placeholder: "\(Int(store.macroGoals.fiber))", text: $fiber, keyboardType: .numberPad)
                    }
                }
                SkyButton(title: "✓ SEAL TARGETS", variant: .primary) {
                    if let c = Double(calories) { store.macroGoals.calories = c }
                    if let p = Double(protein)  { store.macroGoals.protein = p }
                    if let f = Double(fiber)    { store.macroGoals.fiber = f }
                    editing = false
                }
            }
        } else {
            HStack {
                Text("\(Int(store.macroGoals.calories)) kcal · \(Int(store.macroGoals.protein))g protein · \(Int(store.macroGoals.fiber))g fiber")
                    .font(.caption).foregroundColor(Theme.muted)
                Spacer()
                SkyButton(title: "✏ EDIT") {
                    calories = "\(Int(store.macroGoals.calories))"
                    protein  = "\(Int(store.macroGoals.protein))"
                    fiber    = "\(Int(store.macroGoals.fiber))"
                    editing  = true
                }
            }
        }
    }
}

// MARK: - Recovery View
struct RecoveryView: View {
    @EnvironmentObject var store: AppStore
    @State private var sleep = 7.0
    @State private var soreness = 2
    @State private var energy = 3
    @State private var notes = ""
    @State private var saved = false

    var body: some View {
        VStack(spacing: 0) {
            SkyTitle(icon: "🌙", label: "Recovery Sanctum")

            SkyPanel {
                Text("◈ LOG RECOVERY").font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 12)

                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("😴 SLEEP").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                            Spacer()
                            Text("\(sleep, specifier: "%.1f") hrs").font(.caption).foregroundColor(Theme.gold)
                        }
                        Slider(value: $sleep, in: 0...12, step: 0.5)
                            .accentColor(Theme.gold.cgColor.map { UIColor($0) }.map { Color($0) } ?? Theme.gold)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("💢 SORENESS").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                            Spacer()
                            Text("\(soreness)/5").font(.caption).foregroundColor(Theme.redHi)
                        }
                        HStack(spacing: 6) {
                            ForEach(1...5, id: \.self) { i in
                                Button { soreness = i } label: {
                                    Circle()
                                        .fill(i <= soreness ? Theme.redHi : Theme.panelHi)
                                        .frame(width: 30, height: 30)
                                        .overlay(Circle().stroke(i <= soreness ? Theme.redHi : Theme.border, lineWidth: 1))
                                }
                            }
                            Spacer()
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("⚡ ENERGY").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                            Spacer()
                            Text("\(energy)/5").font(.caption).foregroundColor(Theme.greenHi)
                        }
                        HStack(spacing: 6) {
                            ForEach(1...5, id: \.self) { i in
                                Button { energy = i } label: {
                                    Circle()
                                        .fill(i <= energy ? Theme.greenHi : Theme.panelHi)
                                        .frame(width: 30, height: 30)
                                        .overlay(Circle().stroke(i <= energy ? Theme.greenHi : Theme.border, lineWidth: 1))
                                }
                            }
                            Spacer()
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("NOTES").font(.caption2).tracking(2).foregroundColor(Theme.muted)
                        SkyTextField(placeholder: "How are you feeling, Dragonborn?", text: $notes)
                    }
                }

                SkyButton(title: saved ? "✓ LOGGED" : "🌙 LOG RECOVERY", variant: .primary) {
                    let entry = RecoveryEntry(sleep: sleep, soreness: soreness, energy: energy, notes: notes, date: Date())
                    store.logRecovery(entry)
                    saved = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { saved = false }
                }.padding(.top, 12)
            }

            // Recent entries
            if !store.recoveryEntries.isEmpty {
                SkyPanel {
                    Text("◈ RECENT RECOVERY").font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 8)
                    ForEach(store.recoveryEntries.suffix(5).reversed(), id: \.date) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.date, style: .date).font(.caption).foregroundColor(Theme.muted)
                                Text("😴 \(entry.sleep, specifier: "%.1f")h · 💢 \(entry.soreness)/5 · ⚡ \(entry.energy)/5")
                                    .font(.caption2).foregroundColor(Theme.parchment)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        Divider().background(Theme.border.opacity(0.4))
                    }
                }
            }
        }
    }
}

// MARK: - Workout History View
struct WorkoutHistoryView: View {
    @EnvironmentObject var store: AppStore
    @State private var expanded: UUID? = nil

    var body: some View {
        VStack(spacing: 0) {
            SkyTitle(icon: "📜", label: "Workout Chronicles")

            if store.workoutSessions.isEmpty {
                SkyPanel {
                    Text("No battles recorded yet.\nBegin training and your chronicle will be written here.")
                        .font(.caption).italic().foregroundColor(Theme.dimmed)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                }
            } else {
                ForEach(store.workoutSessions.reversed()) { session in
                    SkyPanel {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text("⚔️")
                                    Text(session.workout).font(.system(.subheadline, design: .serif)).foregroundColor(Theme.goldPale)
                                }
                                Text(session.date, style: .date).font(.caption2).foregroundColor(Theme.muted)
                                Text("\(session.exercises.count) exercises").font(.caption2).foregroundColor(Theme.muted)
                            }
                            Spacer()
                            Button {
                                expanded = expanded == session.id ? nil : session.id
                            } label: {
                                Text(expanded == session.id ? "▲" : "▼").font(.caption).foregroundColor(Theme.muted)
                            }
                        }

                        if expanded == session.id {
                            Divider().background(Theme.border.opacity(0.4)).padding(.vertical, 8)
                            ForEach(session.exercises) { ex in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ex.name).font(.caption).foregroundColor(Theme.gold)
                                    HStack(spacing: 6) {
                                        ForEach(ex.completedSets.indices, id: \.self) { i in
                                            let s = ex.completedSets[i]
                                            Text(s.reps.isEmpty ? "—" : "\(s.reps)×\(s.weight)lbs")
                                                .font(.system(size: 10))
                                                .foregroundColor(s.reps.isEmpty ? Theme.dimmed : Theme.parchment)
                                                .padding(.horizontal, 6).padding(.vertical, 3)
                                                .background(s.reps.isEmpty ? Theme.panelHi : Theme.greenHi.opacity(0.15))
                                                .overlay(RoundedRectangle(cornerRadius: 1).stroke(s.reps.isEmpty ? Theme.border : Theme.greenHi.opacity(0.4), lineWidth: 0.5))
                                        }
                                    }
                                }.padding(.vertical, 2)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Coach (Paarthurnax) View
struct CoachView: View {
    @EnvironmentObject var store: AppStore
    @State private var input = ""
    @State private var isLoading = false

    let suggestedQuestions = [
        "📊 Assess my chronicle today",
        "💪 Am I ready for heavier iron?",
        "🥗 How do I claim my macro targets?",
        "🌙 Assess my recovery — should I train?",
    ]

    var body: some View {
        VStack(spacing: 0) {
            SkyTitle(icon: "🐉", label: "Paarthurnax")

            if store.chatHistory.isEmpty {
                SkyPanel {
                    VStack(spacing: 12) {
                        Text("🐉").font(.system(size: 52))
                        Text("PAARTHURNAX").font(.system(.headline, design: .serif)).tracking(3).foregroundColor(Theme.gold)
                        Text("MASTER OF THE THROAT OF THE WORLD")
                            .font(.system(size: 10)).tracking(2).foregroundColor(Theme.goldDim)
                        OrnamentDivider()
                        VStack(spacing: 8) {
                            ForEach(suggestedQuestions, id: \.self) { q in
                                Button { sendMessage(q) } label: {
                                    HStack {
                                        Text(q).font(.system(.caption, design: .serif)).foregroundColor(Theme.parchment)
                                        Spacer()
                                        Text("→").foregroundColor(Theme.goldDim)
                                    }
                                    .padding(10)
                                    .background(Theme.panelHi)
                                    .overlay(RoundedRectangle(cornerRadius: 1).stroke(Theme.border, lineWidth: 1).overlay(
                                        HStack { Rectangle().fill(Theme.goldDim).frame(width: 3); Spacer() }
                                    ))
                                }
                            }
                        }
                    }.frame(maxWidth: .infinity)
                }
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(store.chatHistory) { msg in
                            ChatBubble(message: msg)
                        }
                        if isLoading {
                            HStack(spacing: 8) {
                                Text("🐉").font(.caption)
                                Text("Paarthurnax contemplates the ancient wisdom...")
                                    .font(.caption).italic().foregroundColor(Theme.muted)
                                Spacer()
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
            }

            // Input
            HStack(spacing: 8) {
                SkyTextField(placeholder: "Speak to Paarthurnax, Dragonborn...", text: $input)
                Button {
                    sendMessage(input)
                } label: {
                    Text("🔥").font(.title2)
                        .padding(10)
                        .background(Theme.red.opacity(0.6))
                        .overlay(RoundedRectangle(cornerRadius: 1).stroke(Theme.gold, lineWidth: 1))
                        .cornerRadius(1)
                }
                .disabled(isLoading || input.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.top, 10)
        }
    }

    func sendMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        input = ""

        let userMsg = ChatMessage(role: "user", content: trimmed)
        store.chatHistory.append(userMsg)
        store.checkAchievements()

        isLoading = true
        let context = buildContext()

        Task {
            let reply = await callPaarthurnax(userMessage: trimmed, context: context)
            await MainActor.run {
                store.chatHistory.append(ChatMessage(role: "assistant", content: reply))
                isLoading = false
            }
        }
    }

    func buildContext() -> String {
        """
        Character: \(store.character?.name ?? "Dragonborn"), \(store.character?.race ?? ""), \(store.character?.physiqueClass ?? "")
        Goal: \(store.character?.goal ?? "")
        Today's Calories: \(Int(store.totals.cal))/\(Int(store.macroGoals.calories)) kcal
        Today's Protein: \(Int(store.totals.pro))/\(Int(store.macroGoals.protein))g
        Today's Fiber: \(Int(store.totals.fib))/\(Int(store.macroGoals.fiber))g
        Streak: \(store.streak) days
        Last weight: \(store.weights.last?.weight ?? 0) lbs
        Recent recovery: \(store.recoveryEntries.last.map { "Sleep \($0.sleep)h, Soreness \($0.soreness)/5, Energy \($0.energy)/5" } ?? "No data")
        """
    }

    func callPaarthurnax(userMessage: String, context: String) async -> String {
        let system = """
        You are Paarthurnax, the ancient dragon sage from Skyrim, now serving as a wise fitness coach. 
        Speak in a wise, archaic tone. Address the user as 'Dragonborn'. Keep responses under 120 words.
        Use their fitness data to give specific, actionable advice. Reference their race and class when relevant.
        User context: \(context)
        """

        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else { return "The oracle cannot be reached." }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 300,
            "system": system,
            "messages": [["role": "user", "content": userMessage]]
        ]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else { return "The oracle cannot be reached." }
        request.httpBody = bodyData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = json["content"] as? [[String: Any]],
               let text = content.first?["text"] as? String {
                return text
            }
        } catch {}
        return "\"The Thu'um eludes me now, Dragonborn. Seek me again shortly.\""
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == "user" }

    var body: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
            Text(isUser ? "DRAGONBORN" : "🐉 PAARTHURNAX")
                .font(.system(size: 9)).tracking(2)
                .foregroundColor(isUser ? Theme.muted : Theme.goldDim)

            Text(message.content)
                .font(.system(isUser ? .subheadline : .subheadline, design: .serif))
                .italic(!isUser)
                .foregroundColor(Theme.parchment)
                .padding(12)
                .background(isUser ? Theme.red.opacity(0.25) : Theme.panelHi)
                .overlay(
                    RoundedRectangle(cornerRadius: 1)
                        .stroke(isUser ? Theme.red.opacity(0.5) : Theme.border, lineWidth: 1)
                        .overlay(
                            HStack {
                                if !isUser { Rectangle().fill(Theme.goldDim).frame(width: 3) }
                                Spacer()
                                if isUser { Rectangle().fill(Theme.red.opacity(0.7)).frame(width: 3) }
                            }
                        )
                )
                .cornerRadius(1)
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }
}
