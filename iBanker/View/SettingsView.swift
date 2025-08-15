//
//  SettingsView.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/4/25.
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


import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SettingsStore()
    
    var showTitle: Bool = true
    
    var body: some View {
        VStack {
            if showTitle {
                HStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            
            Form {
                Section ("Preferences"){
                    Toggle("Dark Mode", isOn: $settings.darkMode)
                    Toggle("Sound effects", isOn: $settings.soundEffects)
                }
                // MARK: - Game Mode Settings
                Section("Game Mode Defaults") {
                    Picker("Game Mode", selection: $settings.selectedGameMode) {
                        ForEach(GameMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }

                    // Show custom input fields only if "Custom" mode is selected
                    if settings.selectedGameMode == .custom {
                        HStack {
                            Text("Default Balance")
                            Spacer()
                            TextField("Custom Initial Balance", value: $settings.customInitialBalance, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .autocorrectionDisabled()
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Default Salary")
                            Spacer()
                            TextField("Custom Initial Salary", value: $settings.customInitialSalary, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .autocorrectionDisabled()
                                .multilineTextAlignment(.trailing)
                        }
                    } else {
                        // Display the default values for the selected non-custom mode
                        HStack {
                            Text("Default Balance")
                            Spacer()
                            Text("$\(settings.effectiveDefaultBalance)")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Default Salary")
                            Spacer()
                            Text("$\(settings.effectiveDefaultSalary)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            Button("Reset All Settings") {
                withAnimation {
                    settings.resetAllSettings()
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

#if DEBUG
#Preview {
    SettingsView(showTitle: true)
}
#endif
