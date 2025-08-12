//
//  WorkoutModels.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import Foundation

struct Exercise: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var isCustom: Bool = false
}

struct WorkoutLog: Codable, Identifiable {
    let id = UUID()
    var date: Date
    var weight: Double
    var reps: Int
    
    var displayString: String {
        let weightString: String
        if floor(weight) == weight {
            weightString = String(format: "%.0f", weight)
        } else {
            weightString = String(format: "%.1f", weight)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        let dateString = dateFormatter.string(from: date)
        
        return "\(weightString) kg × \(reps) reps – \(dateString)"
    }
}


extension Date {
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    static func from(string: String, format: String = "yyyy-MM-dd") -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string) ?? Date()
    }
}


struct MeasurementType: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var unit: String
    var isCustom: Bool = false
    var iconName: String
}

struct MeasurementLog: Codable, Identifiable {
    let id = UUID()
    var date: Date
    var value: Double
    
    func displayString(unit: String) -> String {
        let valueString: String
        if floor(value) == value {
            valueString = String(format: "%.0f", value)
        } else {
            valueString = String(format: "%.1f", value)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d" // Формат "Jul 8"
        let dateString = dateFormatter.string(from: date)
        
        return "\(valueString) \(unit) – \(dateString)"
    }
}

import Foundation

struct SportNote: Codable, Identifiable {
    let id: UUID
    var title: String
    var content: String
    var tag: String?
    var createdAt: Date
}
