//
//  MeasurementsView.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import SwiftUI

#Preview {
    MeasurementsView()
}

struct MeasurementsView: View {
    @StateObject private var viewModel = MeasurementsViewModel()
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("My Measurements")
                    .font(.largeTitle).bold()
                    .padding()
                
                ScrollView {
                    ForEach(viewModel.measurementTypes) { type in
                        MeasurementCell(
                            type: type,
                            log: viewModel.measurementLogs[type.id]
                        )
                        .onTapGesture {
                            viewModel.selectedMeasurement = type
                            viewModel.isAddLogSheetPresented = true
                        }
                    }
                    
                    AddCustomButton {
                        viewModel.isAddCustomSheetPresented = true
                    }
                }
            }
            .foregroundColor(.themePrimaryText)
            
            if viewModel.isAddLogSheetPresented, let measurement = viewModel.selectedMeasurement {
                AddMeasurementOverlayView(
                    isPresented: $viewModel.isAddLogSheetPresented,
                    measurement: measurement,
                    log: viewModel.measurementLogs[measurement.id],
                    onSave: { date, value in
                        viewModel.saveLog(for: measurement, date: date, value: value)
                    }
                )
            }
            
            if viewModel.isAddCustomSheetPresented {
                AddCustomMeasurementOverlayView(
                    isPresented: $viewModel.isAddCustomSheetPresented,
                    onSave: { name, unit in
                        viewModel.addCustomMeasurement(name: name, unit: unit)
                    }
                )
            }
        }
    }
}

private struct MeasurementCell: View {
    let type: MeasurementType
    let log: MeasurementLog?
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: type.iconName)
                .padding(12)
                .colorMultiply(.themeAccentRed)
                .background(Color.themeSecondaryBackground)
                .frame(height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(type.name)
                    .font(.headline)
                Text(log?.displayString(unit: type.unit) ?? "No data yet")
                    .font(.caption)
                    .foregroundColor(.themeSecondaryText)
            }
            
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color.themeCardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

private struct AddCustomButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Add Custom Measurement", systemImage: "plus")
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

struct AddMeasurementOverlayView: View {
    @Binding var isPresented: Bool
    let measurement: MeasurementType
    let log: MeasurementLog?
    let onSave: (Date, Double) -> Void
    
    @State private var date: Date
    @State private var valueString: String
    @State private var unit: String
    @State private var isAnimating = false
    
    init(isPresented: Binding<Bool>, measurement: MeasurementType, log: MeasurementLog?, onSave: @escaping (Date, Double) -> Void) {
        self._isPresented = isPresented
        self.measurement = measurement
        self.log = log
        self.onSave = onSave
        
        _date = State(initialValue: log?.date ?? Date())
        _valueString = State(initialValue: log != nil ? String(log!.value) : "")
        _unit = State(initialValue: measurement.unit)
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(alignment: .leading, spacing: 20) {
                HeaderView(title: "Add Measurement") { isPresented = false }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Date")
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden().padding(.horizontal).frame(height: 50)
                        .background(Color.themeBackground).cornerRadius(12).colorScheme(.dark)
                    
                    Text("Measurement")
                    HStack {
                        TextField("Enter value", text: $valueString)
                            .keyboardType(.decimalPad)
                            .padding().frame(height: 50)
                            .background(Color.themeBackground).cornerRadius(12)
                        
                        Text(unit).padding().frame(width: 80, height: 50)
                            .background(Color.themeBackground).cornerRadius(12)
                    }
                }
                
                Button(action: {
                    if let value = Double(valueString) {
                        onSave(date, value)
                        isPresented = false
                    }
                }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.headline.bold()).frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(24).background(Color.themeCardBackground).cornerRadius(20)
            .shadow(radius: 20).padding(30).foregroundColor(.themePrimaryText)
            .scaleEffect(isAnimating ? 1 : 0.9).opacity(isAnimating ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

struct AddCustomMeasurementOverlayView: View {
    @Binding var isPresented: Bool
    let onSave: (String, String) -> Void
    
    @State private var name: String = ""
    @State private var unit: String = "cm"
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(alignment: .leading, spacing: 20) {
                HeaderView(title: "Add Custom Measurement") { isPresented = false }
                
                TextField("Measurement Name (e.g., Calf)", text: $name)
                    .padding().background(Color.themeBackground).cornerRadius(12)
                TextField("Unit (e.g., cm, kg)", text: $unit)
                    .padding().background(Color.themeBackground).cornerRadius(12)
                
                Button(action: {
                    if !name.isEmpty && !unit.isEmpty {
                        onSave(name, unit)
                        isPresented = false
                    }
                }) {
                    Label("Save", systemImage: "plus")
                        .font(.headline.bold()).frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(name.isEmpty || unit.isEmpty)
            }
            .padding(24).background(Color.themeCardBackground).cornerRadius(20)
            .shadow(radius: 20).padding(30).foregroundColor(.themePrimaryText)
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

//struct PrimaryButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding()
//            .background(Color.themeAccentRed)
//            .clipShape(Capsule())
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//    }
//}
