//
//  Extensions.swift
//  SportAPP
//
//  Created by D K on 11.08.2025.
//

import SwiftUI

extension Color {
    static let themeBackground = Color(hex: "0F172A")
    static let themeAccentRed = Color(hex: "EF4444")
    static let themeCardBackground = Color(hex: "1E293B")
    static let themeSecondaryBackground = Color(hex: "334155")
    static let themePrimaryText = Color.white
    static let themeSecondaryText = Color(hex: "94A3B8")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

extension View {
    func size() -> CGSize {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        return window.screen.bounds.size
    }
}
