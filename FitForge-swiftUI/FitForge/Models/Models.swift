import Foundation
import SwiftUI

// MARK: - Character Models

struct Character: Codable, Equatable {
    var name: String
    var race: String
    var physiqueClass: String
    var goal: String
    var workoutStyle: String
}

struct Race: Identifiable {
    let id: String
    let name: String
    let icon: String
    let bonus: String
    let desc: String
}

struct PhysiqueClass: Identifiable {
    let id: String
    let label: String
    let icon: String
    let desc: String
}

struct FitnessGoal: Identifiable {
    let id: String
    let label: String
    let icon: String
    let desc: String
}

struct WorkoutStyle: Identifiable {
    let id: String
    let label: String
    let icon: String
}

// MARK: - Nutrition Models

struct Meal: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var calories: Double
    var protein: Double
    var fiber: Double
    var category: String
    var time: String
}

struct MacroGoals: Codable {
    var calories: Double = 2400
    var protein: Double = 180
    var fiber: Double = 30
}

// MARK: - Workout Models

struct Exercise: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var sets: Int
    var reps: String
    var weight: Double
    var completedSets: [CompletedSet] = []
}

struct CompletedSet: Codable {
    var reps: String
    var weight: String
}

struct WorkoutSession: Identifiable, Codable {
    var id: UUID = UUID()
    var workout: String
    var date: Date
    var exercises: [Exercise]
}

struct WorkoutTemplate {
    let name: String
    let days: [String]
    let exercises: [String: [Exercise]]
}

// MARK: - Weight Models

struct WeightEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var date: String
    var weight: Double
}

// MARK: - Recovery Models

struct RecoveryEntry: Codable {
    var sleep: Double
    var soreness: Int
    var energy: Int
    var notes: String
    var date: Date
}

// MARK: - Achievement Models

struct Achievement: Identifiable {
    let id: String
    let icon: String
    let title: String
    let desc: String
    let category: String
}

// MARK: - Static Data

let allRaces: [Race] = [
    Race(id: "nord",     name: "Nord",      icon: "🧊", bonus: "Cold Resistance",      desc: "Born warriors of Skyrim. +10% Stamina gains."),
    Race(id: "imperial", name: "Imperial",  icon: "🛡️", bonus: "Voice of the Emperor", desc: "Disciplined and balanced. +10% all macro targets."),
    Race(id: "breton",   name: "Breton",    icon: "✨", bonus: "Dragonskin",            desc: "Half-Mer scholars. +10% recovery efficiency."),
    Race(id: "redguard", name: "Redguard",  icon: "⚔️", bonus: "Adrenaline Rush",      desc: "Master swordsmen. +10% protein synthesis."),
    Race(id: "dunmer",   name: "Dark Elf",  icon: "🔥", bonus: "Ancestor's Wrath",     desc: "Swift and cunning. +10% calorie burn rate."),
    Race(id: "altmer",   name: "High Elf",  icon: "🌟", bonus: "Highborn",              desc: "Magically gifted. +10% fiber absorption."),
    Race(id: "orsimer",  name: "Orc",       icon: "💪", bonus: "Berserker Rage",        desc: "Savage power. +15% muscle growth potential."),
    Race(id: "argonian", name: "Argonian",  icon: "🦎", bonus: "Histskin",              desc: "Natural regenerators. +10% recovery speed."),
    Race(id: "khajiit",  name: "Khajiit",   icon: "🐱", bonus: "Night Eye",             desc: "Agile hunters. +10% mobility progress."),
    Race(id: "bosmer",   name: "Wood Elf",  icon: "🌿", bonus: "Beast Tongue",          desc: "Fleet-footed archers. +10% cardio efficiency."),
]

let allPhysiqueClasses: [PhysiqueClass] = [
    PhysiqueClass(id: "warrior",   label: "Warrior",   icon: "⚔️", desc: "Dense muscle, raw power, built for battle"),
    PhysiqueClass(id: "ranger",    label: "Ranger",    icon: "🏹", desc: "Lean, athletic, agile — speed and endurance"),
    PhysiqueClass(id: "knight",    label: "Knight",    icon: "🛡️", desc: "Bulky and armored — maximum size and strength"),
    PhysiqueClass(id: "assassin",  label: "Assassin",  icon: "🗡️", desc: "Shredded and defined — low body fat, visible cuts"),
    PhysiqueClass(id: "paladin",   label: "Paladin",   icon: "✨", desc: "Balanced physique — strength meets aesthetics"),
    PhysiqueClass(id: "berserker", label: "Berserker", icon: "💪", desc: "Massive and powerful — pure hypertrophy"),
]

let allGoals: [FitnessGoal] = [
    FitnessGoal(id: "muscle",    label: "Forge Muscle",    icon: "💪", desc: "Build mass and raw strength"),
    FitnessGoal(id: "mobility",  label: "Master Mobility", icon: "🤸", desc: "Flexibility and range of motion"),
    FitnessGoal(id: "athletic",  label: "Athletic Build",  icon: "⚡", desc: "Speed, power and endurance"),
    FitnessGoal(id: "cut",       label: "Cut & Define",    icon: "🗡️", desc: "Reduce fat, reveal the warrior"),
    FitnessGoal(id: "endurance", label: "Endurance",       icon: "🏃", desc: "Stamina for long campaigns"),
]

let allWorkoutStyles: [WorkoutStyle] = [
    WorkoutStyle(id: "gym",  label: "Gym & Iron",    icon: "🏋️"),
    WorkoutStyle(id: "home", label: "Home Training", icon: "🏠"),
    WorkoutStyle(id: "both", label: "Both Realms",   icon: "⚔️"),
]

