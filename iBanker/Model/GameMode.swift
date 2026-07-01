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

    static let zero = GameModeDefaults(initialBalance: 0, initialSalary: 0)
    static let fifteenHundred = GameModeDefaults(initialBalance: 1500, initialSalary: 200)
    static let tenK = GameModeDefaults(initialBalance: 10000, initialSalary: 0)
    static let fourHundredK = GameModeDefaults(initialBalance: 400000, initialSalary: 0)
    static let fifteenMil = GameModeDefaults(initialBalance: 15000000, initialSalary: 2000000)
}

// Enum for different game modes
enum GameMode: String, CaseIterable, Codable, Identifiable {
    case zero = "$0 Balance"
    case fifteenHundred = "$1500 Balance"
    case tenK = "$10K Balance"
    case fourHundredK = "$400K Balance"
    case fifteenMil = "$15M Balance"
    case custom = "Custom"

    var id: String { self.rawValue }

    // Computed property to get the default values for a non-custom mode
    var defaults: GameModeDefaults? {
        switch self {
        case .zero:
            return .zero
        case .fifteenHundred:
            return .fifteenHundred
        case .tenK:
            return .tenK
        case .fourHundredK:
            return .fourHundredK
        case .fifteenMil:
            return .fifteenMil
        case .custom:
            return nil // Custom mode doesn't have fixed defaults
        }
    }
}
