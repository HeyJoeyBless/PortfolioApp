//
//  AppTheme.swift
//  PortfolioApp
//

import SwiftUI

enum AppTheme {
    static let ink = Color(red: 0.09, green: 0.10, blue: 0.14)
    static let paper = Color(red: 0.97, green: 0.96, blue: 0.93)
    static let mist = Color(red: 0.88, green: 0.90, blue: 0.94)
    static let crimson = Color(red: 0.72, green: 0.18, blue: 0.22)
    static let gold = Color(red: 0.86, green: 0.68, blue: 0.28)
    static let bamboo = Color(red: 0.35, green: 0.55, blue: 0.42)
    static let dawn = Color(red: 0.55, green: 0.62, blue: 0.82)

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.14, blue: 0.22),
                Color(red: 0.18, green: 0.22, blue: 0.35),
                Color(red: 0.28, green: 0.24, blue: 0.32)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.22),
                Color.white.opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var journeyTrack: LinearGradient {
        LinearGradient(
            colors: [mist.opacity(0.9), dawn.opacity(0.35)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