let allAchievements: [Achievement] = [
    Achievement(id: "first_meal",     icon: "🍖", title: "First Ration",          desc: "Log your first meal",                   category: "nutrition"),
    Achievement(id: "macro_hit",      icon: "🎯", title: "Perfectly Balanced",    desc: "Hit all 3 macro targets in one day",    category: "nutrition"),
    Achievement(id: "feast",          icon: "🏰", title: "Feast of Sovngarde",    desc: "Log 5 or more meals in one day",        category: "nutrition"),
    Achievement(id: "first_workout",  icon: "⚔️", title: "First Shout",           desc: "Log your first workout session",        category: "training"),
    Achievement(id: "iron_will",      icon: "🛡️", title: "Iron Will",             desc: "Complete a full week of training",      category: "training"),
    Achievement(id: "streak_3",       icon: "🔥", title: "Flame Kindled",         desc: "Maintain a 3-day streak",               category: "streak"),
    Achievement(id: "streak_7",       icon: "🔥", title: "Dragon's Persistence",  desc: "Maintain a 7-day streak",               category: "streak"),
    Achievement(id: "streak_30",      icon: "🔥", title: "Throat of the World",   desc: "Maintain a 30-day streak",              category: "streak"),
    Achievement(id: "streak_100",     icon: "👑", title: "Legendary Dragonborn",  desc: "Maintain a 100-day streak",             category: "streak"),
    Achievement(id: "first_recovery", icon: "🌙", title: "Rest of the Nord",      desc: "Log your first recovery entry",         category: "recovery"),
    Achievement(id: "well_rested",    icon: "😴", title: "Well Rested",           desc: "Log 8+ hours of sleep",                 category: "recovery"),
    Achievement(id: "weight_logged",  icon: "⚖️", title: "The Scales Speak",     desc: "Log weight 7 times",                    category: "progress"),
    Achievement(id: "char_born",      icon: "🐉", title: "Dovahkiin Awakens",     desc: "Complete character creation",           category: "general"),
    Achievement(id: "paarthurnax",    icon: "🐉", title: "Audience with Paarthurnax", desc: "Have your first conversation",      category: "general"),
]

let workoutTemplates: [String: WorkoutTemplate] = [
    "ppl": WorkoutTemplate(
        name: "Push / Pull / Legs",
        days: ["Push","Pull","Legs","Push","Pull","Legs","Rest"],
        exercises: [
            "Push": [
                Exercise(name: "Bench Press", sets: 4, reps: "8-10", weight: 135),
                Exercise(name: "Overhead Press", sets: 3, reps: "8-10", weight: 75),
                Exercise(name: "Tricep Dips", sets: 3, reps: "10-12", weight: 0),
            ],
            "Pull": [
                Exercise(name: "Deadlift", sets: 4, reps: "5-6", weight: 185),
                Exercise(name: "Pull-Ups", sets: 3, reps: "8-10", weight: 0),
                Exercise(name: "Barbell Row", sets: 3, reps: "8-10", weight: 115),
            ],
            "Legs": [
                Exercise(name: "Squat", sets: 4, reps: "8-10", weight: 155),
                Exercise(name: "Romanian Deadlift", sets: 3, reps: "10-12", weight: 115),
                Exercise(name: "Calf Raises", sets: 4, reps: "15-20", weight: 0),
            ],
            "Rest": []
        ]
    ),
    "upperlower": WorkoutTemplate(
        name: "Upper / Lower Split",
        days: ["Upper","Lower","Rest","Upper","Lower","Rest","Rest"],
        exercises: [
            "Upper": [
                Exercise(name: "Bench Press", sets: 4, reps: "6-8", weight: 145),
                Exercise(name: "Pull-Ups", sets: 4, reps: "8-10", weight: 0),
                Exercise(name: "Shoulder Press", sets: 3, reps: "10-12", weight: 65),
            ],
            "Lower": [
                Exercise(name: "Squat", sets: 4, reps: "6-8", weight: 165),
                Exercise(name: "Leg Press", sets: 3, reps: "12-15", weight: 250),
                Exercise(name: "Hip Thrust", sets: 3, reps: "12", weight: 135),
            ],
            "Rest": []
        ]
    ),
    "fullbody": WorkoutTemplate(
        name: "Full Body Athletic",
        days: ["Full Body","Rest","Full Body","Rest","Full Body","Rest","Rest"],
        exercises: [
            "Full Body": [
                Exercise(name: "Power Clean", sets: 4, reps: "4-5", weight: 115),
                Exercise(name: "Front Squat", sets: 3, reps: "6-8", weight: 115),
                Exercise(name: "Pull-Ups", sets: 3, reps: "8-10", weight: 0),
                Exercise(name: "Push-Ups", sets: 3, reps: "15-20", weight: 0),
            ],
            "Rest": []
        ]
    ),
]

let mealCategories = [
    ("breakfast", "Breakfast", "🌅"),
    ("lunch",     "Lunch",     "☀️"),
    ("dinner",    "Dinner",    "🌙"),
    ("snacks",    "Snacks",    "⚔️"),
]

let compoundExercises = ["bench press","deadlift","squat","overhead press","barbell row","power clean","front squat","romanian deadlift","hip thrust","leg press","pull-ups"]

func isCompound(_ name: String) -> Bool {
    compoundExercises.contains { name.lowercased().contains($0.split(separator: " ").first.map(String.init) ?? "") }
}
