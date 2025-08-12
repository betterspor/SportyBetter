//
//  SettingsView.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.themeBackground.ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("Settings")
                        .font(.largeTitle).bold()
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.themeSecondaryText)
                    }
                }
                .padding()
                
                List {
                    SettingsRow(iconName: "square.and.arrow.up.fill", title: "Share App", action: viewModel.shareApp)
                    SettingsRow(iconName: "star.fill", title: "Rate App", action: viewModel.rateApp)
                    SettingsRow(iconName: "envelope.fill", title: "Contact Us", action: viewModel.contactUs)
                    SettingsRow(iconName: "trash.fill", title: "Reset All Data", isDestructive: true) {
                        viewModel.isShowingResetAlert = true
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                
                Spacer()
                
                Text("Version \(viewModel.appVersion)")
                    .font(.caption)
                    .foregroundColor(.themeSecondaryText)
                    .padding()
            }
            .foregroundColor(.themePrimaryText)
        }
        .alert("Reset All Data", isPresented: $viewModel.isShowingResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive, action: viewModel.resetAllData)
        } message: {
            Text("Are you sure you want to delete all your custom exercises, workout logs, measurements, and notes? This action cannot be undone.")
        }
    }
}


private struct SettingsRow: View {
    let iconName: String
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(isDestructive ? .themeAccentRed : .themePrimaryText)
                
                Text(title)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.themeSecondaryText)
            }
        }
        .listRowBackground(Color.themeCardBackground)
        .foregroundColor(isDestructive ? .themeAccentRed : .themePrimaryText)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
