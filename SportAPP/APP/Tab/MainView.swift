//
//  MainView.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import SwiftUI

enum Tab: Int {
    case workouts, measurements, progress, notes
}

struct MainView: View {
    @State private var selectedTab: Tab = .workouts
    @State private var isonboardingShown: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case .workouts:
                    WorkoutsView()
                case .measurements:
                    MeasurementsView()
                case .progress:
                    NewProgressView()
                case .notes:
                    NotesView()
                }
            }
            
            CustomTabBar(selectedTab: $selectedTab)

        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "isOnboardingShown") {
                isonboardingShown = true
                UserDefaults.standard.set(true, forKey: "isOnboardingShown")
            }
        }
        .fullScreenCover(isPresented: $isonboardingShown) {
            OnboardingView()
        }
    }
}

private struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack {
            TabItem(iconName: "dumbbell.fill", title: "Workouts", tab: .workouts, selectedTab: $selectedTab)
            TabItem(iconName: "scalemass.fill", title: "Measurements", tab: .measurements, selectedTab: $selectedTab)
            TabItem(iconName: "chart.line.uptrend.xyaxis", title: "Progress", tab: .progress, selectedTab: $selectedTab)
            TabItem(iconName: "note.text.badge.plus", title: "Notes", tab: .notes, selectedTab: $selectedTab)
        }
        .padding(.top, 12)
        .frame(height: 60)
        .background(Color.themeCardBackground)
        .background(Color.themeSecondaryBackground.offset(y: -1))
    }
}

private struct TabItem: View {
    let iconName: String
    let title: String
    let tab: Tab
    @Binding var selectedTab: Tab
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .renderingMode(.template)
                    .foregroundColor(isSelected ? .themeAccentRed : .themeSecondaryText)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .themeAccentRed : .themeSecondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}


#Preview {
    MainView()
}
