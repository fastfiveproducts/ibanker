//
//  GameModeSection.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 7/7/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/8/26.
//
//  Copyright © 2026 Fast Five Products LLC. All rights reserved.
//
//  This file is part of a project licensed under the GNU Affero General Public License v3.0.
//  See the LICENSE file at the root of this repository for full terms.
//
//  An exception applies: Fast Five Products LLC retains the right to use this code and
//  derivative works in proprietary software without being subject to the AGPL terms.
//  See LICENSE-EXCEPTIONS.md for details.
//

import SwiftUI

/// The "Game Mode Defaults" section — mode picker plus the resulting (or
/// custom) starting balance/salary. Shared by SettingsView and the empty-state
/// "Game Mode" sheet (#31). Place inside a `Form`/`List`.
struct GameModeSection: View {
    // Shared SettingsStore from iBankerApp (#13); inherited by the sheet too.
    @EnvironmentObject private var settings: SettingsStore
    // For logging a mode change to the Activity Log (see the picker binding).
    @EnvironmentObject private var gameSession: GameSession

    var body: some View {
        Section("Game Mode Defaults") {
            // Log the mode change (#32) from the picker's set, not the onChange
            // below, so it fires once and only on a user pick: programmatic
            // changes (e.g. Reset Settings) write the store directly and bypass
            // this binding, and only the picker the user actually touched logs —
            // avoiding a duplicate from the other live GameModeSection (Settings
            // tab vs the empty-state sheet).
            Picker("Game Mode", selection: Binding(
                get: { settings.selectedGameMode },
                set: { newMode in
                    guard newMode != settings.selectedGameMode else { return }
                    settings.selectedGameMode = newMode
                    gameSession.recordGameModeChange(newMode)
                }
            )) {
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
        .onChange(of: settings.selectedGameMode) {
            // Reset the spinner to the mode's default (v1.3.0) on ANY mode change,
            // including programmatic ones like Reset Settings; the Preferences
            // toggle stays a manual override. (Logging lives on the picker binding
            // above, not here.)
            settings.enabledSpinner = settings.selectedGameMode.defaultSpinnerOn
        }
    }
}


#if DEBUG
#Preview {
    let sampleSettings = SettingsStore()
    let sampleGameSession = GameSession()
    Form {
        GameModeSection()
    }
    .environmentObject(sampleSettings)
    .environmentObject(sampleGameSession)
}
#endif
