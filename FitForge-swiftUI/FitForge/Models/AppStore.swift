import Foundation
import SwiftUI
import Combine

class AppStore: ObservableObject {
    // MARK: - Character
    @Published var character: Character? {
        didSet { save("character", character) }
    }

    // MARK: - Nutrition
    @Published var meals: [Meal] = [] {
        didSet { save("meals", meals) }
    }
    @Published var macroGoals: MacroGoals = MacroGoals() {
        didSet { save("macroGoals", macroGoals) }
    }

    // MARK: - Workouts
    @Published var workoutSessions: [WorkoutSession] = [] {
        didSet { save("workoutSessions", workoutSessions) }
    }
    @Published var activeTemplate: String = "ppl" {
        didSet { save("activeTemplate", activeTemplate) }
    }

    // MARK: - Weight
    @Published var weights: [WeightEntry] = [
        WeightEntry(date: "May 5",  weight: 182),
        WeightEntry(date: "May 6",  weight: 181.5),
        WeightEntry(date: "May 7",  weight: 181),
        WeightEntry(date: "May 8",  weight: 180.5),
        WeightEntry(date: "May 9",  weight: 181),
        WeightEntry(date: "May 10", weight: 180),
        WeightEntry(date: "May 11", weight: 179.5),
    ] {
        didSet { save("weights", weights) }
    }

    // MARK: - Recovery
    @Published var recoveryEntries: [RecoveryEntry] = [] {
        didSet { save("recoveryEntries", recoveryEntries) }
    }

    // MARK: - Achievements
    @Published var unlockedAchievements: Set<String> = [] {
        didSet { save("unlockedAchievements", Array(unlockedAchievements)) }
    }
    @Published var pendingAchievement: Achievement? = nil

    // MARK: - Streak
    @Published var streak: Int = 0 {
        didSet { save("streak", streak) }
    }
    @Published var loggedToday: Bool = false {
        didSet { save("loggedToday", loggedToday) }
    }

    // MARK: - Chat
    @Published var chatHistory: [ChatMessage] = []

    init() {
        load()
    }

    // MARK: - Computed
    var totals: (cal: Double, pro: Double, fib: Double) {
        meals.reduce((0, 0, 0)) { acc, m in
            (acc.0 + m.calories, acc.1 + m.protein, acc.2 + m.fiber)
        }
    }

    // MARK: - Persistence
    private func save<T: Codable>(_ key: String, _ value: T) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load<T: Codable>(_ key: String, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    private func load() {
        character           = load("character",           as: Character.self)
        meals               = load("meals",               as: [Meal].self)           ?? []
        macroGoals          = load("macroGoals",          as: MacroGoals.self)       ?? MacroGoals()
        workoutSessions     = load("workoutSessions",     as: [WorkoutSession].self) ?? []
        activeTemplate      = load("activeTemplate",      as: String.self)           ?? "ppl"
        weights             = load("weights",             as: [WeightEntry].self)    ?? weights
        recoveryEntries     = load("recoveryEntries",     as: [RecoveryEntry].self)  ?? []
        streak              = load("streak",              as: Int.self)              ?? 0
        loggedToday         = load("loggedToday",         as: Bool.self)             ?? false
        let ids             = load("unlockedAchievements", as: [String].self)        ?? []
        unlockedAchievements = Set(ids)
    }

    // MARK: - Achievement Checking
    func checkAchievements() {
        for achievement in allAchievements {
            guard !unlockedAchievements.contains(achievement.id) else { continue }
            var unlocked = false
            switch achievement.id {
            case "first_meal":     unlocked = meals.count >= 1
            case "macro_hit":      unlocked = totals.cal >= macroGoals.calories && totals.pro >= macroGoals.protein && totals.fib >= macroGoals.fiber
            case "feast":          unlocked = meals.count >= 5
            case "first_workout":  unlocked = !workoutSessions.isEmpty
            case "iron_will":      unlocked = streak >= 7
            case "streak_3":       unlocked = streak >= 3
            case "streak_7":       unlocked = streak >= 7
            case "streak_30":      unlocked = streak >= 30
            case "streak_100":     unlocked = streak >= 100
            case "first_recovery": unlocked = !recoveryEntries.isEmpty
            case "well_rested":    unlocked = recoveryEntries.last?.sleep ?? 0 >= 8
            case "weight_logged":  unlocked = weights.count >= 7
            case "char_born":      unlocked = character != nil
            case "paarthurnax":    unlocked = chatHistory.count >= 1
            default: break
            }
            if unlocked {
                unlockedAchievements.insert(achievement.id)
                pendingAchievement = achievement
            }
        }
    }

    func logMeal(_ meal: Meal) {
        meals.append(meal)
        if !loggedToday { streak += 1; loggedToday = true }
        checkAchievements()
    }

    func logWorkout(_ session: WorkoutSession) {
        workoutSessions.append(session)
        checkAchievements()
    }

    func logWeight(_ w: Double) {
        let entry = WeightEntry(date: formattedToday(), weight: w)
        weights.append(entry)
        checkAchievements()
    }

    func logRecovery(_ entry: RecoveryEntry) {
        recoveryEntries.append(entry)
        checkAchievements()
    }

    private func formattedToday() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: Date())
    }
}

struct ChatMessage: Identifiable, Codable {
    var id: UUID = UUID()
    var role: String  // "user" or "assistant"
    var content: String
}
