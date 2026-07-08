//
//  GameModeSection.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 7/7/26.
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

    var body: some View {
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
        .onChange(of: settings.selectedGameMode) {
            // Changing the mode resets the spinner to its default (v1.3.0); the
            // Preferences toggle stays a manual override. Here so it applies
            // wherever the mode changes.
            settings.enabledSpinner = settings.selectedGameMode.defaultSpinnerOn
        }
    }
}


#if DEBUG
#Preview {
    let sampleSettings = SettingsStore()
    Form {
        GameModeSection()
    }
    .environmentObject(sampleSettings)
}
#endif
