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
//  For licensing inquiries, contact: licenses@fastfiveproducts.com
//


import SwiftUI

struct SettingsView: View {
    // The single shared SettingsStore, injected from iBankerApp (#13) —
    // do not create additional SettingsStore instances in app code.
    @EnvironmentObject private var settings: SettingsStore
    @EnvironmentObject private var gameSession: GameSession
    @State private var showingResetPlayersAlert = false
    @State private var showingResetSettingsAlert = false
    @State private var showingDeleteAllPlayersAlert = false

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
                // Shared with the empty-state "Game Mode" sheet (#31); the
                // mode → spinner reset lives inside GameModeSection.
                GameModeSection()
                // Destructive-settings section (#28, extended #30), mirroring
                // iOS Settings > General > Reset: red buttons, each confirmed,
                // ordered least- to most-destructive. No footer — the confirm
                // alerts carry the explanation.
                Section {
                    Button("Reset Settings", role: .destructive) {
                        showingResetSettingsAlert = true
                    }

                    Button("Reset Players", role: .destructive) {
                        showingResetPlayersAlert = true
                    }
                    .disabled(gameSession.players.isEmpty)

                    Button("Delete All Players", role: .destructive) {
                        showingDeleteAllPlayersAlert = true
                    }
                    .disabled(gameSession.players.isEmpty)
                } header: {
                    Text("Reset")
                }
                .alert("Reset Settings?", isPresented: $showingResetSettingsAlert) {
                    Button("Reset", role: .destructive) {
                        withAnimation {
                            settings.resetAllSettings()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("iBanker's settings will return to their defaults.")
                }
                .alert("Reset Players?", isPresented: $showingResetPlayersAlert) {
                    Button("Reset", role: .destructive) {
                        resetPlayers()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Each player's balance and salary will return to the current Mode's defaults.")
                }
                .alert("Delete All Players?", isPresented: $showingDeleteAllPlayersAlert) {
                    Button("Delete All", role: .destructive) {
                        withAnimation {
                            gameSession.deleteAllPlayers()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Every player will be removed and the game reset. The Activity Log is kept. This can't be undone.")
                }

                aboutSection
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private func resetPlayers() {
        gameSession.resetPlayers(balance: settings.effectiveDefaultBalance, salary: settings.effectiveDefaultSalary)
        // One shake for the whole reset (not per player), matching v1.3.0
        SoundPlayer.shared.playSystemSound(.shake)
    }

    /// About footer (pattern adopted from DTrol's SettingsView): the app's
    /// logo, brand name, version, support and privacy links, and copyright.
    private var aboutSection: some View {
        Section {
            VStack(spacing: 6) {
                Image("iBankerLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .accessibilityHidden(true)
                Text(AppConfig.brandName)
                    .font(.headline)
                Text("Version \(Self.appVersion)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Link(AppConfig.supportText, destination: AppConfig.supportURL)
                    .font(.caption)
                Link(AppConfig.privacyText, destination: AppConfig.privacyURL)
                    .font(.caption)
                Text("© 2015–2026 Fast Five Products LLC")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
            // Two links share this row: without .borderless a Form row forwards
            // a tap ANYWHERE in the row to its first control, so taps on the
            // logo — or on Privacy Policy — would all open the support URL
            // (lesson learned in DTrol). Borderless gives each link its own
            // discrete hit area.
            .buttonStyle(.borderless)
        }
    }

    /// "2.0 (1)" — marketing version and build, from the bundle.
    private static var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        let build = info?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
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

