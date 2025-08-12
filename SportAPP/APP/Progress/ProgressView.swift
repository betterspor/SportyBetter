//
//  ProgressView.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import SwiftUI
import Charts

struct NewProgressView: View {
    @StateObject private var viewModel = ProgressViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Progress")
                    .font(.largeTitle).bold()
                    .padding([.horizontal, .top])
                
                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.vertical, 100)
                } else if viewModel.progressStats.totalWorkouts == 0 {
                    EmptyStateView()
                } else {
                    content
                }
            }
            .padding(.bottom, 120)
        }
        .foregroundColor(.themePrimaryText)
        .background(Color.themeBackground.ignoresSafeArea())
        .onAppear(perform: viewModel.refreshData)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            AtAGlanceCard(stats: viewModel.progressStats)
            PersonalRecordsCard(records: viewModel.progressStats.personalRecords)
            StrengthRatingCard(ratingText: viewModel.strengthRating)
            MuscleGroupFocusCard(data: viewModel.progressStats.muscleGroupFocus)
            TotalVolumeCard(data: viewModel.monthlyVolumeData)
            ExerciseProgressionCard(
                data: viewModel.exerciseProgressionData,
                availableExercises: viewModel.exercisesWithHistoryNames,
                selectedExercise: $viewModel.selectedExerciseName
            )
        }
    }
}

private struct AtAGlanceCard: View {
    let stats: ProgressStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("At a Glance").font(.title2).bold()
            HStack(spacing: 16) {
                StatItem(value: "\(stats.totalWorkouts)", label: "Workouts")
                if let heaviest = stats.heaviestLift {
                    StatItem(value: "\(Int(heaviest.log.weight)) kg", label: heaviest.name)
                }
            }
        }
        .cardStyle()
    }
}

private struct StatItem: View {
    let value: String
    let label: String
    var body: some View {
        VStack {
            Text(value).font(.headline).bold().foregroundColor(.themeAccentRed)
            Text(label).font(.caption).foregroundColor(.themeSecondaryText).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PersonalRecordsCard: View {
    let records: [PersonalRecord]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personal Records").font(.title2).bold()
            if records.isEmpty {
                Text("Log workouts for Bench, Squat or Deadlift to see your PRs.")
                    .font(.caption).foregroundColor(.themeSecondaryText)
            } else {
                ForEach(records) { record in
                    HStack {
                        Text(record.exerciseName).font(.headline)
                        Spacer()
                        Text(record.bestLog.displayString).foregroundColor(.themeSecondaryText)
                    }
                }
            }
        }
        .cardStyle()
    }
}

private struct MuscleGroupFocusCard: View {
    let data: [MuscleGroupFocus]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Muscle Group Focus").font(.title2).bold()
            Text("Based on your logged workouts").font(.caption).foregroundColor(.themeSecondaryText)
            
            if data.filter({ $0.count > 0 }).isEmpty {
                PlaceholderChartView(message: "Log workouts to see your muscle focus.")
            } else {
                Chart(data) { item in
                    if #available(iOS 17.0, *) {
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.618),
                            angularInset: 2
                        )
                        .cornerRadius(5)
                        .foregroundStyle(by: .value("Muscle Group", item.name))
                    } else {
                        // Fallback for iOS 16
                        BarMark(
                            x: .value("Count", item.count),
                            y: .value("Muscle Group", item.name)
                        )
                        .foregroundStyle(by: .value("Muscle Group", item.name))
                    }
                }
                .chartLegend(position: .bottom, alignment: .center)
                .frame(height: 200)
            }
        }
        .cardStyle()
    }
}

private struct TotalVolumeCard: View {
    let data: [MonthlyVolume]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Volume").font(.title2).bold()
            Text("Sum of weight × reps across all workouts").font(.caption).foregroundColor(.themeSecondaryText)
            
            if data.isEmpty {
                PlaceholderChartView(message: "Log your workouts to see your volume.")
            } else {
                Chart(data) { item in
                    BarMark(x: .value("Month", item.month), y: .value("Volume (kg)", item.totalVolume))
                        .foregroundStyle(Color.themeAccentRed.gradient)
                }
                .chartStyle()
            }
        }
        .cardStyle()
    }
}

private struct BMICard: View {
    let result: (value: Double, category: String, color: Color)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Body Mass Index (BMI)").font(.title2).bold()
            
            if let result = result {
                HStack {
                    VStack(alignment: .leading) {
                        Text(String(format: "%.1f", result.value))
                            .font(.system(size: 48, weight: .bold))
                        Text(result.category)
                            .font(.headline)
                            .foregroundColor(result.color)
                    }
                    Spacer()
                    // TODO: Add gauge chart here if needed
                }
            } else {
                Text("Add your Height and Weight in the Measurements tab to calculate BMI.")
                    .font(.caption)
                    .foregroundColor(.themeSecondaryText)
            }
        }
        .cardStyle()
    }
}

private struct StrengthRatingCard: View {
    let ratingText: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Strength Rating").font(.title2).bold()
            Text("Based on body weight and lifts").font(.caption).foregroundColor(.themeSecondaryText)
            
            Text(ratingText ?? "No data available.")
                .font(.headline)
                .padding(.top)
        }
        .frame(width: size().width - 70, alignment: .leading)
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

private struct ExerciseProgressionCard: View {
    let data: [WorkoutLog]
    let availableExercises: [String]
    @Binding var selectedExercise: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Exercise Progression").font(.title2).bold()
            
            if !availableExercises.isEmpty {
                Picker("Select Exercise", selection: $selectedExercise) {
                    ForEach(availableExercises, id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
                .accentColor(.themeAccentRed)
            }
            
            if data.isEmpty {
                PlaceholderChartView(message: "No progression data for this exercise yet.")
            } else {
                Chart(data) { log in
                    LineMark(x: .value("Date", log.date), y: .value("Weight", log.weight))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Color.themeAccentRed)
                    
                    PointMark(x: .value("Date", log.date), y: .value("Weight", log.weight))
                        .foregroundStyle(Color.themeAccentRed)
                }
                .chartStyle()
            }
        }
        .cardStyle()
    }
}


private struct PlaceholderChartView: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.themeSecondaryText)
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .center)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(Color.themeCardBackground).frame(width: 120, height: 120)
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .renderingMode(.template)
                    .font(.system(size: 48))
                    .foregroundColor(.themeAccentRed)
            }
            .padding(.top, size().height > 667 ? 170 : 50)
            Text("No Data Yet").font(.title).bold()
            Text("Track your workouts and measurements to unlock progress charts!")
                .font(.body)
                .foregroundColor(.themeSecondaryText)
                .multilineTextAlignment(.center)
                
            
            Spacer()
        }
        .frame(width: size().width)
    }
}

private struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.themeCardBackground)
            .cornerRadius(16)
            .padding(.horizontal)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}

extension Chart {
    func chartStyle() -> some View {
        self.frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine().foregroundStyle(Color.themeSecondaryBackground)
                    AxisValueLabel().foregroundStyle(Color.themeSecondaryText)
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisGridLine().foregroundStyle(Color.clear)
                    AxisValueLabel(format: .dateTime.month().day()).foregroundStyle(Color.themeSecondaryText)
                }
            }
    }
}

#Preview {
    NewProgressView()
}
