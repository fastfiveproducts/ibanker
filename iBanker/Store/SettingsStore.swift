//  SettingsView.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/5/25.
//
//  Template v0.2.0 — Fast Five Products LLC's public AGPL template.
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
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//


import Foundation
import SwiftUI

class SettingsStore: ObservableObject {
    @AppStorage("soundEffects") var soundEffects = true

    // New properties for Game Mode settings
    @AppStorage("selectedGameMode") var selectedGameMode: GameMode = .zero
    @AppStorage("customInitialBalance") var customInitialBalance: Int = 0
    @AppStorage("customInitialSalary") var customInitialSalary: Int = 0

    // Computed property to get the effective default balance
    var effectiveDefaultBalance: Int {
        if let defaults = selectedGameMode.defaults {
            return defaults.initialBalance
        } else { // Custom mode
            return customInitialBalance
        }
    }

    // Computed property to get the effective default salary
    var effectiveDefaultSalary: Int {
        if let defaults = selectedGameMode.defaults {
            return defaults.initialSalary
        } else { // Custom mode
            return customInitialSalary
        }
    }
    
    func resetAllSettings() {
        soundEffects = true
        selectedGameMode = .zero
        customInitialBalance = 0 // Reset custom values
        customInitialSalary = 0
    }
}
