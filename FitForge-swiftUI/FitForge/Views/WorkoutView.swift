import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var store: AppStore
    @State private var activeSession: [Exercise] = []
    @State private var sessionName = ""
    @State private var isActive = false
    @State private var restTimerExercise: String? = nil
    @State private var showTemplatePicker = false

    var dayIndex: Int { Calendar.current.component(.weekday, from: Date()) - 2 }
    var template: WorkoutTemplate? { workoutTemplates[store.activeTemplate] }
    var todayLabel: String {
        guard let t = template else { return "Rest" }
        let idx = max(0, min(dayIndex, t.days.count - 1))
        return t.days[idx]
    }
    var todayExercises: [Exercise] {
        template?.exercises[todayLabel] ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            SkyTitle(icon: "⚔️", label: "Training Hall")

            // Template selector
            SkyPanel {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("◈ ACTIVE PROGRAM").font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim)
                        Text(template?.name ?? "No template").font(.system(.subheadline, design: .serif)).foregroundColor(Theme.goldPale)
                        Text("Today: \(todayLabel)").font(.caption).foregroundColor(Theme.muted)
                    }
                    Spacer()
                    SkyButton(title: "CHANGE") { showTemplatePicker = true }
                }
            }

            if todayLabel == "Rest" {
                SkyPanel {
                    VStack(spacing: 8) {
                        Text("🌙").font(.system(size: 36))
                        Text("REST DAY").font(.system(.headline, design: .serif)).tracking(3).foregroundColor(Theme.goldPale)
                        Text("\"Even Dragonborn must rest their blade.\"")
                            .font(.caption).italic().foregroundColor(Theme.muted).multilineTextAlignment(.center)
                    }.frame(maxWidth: .infinity).padding(.vertical, 12)
                }
            } else {
                if !isActive {
                    // Today's plan preview
                    SkyPanel {
                        Text("◈ TODAY'S BATTLE PLAN").font(.system(size: 11)).tracking(3).foregroundColor(Theme.goldDim).padding(.bottom, 8)
                        ForEach(todayExercises) { ex in
                            HStack {
                                Text("⚔").foregroundColor(Theme.goldDim).font(.caption)
                                Text(ex.name).font(.system(.subheadline, design: .serif)).foregroundColor(Theme.parchment)
                                Spacer()
                                Text("\(ex.sets)×\(ex.reps)").font(.caption).foregroundColor(Theme.muted)
                                if ex.weight > 0 {
                                    Text("\(Int(ex.weight))lbs").font(.caption2).foregroundColor(Theme.dimmed).padding(.leading, 4)
                                }
                            }.padding(.vertical, 3)
                        }
                    }
                    SkyButton(title: "⚔️ BEGIN TRAINING", variant: .primary) {
                        activeSession = todayExercises.map { ex in
                            var e = ex; e.completedSets = Array(repeating: CompletedSet(reps: "", weight: "\(Int(ex.weight))"), count: ex.sets)
                            return e
                        }
                        sessionName = todayLabel
                        isActive = true
                    }.frame(maxWidth: .infinity)
                } else {
                    // Active session
                    activeWorkoutView
                }
            }
        }
        .sheet(isPresented: $showTemplatePicker) {
            TemplatePickerView().environmentObject(store)
        }
        .overlay(alignment: .bottom) {
            if let ex = restTimerExercise {
                RestTimerView(exerciseName: ex) { restTimerExercise = nil }
            }
        }
    }

    var activeWorkoutView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("⚔️ \(sessionName.uppercased())").font(.system(.subheadline, design: .serif)).tracking(2).foregroundColor(Theme.goldPale)
                Spacer()
                SkyButton(title: "✓ FINISH", variant: .primary) { finishSession() }
            }.padding(.bottom, 12)

            ForEach($activeSession) { $exercise in
                SkyPanel {
                    Text(exercise.name).font(.system(.subheadline, design: .serif)).foregroundColor(Theme.gold).padding(.bottom, 6)
                    HStack(spacing: 4) {
                        Text("SET").font(.system(size: 9)).tracking(2).foregroundColor(Theme.muted).frame(width: 30)
                        Text("REPS").font(.system(size: 9)).tracking(2).foregroundColor(Theme.muted).frame(maxWidth: .infinity)
                        Text("WEIGHT").font(.system(size: 9)).tracking(2).foregroundColor(Theme.muted).frame(maxWidth: .infinity)
                        Text("✓").font(.system(size: 9)).foregroundColor(Theme.muted).frame(width: 28)
                    }.padding(.bottom, 4)

                    ForEach(exercise.completedSets.indices, id: \.self) { i in
                        SetRow(
                            index: i,
                            set: $exercise.completedSets[i],
                            targetReps: exercise.reps,
                            onComplete: { restTimerExercise = exercise.name }
                        )
                    }
                }
            }
        }
    }

    func finishSession() {
        let session = WorkoutSession(workout: sessionName, date: Date(), exercises: activeSession)
        store.logWorkout(session)
        isActive = false
        activeSession = []
    }
}

