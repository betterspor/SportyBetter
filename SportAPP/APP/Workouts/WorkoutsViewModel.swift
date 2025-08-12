//
//  WorkoutsViewModel.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//


import Foundation

@MainActor
class WorkoutsViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var workoutHistory: [String: [WorkoutLog]] = [:]
    
    @Published var selectedExercise: Exercise?
    @Published var isAddWorkoutSheetPresented = false
    @Published var isAddCustomExerciseSheetPresented = false
    
    private let exercisesKey = "user_exercises"
    private let historyKey = "workout_history"
    
    init() {
        loadData()
        NotificationCenter.default.addObserver(
                   self,
                   selector: #selector(handleDataReset),
                   name: .didRequestDataReset,
                   object: nil
               )
    }
    
    @objc private func handleDataReset() {
           self.exercises = []
           self.workoutHistory = [:]
           loadData()
       }
    
    func loadData() {
        let savedExercises = loadExercises()
        if savedExercises.isEmpty {
            self.exercises = baseExercises
        } else {
            self.exercises = (baseExercises + savedExercises).sorted { !$0.isCustom && $1.isCustom }
        }
        self.workoutHistory = loadWorkoutHistory()
    }
    
    func getLatestLog(for exercise: Exercise) -> WorkoutLog? {
        return workoutHistory[exercise.id]?.sorted(by: { $0.date > $1.date }).first
    }
    
    func saveLog(for exercise: Exercise, date: Date, weight: Double, reps: Int) {
        let newLog = WorkoutLog(date: date, weight: weight, reps: reps)
        
        var history = workoutHistory[exercise.id, default: []]
        history.append(newLog)
        workoutHistory[exercise.id] = history
        
        saveWorkoutHistory()
    }
    
    func addCustomExercise(name: String) {
        let newExercise = Exercise(id: UUID().uuidString, name: name, isCustom: true)
        exercises.append(newExercise)
        saveExercises()
    }
    
    private func saveExercises() {
        let customExercises = exercises.filter { $0.isCustom }
        if let data = try? JSONEncoder().encode(customExercises) {
            UserDefaults.standard.set(data, forKey: exercisesKey)
        }
    }
    
    private func loadExercises() -> [Exercise] {
        guard let data = UserDefaults.standard.data(forKey: exercisesKey),
              let exercises = try? JSONDecoder().decode([Exercise].self, from: data) else {
            return []
        }
        return exercises
    }
    
    private func saveWorkoutHistory() {
        if let data = try? JSONEncoder().encode(workoutHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
    
    private func loadWorkoutHistory() -> [String: [WorkoutLog]] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([String: [WorkoutLog]].self, from: data) else {
            return [:]
        }
        return history
    }
    
    private let baseExercises: [Exercise] = [
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
