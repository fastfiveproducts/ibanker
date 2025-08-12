//
//  GameMode.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/24/25.
//


import Foundation

// Struct to hold the default settings for each game mode
struct GameModeDefaults: Codable, Equatable {
    let initialBalance: Int
    let initialSalary: Int

    static let monopoly = GameModeDefaults(initialBalance: 1500, initialSalary: 200)
    static let gameOfLife = GameModeDefaults(initialBalance: 10000, initialSalary: 0) // Example values
    // Add more presets here if needed
}

// Enum for different game modes
enum GameMode: String, CaseIterable, Codable, Identifiable {
    case monopoly = "Monopoly"
    case gameOfLife = "The Game of Life"
    case custom = "Custom"

    var id: String { self.rawValue }

    // Computed property to get the default values for a non-custom mode
    var defaults: GameModeDefaults? {
        switch self {
        case .monopoly:
            return .monopoly
        case .gameOfLife:
            return .gameOfLife
        case .custom:
            return nil // Custom mode doesn't have fixed defaults
        }
    }
}
