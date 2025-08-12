//
//  SettingsViewModel.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import Foundation
import SwiftUI
import StoreKit

extension Notification.Name {
    static let didRequestDataReset = Notification.Name("didRequestDataReset")
}

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var isShowingResetAlert = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    func contactUs() {
            let email = "support@sportybetter.com"
            if let url = URL(string: "mailto:\(email)") {
                UIApplication.shared.open(url)
            }
        }
    
    func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func shareApp() {
        guard let url = URL(string: "https://apps.apple.com/app/id6749900442") else { return }
        let text = "Check out SportyBetter, a great app for tracking workouts and progress!"
        let items: [Any] = [text, url]
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }

    func resetAllData() {
            let keysToRemove = [
                "user_exercises",
                "workout_history", // Используйте "workout_history", а не "workout_logs"
                "measurement_types",
                "measurement_logs",
                "sport_notes"
            ]
            
            for key in keysToRemove {
                UserDefaults.standard.removeObject(forKey: key)
            }
            
            // Отправляем уведомление, чтобы другие части приложения узнали о сбросе
            NotificationCenter.default.post(name: .didRequestDataReset, object: nil)
            
            print("All user data has been reset.")
        }
}