struct SetRow: View {
    let index: Int
    @Binding var set: CompletedSet
    let targetReps: String
    let onComplete: () -> Void
    @State private var done = false

    var body: some View {
        HStack(spacing: 4) {
            Text("S\(index + 1)").font(.caption2).foregroundColor(Theme.muted).frame(width: 30)
            TextField(targetReps, text: $set.reps)
                .keyboardType(.numberPad)
                .font(.system(.caption, design: .serif))
                .foregroundColor(Theme.parchment)
                .padding(6).background(Theme.panelHi)
                .overlay(RoundedRectangle(cornerRadius: 1).stroke(Theme.border, lineWidth: 0.5))
                .frame(maxWidth: .infinity)
            TextField("lbs", text: $set.weight)
                .keyboardType(.decimalPad)
                .font(.system(.caption, design: .serif))
                .foregroundColor(Theme.parchment)
                .padding(6).background(Theme.panelHi)
                .overlay(RoundedRectangle(cornerRadius: 1).stroke(Theme.border, lineWidth: 0.5))
                .frame(maxWidth: .infinity)
            Button {
                done.toggle()
                if done { onComplete() }
            } label: {
                Image(systemName: done ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(done ? Theme.greenHi : Theme.border)
                    .frame(width: 28)
            }
        }.padding(.vertical, 2)
    }
}

struct TemplatePickerView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("CHOOSE PROGRAM").font(.system(.headline, design: .serif)).tracking(4).foregroundColor(Theme.goldPale).padding(.top, 20)
                OrnamentDivider()
                ForEach(workoutTemplates.keys.sorted(), id: \.self) { key in
                    let t = workoutTemplates[key]!
                    Button {
                        store.activeTemplate = key
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(t.name).font(.system(.subheadline, design: .serif)).foregroundColor(Theme.goldPale)
                                Text(t.days.joined(separator: " · ")).font(.caption2).foregroundColor(Theme.muted)
                            }
                            Spacer()
                            if store.activeTemplate == key {
                                Text("✓").foregroundColor(Theme.gold)
                            }
                        }
                        .padding(14)
                        .background(store.activeTemplate == key ? Theme.red.opacity(0.2) : Theme.panel)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(store.activeTemplate == key ? Theme.gold : Theme.border, lineWidth: 1))
                        .cornerRadius(2)
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
            }
        }
    }
}

// MARK: - Rest Timer
struct RestTimerView: View {
    let exerciseName: String
    let onDismiss: () -> Void

    let compound: Bool
    @State private var timeLeft: Int
    @State private var running = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(exerciseName: String, onDismiss: @escaping () -> Void) {
        self.exerciseName = exerciseName
        self.onDismiss = onDismiss
        self.compound = isCompound(exerciseName)
        _timeLeft = State(initialValue: isCompound(exerciseName) ? 120 : 60)
    }

    var progress: Double { Double(timeLeft) / Double(compound ? 120 : 60) }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("◈ REST TIMER").font(.system(size: 9)).tracking(3).foregroundColor(Theme.goldDim)
                    Text("⚔ \(exerciseName)").font(.system(.caption, design: .serif)).foregroundColor(Theme.parchment)
                }
                Spacer()
                Button("Dismiss", action: onDismiss).font(.caption).foregroundColor(Theme.muted)
            }

            HStack(spacing: 16) {
                ZStack {
                    Circle().stroke(Theme.panelHi, lineWidth: 6).frame(width: 70, height: 70)
                    Circle().trim(from: 0, to: progress)
                        .stroke(timeLeft == 0 ? Theme.greenHi : Theme.gold, lineWidth: 6)
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                    VStack(spacing: 0) {
                        Text("\(timeLeft / 60):\(String(format: "%02d", timeLeft % 60))")
                            .font(.system(.title3, design: .serif)).foregroundColor(Theme.goldPale)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    SkyButton(title: "⚔️ 2:00 Compound") { timeLeft = 120; running = true }
                    SkyButton(title: "🗡️ 1:00 Isolation") { timeLeft = 60; running = true }
                }
                Spacer()
            }

            if timeLeft == 0 {
                Text("\"Rise, Dragonborn. Your iron awaits.\"")
                    .font(.caption).italic().foregroundColor(Theme.greenHi)
            }
        }
        .padding(16)
        .background(Theme.panel)
        .overlay(VStack { Rectangle().fill(timeLeft == 0 ? Theme.greenHi : Theme.gold).frame(height: 2); Spacer() })
        .shadow(color: .black.opacity(0.8), radius: 12)
        .onReceive(timer) { _ in
            if running && timeLeft > 0 { timeLeft -= 1 }
            else if timeLeft == 0 { running = false }
        }
    }
}
