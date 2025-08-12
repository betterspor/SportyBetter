//
//  AddWorkoutOverlayView.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import SwiftUI

struct AddWorkoutOverlayView: View {
    @Binding var isPresented: Bool
    let exercise: Exercise
    let log: WorkoutLog?
    let onSave: (Date, Double, Int) -> Void
    
    @State private var date: Date
    @State private var weight: Double
    @State private var reps: Int
    @State private var isAnimating = false
    
    init(isPresented: Binding<Bool>, exercise: Exercise, log: WorkoutLog?, onSave: @escaping (Date, Double, Int) -> Void) {
        self._isPresented = isPresented
        self.exercise = exercise
        self.log = log
        self.onSave = onSave
        
        _date = State(initialValue: log?.date ?? Date())
        _weight = State(initialValue: log?.weight ?? 70.0)
        _reps = State(initialValue: log?.reps ?? 8)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(alignment: .leading, spacing: 20) {
                HeaderView(title: "Add Workout") { isPresented = false }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Date")
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .padding(.horizontal)
                        .frame(height: 50)
                        .background(Color.themeBackground)
                        .cornerRadius(12)
                        .colorScheme(.dark)
                    
                    StepperView(title: "Weight (kg)", value: $weight, step: 2.5, format: "%.1f")
                    StepperView(title: "Reps", value: Binding(
                        get: { Double(reps) },
                        set: { reps = Int($0) }
                    ), step: 1, format: "%.0f")
                }
                
                Button(action: {
                    onSave(date, weight, reps)
                    isPresented = false
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(24)
            .background(Color.themeCardBackground)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(30)
            .foregroundColor(.themePrimaryText)
            .scaleEffect(isAnimating ? 1 : 0.9).opacity(isAnimating ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

struct AddCustomExerciseOverlayView: View {
    @Binding var isPresented: Bool
    let onSave: (String) -> Void
    
    @State private var name: String = ""
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(alignment: .leading, spacing: 20) {
                HeaderView(title: "Add Custom Exercise") { isPresented = false }
                
                TextField("Exercise Name", text: $name)
                    .padding()
                    .background(Color.themeBackground)
                    .cornerRadius(12)
                
                Button(action: {
                    if !name.isEmpty {
                        onSave(name)
                        isPresented = false
                    }
                }) {
                    Label("Save", systemImage: "plus")
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(name.isEmpty)
            }
            .padding(24)
            .background(Color.themeCardBackground)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(30)
            .foregroundColor(.themePrimaryText)
            .scaleEffect(isAnimating ? 1 : 0.9).opacity(isAnimating ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

private struct HeaderView: View {
    let title: String
    let onDismiss: () -> Void
    var body: some View {
        HStack {
            Text(title).font(.title2).bold()
            Spacer()
            Button(action: onDismiss) { Image(systemName: "xmark") }
        }
    }
}

private struct StepperView: View {
    let title: String
    @Binding var value: Double
    let step: Double
    let format: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            HStack {
                Button(action: { value -= step }) { Image(systemName: "minus") }
                Spacer()
                Text(String(format: format, value))
                Spacer()
                Button(action: { value += step }) { Image(systemName: "plus") }
            }
            .padding(.horizontal)
            .frame(height: 50)
            .background(Color.themeBackground)
            .cornerRadius(12)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.themeAccentRed)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
    }
}
