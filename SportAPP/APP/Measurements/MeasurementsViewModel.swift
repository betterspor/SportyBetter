//
//  MeasurementsViewModel.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import Foundation

@MainActor
class MeasurementsViewModel: ObservableObject {
    @Published var measurementTypes: [MeasurementType] = []
    @Published var measurementLogs: [String: MeasurementLog] = [:]
    
    @Published var selectedMeasurement: MeasurementType?
    @Published var isAddLogSheetPresented = false
    @Published var isAddCustomSheetPresented = false
    
    private let typesKey = "measurement_types"
    private let logsKey = "measurement_logs"
    
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
           self.measurementTypes = []
           self.measurementLogs = [:]
           loadData()
       }
    
    func loadData() {
        let savedTypes = loadTypes()
        if savedTypes.isEmpty {
            self.measurementTypes = baseMeasurementTypes
        } else {
            self.measurementTypes = (baseMeasurementTypes + savedTypes).sorted { !$0.isCustom && $1.isCustom }
        }
        self.measurementLogs = loadLogs()
    }
    
    func saveLog(for type: MeasurementType, date: Date, value: Double) {
        let log = MeasurementLog(date: date, value: value)
        measurementLogs[type.id] = log
        saveLogs()
    }
    
    func addCustomMeasurement(name: String, unit: String) {
        let newType = MeasurementType(id: UUID().uuidString, name: name, unit: unit, isCustom: true, iconName: "ruler")
        measurementTypes.append(newType)
        saveTypes()
    }
    
    private func saveTypes() {
        let customTypes = measurementTypes.filter { $0.isCustom }
        if let data = try? JSONEncoder().encode(customTypes) {
            UserDefaults.standard.set(data, forKey: typesKey)
        }
    }
    
    private func loadTypes() -> [MeasurementType] {
        guard let data = UserDefaults.standard.data(forKey: typesKey),
              let types = try? JSONDecoder().decode([MeasurementType].self, from: data) else {
            return []
        }
        return types
    }
    
    private func saveLogs() {
        if let data = try? JSONEncoder().encode(measurementLogs) {
            UserDefaults.standard.set(data, forKey: logsKey)
        }
    }
    
    private func loadLogs() -> [String: MeasurementLog] {
        guard let data = UserDefaults.standard.data(forKey: logsKey),
              let logs = try? JSONDecoder().decode([String: MeasurementLog].self, from: data) else {
            return [:]
        }
        return logs
    }
    
    private let baseMeasurementTypes: [MeasurementType] = [
        MeasurementType(id: "height", name: "Height", unit: "cm", iconName: "ruler"),
        MeasurementType(id: "weight", name: "Weight", unit: "kg", iconName: "ruler"),
        MeasurementType(id: "age", name: "Age", unit: "years", iconName: "ruler"),
        MeasurementType(id: "shoulders", name: "Shoulders", unit: "cm", iconName: "ruler"),
        MeasurementType(id: "chest", name: "Chest", unit: "cm", iconName: "ruler"),
        MeasurementType(id: "neck", name: "Neck", unit: "cm", iconName: "ruler"),
        MeasurementType(id: "waist", name: "Waist", unit: "cm", iconName: "ruler"),
        MeasurementType(id: "hips", name: "Hips", unit: "cm", iconName: "ruler"),
        MeasurementType(id: "upper_arm", name: "Upper Arm", unit: "cm", iconName: "ruler"),
        MeasurementType(id: "forearm", name: "Forearm", unit: "cm", iconName: "ruler")
    ]
}
