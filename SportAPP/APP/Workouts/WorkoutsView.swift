//
//  WorkoutsView.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import SwiftUI

#Preview {
    WorkoutsView()
}

struct WorkoutsView: View {
    @StateObject private var viewModel = WorkoutsViewModel()
    @State private var isSettingsPresented = false
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                HStack {
                    Text("My Workouts")
                        .font(.largeTitle).bold()
                    Spacer()
                    Button(action: { isSettingsPresented = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title)
                            .foregroundColor(.themeSecondaryText)
                    }
                }
                .padding()
                
                ScrollView {
                    ForEach(viewModel.exercises) { exercise in
                        ExerciseCell(
                            exercise: exercise,
                            log: viewModel.getLatestLog(for: exercise)
                        )
                        .onTapGesture {
                            viewModel.selectedExercise = exercise
                            viewModel.isAddWorkoutSheetPresented = true
                        }
                    }
                    
                    AddCustomExerciseButton {
                        viewModel.isAddCustomExerciseSheetPresented = true
                    }
                }
            }
            .foregroundColor(.themePrimaryText)
            
            if viewModel.isAddWorkoutSheetPresented, let exercise = viewModel.selectedExercise {
                AddWorkoutOverlayView(
                    isPresented: $viewModel.isAddWorkoutSheetPresented,
                    exercise: exercise,
                    log: viewModel.getLatestLog(for: exercise),
                    onSave: { date, weight, reps in
                        viewModel.saveLog(for: exercise, date: date, weight: weight, reps: reps)
                    }
                )
            }
            
            if viewModel.isAddCustomExerciseSheetPresented {
                AddCustomExerciseOverlayView(
                    isPresented: $viewModel.isAddCustomExerciseSheetPresented,
                    onSave: { name in
                        viewModel.addCustomExercise(name: name)
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $isSettingsPresented) {
            SettingsView()
        }
    }
}

private struct ExerciseCell: View {
    let exercise: Exercise
    let log: WorkoutLog?
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: "dumbbell.fill")
                    .padding(12)
                    .colorMultiply(.themeAccentRed)
                    .background(Color.themeSecondaryBackground)
                    .frame(height: 35)
                
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.headline)
                    Text(log?.displayString ?? "No data yet")
                        .font(.caption)
                        .foregroundColor(.themeSecondaryText)
                }
                
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
        }
        .background(Color.themeCardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct AddCustomExerciseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Add Custom Exercise", systemImage: "plus")
                .font(.headline)
                .foregroundColor(.themeAccentRed)
                .padding()
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.themeAccentRed)
                )
        }
        .padding()
    }
}
