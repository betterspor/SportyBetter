//
//  ProgressViewModel.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import Foundation
import SwiftUI

struct MonthlyVolume: Identifiable {
    let id = UUID()
    let month: String
    let date: Date
    let totalVolume: Double
}

struct ProgressStats {
    var totalWorkouts: Int = 0
    var heaviestLift: (name: String, log: WorkoutLog)?
    var personalRecords: [PersonalRecord] = []
    var weightChange: (first: Double, last: Double)?
    var workoutDates: Set<Date> = []
    var muscleGroupFocus: [MuscleGroupFocus] = []
}

struct PersonalRecord: Identifiable {
    let id: UUID = UUID()
    let exerciseName: String
    let bestLog: WorkoutLog
}

struct MuscleGroupFocus: Identifiable {
    let id: String
    var name: String
    var count: Int
}

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var isLoading = true
    
    @Published var monthlyVolumeData: [MonthlyVolume] = []
    @Published var bmiResult: (value: Double, category: String, color: Color)?
    @Published var strengthRating: String?
    @Published var progressStats: ProgressStats = ProgressStats()
    
    @Published var exerciseProgressionData: [WorkoutLog] = []
    @Published var exercisesWithHistoryNames: [String] = []
    @Published var selectedExerciseName: String = "" {
        didSet {
            updateExerciseProgressionChart()
        }
    }
    
    private var fullWorkoutHistory: [String: [WorkoutLog]] = [:]
    private var allExercises: [Exercise] = []
    private var measurementLogs: [String: MeasurementLog] = [:]
    
    init() {
          
           NotificationCenter.default.addObserver(
               self,
               selector: #selector(handleDataReset),
               name: .didRequestDataReset,
               object: nil
           )
       }
    
    @objc private func handleDataReset() {
           refreshData()
       }
    
    func refreshData() {
        isLoading = true
        Task(priority: .userInitiated) {
            let loadedData = await loadAllDataFromUserDefaults()
            
            let calculatedVolume = await calculateMonthlyVolume(from: loadedData.history)
            let calculatedBMI = await calculateBMI(from: loadedData.measurements)
            let calculatedStrength = await calculateStrengthRating(from: loadedData.history, userWeight: loadedData.measurements["weight"]?.value)
            let calculatedStats = await calculateProgressStats(history: loadedData.history, exercises: loadedData.exercises, measurements: loadedData.measurements)
            
            DispatchQueue.main.async {
                self.fullWorkoutHistory = loadedData.history
                self.allExercises = loadedData.exercises
                self.measurementLogs = loadedData.measurements
                
                self.monthlyVolumeData = calculatedVolume
                self.bmiResult = calculatedBMI
                self.strengthRating = calculatedStrength
                self.progressStats = calculatedStats
                
                self.exercisesWithHistoryNames = self.fullWorkoutHistory.keys
                    .compactMap { id in self.allExercises.first { $0.id == id }?.name }
                    .sorted()
                
                if !self.exercisesWithHistoryNames.contains(self.selectedExerciseName), let first = self.exercisesWithHistoryNames.first {
                    self.selectedExerciseName = first
                } else {
                    self.updateExerciseProgressionChart()
                }
                
                self.isLoading = false
            }
        }
    }
    
    private func updateExerciseProgressionChart() {
        guard let exerciseId = allExercises.first(where: { $0.name == selectedExerciseName })?.id else {
            self.exerciseProgressionData = []
            return
        }
        self.exerciseProgressionData = fullWorkoutHistory[exerciseId]?.sorted { $0.date < $1.date } ?? []
    }
    
    // MARK: - Async Calculations
    
    private func loadAllDataFromUserDefaults() async -> (history: [String: [WorkoutLog]], exercises: [Exercise], measurements: [String: MeasurementLog]) {
        let history = loadData(forKey: "workout_history", type: [String: [WorkoutLog]].self) ?? [:]
        
        let baseExercises = getBaseExercises()
        let customExercises = loadData(forKey: "user_exercises", type: [Exercise].self) ?? []
        let allExercises = baseExercises + customExercises
        
        let measurements = loadData(forKey: "measurement_logs", type: [String: MeasurementLog].self) ?? [:]
        
        return (history, allExercises, measurements)
    }
    
    private func calculateMonthlyVolume(from history: [String: [WorkoutLog]]) async -> [MonthlyVolume] {
        let allLogs = history.values.flatMap { $0 }
        let groupedByMonth = Dictionary(grouping: allLogs) { Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: $0.date))! }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        return groupedByMonth.map { (monthDate, logs) in
            let totalVolume = logs.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
            return MonthlyVolume(month: formatter.string(from: monthDate), date: monthDate, totalVolume: totalVolume)
        }.sorted { $0.date < $1.date }
    }
    
    private func calculateBMI(from measurements: [String: MeasurementLog]) async -> (value: Double, category: String, color: Color)? {
        guard let userHeight = measurements["height"]?.value, userHeight > 0,
              let userWeight = measurements["weight"]?.value else {
            return nil
        }
        let heightInMeters = userHeight / 100
        let bmiValue = userWeight / (heightInMeters * heightInMeters)
        let (category, color): (String, Color) = {
            switch bmiValue {
            case ..<18.5: return ("Underweight", .blue)
            case 18.5..<25: return ("Normal", .green)
            case 25..<30: return ("Overweight", .orange)
            default: return ("Obese", .themeAccentRed)
            }
        }()
        return (bmiValue, category, color)
    }

    private func calculateStrengthRating(from history: [String: [WorkoutLog]], userWeight: Double?) async -> String? {
        guard let userWeight = userWeight,
              let benchHistory = history["bench_press"],
              let bestBench = benchHistory.max(by: { $0.weight < $1.weight }) else {
            return "Track Bench Press & Weight to see rating."
        }
        let ratio = bestBench.weight / userWeight
        let rating: String = {
            switch ratio {
            case ..<1.0: return "Beginner"
            case 1.0..<1.5: return "Intermediate"
            case 1.5..<2.0: return "Advanced"
            default: return "Elite"
            }
        }()
        return "Bench: \(Int(bestBench.weight)) kg at \(Int(userWeight)) kg body weight → \(rating)"
    }

    private func calculateProgressStats(history: [String: [WorkoutLog]], exercises: [Exercise], measurements: [String: MeasurementLog]) async -> ProgressStats {
        let allLogs = history.values.flatMap { $0 }
        var stats = ProgressStats()
        
        stats.totalWorkouts = Set(allLogs.map { Calendar.current.startOfDay(for: $0.date) }).count
        
        if let heaviestLog = allLogs.max(by: { $0.weight < $1.weight }) {
            let exerciseIdForHeaviestLift = history.first { $0.value.contains(where: { $0.id == heaviestLog.id }) }?.key
            let exerciseName = exercises.first { $0.id == exerciseIdForHeaviestLift }?.name ?? "Unknown"
            stats.heaviestLift = (name: exerciseName, log: heaviestLog)
        }
        
        let prExercises = ["bench_press", "barbell_squat", "deadlift"]
        stats.personalRecords = prExercises.compactMap { id in
            guard let exerciseName = exercises.first(where: { $0.id == id })?.name,
                  let bestLog = history[id]?.max(by: { $0.weight < $1.weight }) else {
                return nil
            }
            return PersonalRecord(exerciseName: exerciseName, bestLog: bestLog)
        }
        
        stats.workoutDates = Set(allLogs.map { Calendar.current.startOfDay(for: $0.date) })
        stats.muscleGroupFocus = getMuscleGroupFocus(from: history, exercises: exercises)
        
        return stats
    }
    // MARK: - Helpers
    private func getMuscleGroupFocus(from history: [String: [WorkoutLog]], exercises: [Exercise]) -> [MuscleGroupFocus] {
        var counts: [String: Int] = ["Chest": 0, "Legs": 0, "Back": 0, "Arms": 0]
        for (exerciseId, logs) in history {
            guard let group = exerciseToMuscleGroup[exerciseId] else { continue }
            counts[group, default: 0] += logs.count
        }
        return counts.map { MuscleGroupFocus(id: $0.key, name: $0.key, count: $0.value) }
    }
    
    private let exerciseToMuscleGroup: [String: String] = [
        "bench_press": "Chest", "push_ups": "Chest",
        "barbell_squat": "Legs", "deadlift": "Legs",
        "pull_ups": "Back", "bent_over_row": "Back", "lat_pulldown": "Back",
        "dumbbell_curl": "Arms", "triceps_extension": "Arms", "overhead_press": "Arms"
    ]
    
    private func loadData<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func getBaseExercises() -> [Exercise] {
        return [
            Exercise(id: "bench_press", name: "Bench Press"),
            Exercise(id: "barbell_squat", name: "Barbell Squat"),
            Exercise(id: "deadlift", name: "Deadlift"),
            Exercise(id: "overhead_press", name: "Overhead Press"),
            Exercise(id: "pull_ups", name: "Pull-Ups"),
            Exercise(id: "bent_over_row", name: "Bent-over Row"),
            Exercise(id: "lat_pulldown", name: "Lat Pulldown"),
            Exercise(id: "dumbbell_curl", name: "Dumbbell Curl"),
            Exercise(id: "triceps_extension", name: "Triceps Extension"),
            Exercise(id: "plank", name: "Plank"),
            Exercise(id: "push_ups", name: "Push-Ups")
        ]
    }
}
