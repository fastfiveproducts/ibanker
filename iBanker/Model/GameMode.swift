//
//  GameMode.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/24/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/7/26.
//
//  Template v0.2.0 (updated) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025 Fast Five Products LLC. All rights reserved.
//
//  This file is part of a project licensed under the GNU Affero General Public License v3.0.
//  See the LICENSE file at the root of this repository for full terms.
//
//  An exception applies: Fast Five Products LLC retains the right to use this code and
//  derivative works in proprietary software without being subject to the AGPL terms.
//  See LICENSE-EXCEPTIONS.md for details.
//
//  For licensing inquiries, contact: licenses@fastfiveproducts.com
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

    // Whether the Spin-to-Win spinner is on by default for this mode — true
    // only for the $400K mode (The Game of Life). Kept centralized here so a
    // future per-mode attribute (#7) can extend it rather than duplicate it.
    var defaultSpinnerOn: Bool {
        self == .fourHundredK
    }

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
