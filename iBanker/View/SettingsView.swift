//
//  SettingsView.swift
//
//  Template file created by Elizabeth Maiser, Fast Five Products LLC, on 7/4/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/8/26.
//
//  Template v0.3.0 (updated) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025, 2026 Fast Five Products LLC. All rights reserved.
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
    // The single shared SettingsStore, injected from iBankerApp (#13) —
    // do not create additional SettingsStore instances in app code.
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var gameSession: GameSession
    @State private var showingAlert = false

    var showTitle: Bool = false

    // MARK: - App-Specific
    // iBanker's settings are game configuration: sound/spinner preferences,
    // game-mode defaults (via the shared SettingsStore), and player reset.

    var body: some View {
        VStack {
            if showTitle {
                HStack {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.bottom)
            }
            Form {
                Section ("Preferences"){
                    Toggle("Sound effects", isOn: $settings.soundEffects)
                    Toggle("Spin-to-Win Spinner", isOn: $settings.enabledSpinner)
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
                Section {
                    Button("Reset Players") {
                        showingAlert = true
                    }
                    .alert(isPresented: $showingAlert) {
                        // 4. Define the content of the alert.
                        Alert(
                            title: Text("Confirm Reset"),
                            message: Text("Are you sure you want to reset players? Each player's balance and salary will return to default settings."),
                            primaryButton: .destructive(Text("Reset")) {
                                resetPlayers()
                            },
                            secondaryButton: .cancel(Text("Cancel")) {
                            }
                        )
                    }
                }
            }
            .onChange(of: settings.selectedGameMode) {
                // Changing the mode resets the spinner to the mode's default
                // (v1.3.0 behavior); the Preferences Toggle remains a manual
                // override.
                settings.enabledSpinner = settings.selectedGameMode.defaultSpinnerOn
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
    
    private func resetPlayers() {
        for player in gameSession.players{
            gameSession.perform(.resetPlayer(balance: settings.effectiveDefaultBalance, salary: settings.effectiveDefaultSalary), by: player.id)
        }
        // One shake for the whole reset (not per player), matching v1.3.0
        SoundPlayer.shared.playSystemSound(.shake)
    }
}


#if DEBUG
#Preview {
    let sampleGameSession = GameSession()
    SettingsView(showTitle: true)
        .environmentObject(sampleGameSession)
        .environmentObject(sampleGameSession.settings)
}
#endif

