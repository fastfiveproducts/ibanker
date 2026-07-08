//
//  HomeView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Split from MenuView ~restored by Pete Maiser, Fast Five Products LLC, on 10/23/25.
//  App-specific content created by Elizabeth Maiser, Fast Five Products LLC, on 7/16/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/7/26.
//
//  Template v0.4.2 (updated) — Fast Five Products LLC's public AGPL template.
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

struct HomeView: View {
    @EnvironmentObject var gameSession: GameSession // Access the shared game session

    // The add-player sheet is owned by MainTabView (its toolbar has the entry
    // point); this binding lets the empty state's inline button present it too.
    @Binding var showingAddPlayerSheet: Bool

    // Edit mode is owned by MainTabView (its toolbar has the Edit/Done button)
    // and injected here so it can be attached at the List level — the only place
    // it reliably activates a tab-hosted List (#30).
    @Binding var editMode: EditMode

    // Deleting a player is destructive and can't be undone, so it goes through a
    // confirmation. Capture the targeted players (not offsets) so the confirm
    // stays valid even if the roster changes underneath it.
    @State private var pendingDeletePlayers: [Player] = []
    @State private var showingDeleteConfirm = false

    // The empty state offers a quick "Game Mode" detour as a sheet (#31) — a
    // return-able modal rather than a tab switch. Owned locally since it's
    // triggered only from here and has no toolbar entry point.
    @State private var showingGameModeSheet = false

    // MARK: - App-Specific
    // Child projects typically replace the entire body with their own
    // home screen composition. iBanker's home screen is the player roster;
    // the enclosing NavigationStack, navigation title, and toolbar are
    // provided by MainTabView (template pattern).

    var body: some View {
        contentView
    }
    
    /// Determines whether to show the empty state or the list of players.
    @ViewBuilder
    private var contentView: some View {
        if gameSession.players.isEmpty {
            emptyPlayersView
        } else {
            playersListView
        }
    }

    /// The view displayed when no players have been added.
    private var emptyPlayersView: some View {
        VStack(spacing: 20) {
            Text("No players added")
                .font(.headline)
                .foregroundColor(.gray)

            Divider()

            Text("Welcome to iBanker!")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // Tagline carried forward from the original Objective-C app's
            // first-launch screen
            Text("iBanker takes the place of paper money in board games!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Game-mode setup as a return-able sheet, not a tab switch (#31):
            // dismissing it drops the user right back here.
            Button(action: {
                showingGameModeSheet = true
            }) {
                Text("Tap here to choose your game mode!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            Divider()

            Button(action: {
                showingAddPlayerSheet = true
            }) {
                Text("Tap here or press the + button to create your first player!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            Divider()

            // Informational only (#31): the Activity Log is empty on a fresh
            // launch, so this is a plain hint — not a tappable teleport to a
            // blank screen.
            Text("Throughout the game, the Activity tab records every action.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingGameModeSheet) {
            gameModeSheet
        }
    }

    /// A focused "Game Mode" detour presented from the empty state (#31). A
    /// sheet's built-in dismissal (grabber / Done) returns the user straight to
    /// Players — a return-able modal instead of a disorienting tab switch. Reuses
    /// GameModeSection so it writes through to the shared SettingsStore.
    private var gameModeSheet: some View {
        NavigationStack {
            Form {
                GameModeSection()
            }
            .navigationTitle("Game Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showingGameModeSheet = false }
                }
            }
        }
    }

    /// The view displaying the list of players.
    private var playersListView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(Array(gameSession.players.enumerated()), id: \.element.id) { index, player in
                    NavigationLink(destination: PlayerView(player: player, playerIndex: index + 1)) {
                        HStack {
                            PlayerThumbnailView(imageData: player.imageData, size: 44)

                            VStack(alignment: .leading) {
                                Text(player.name)
                                    .font(.headline)
                                    .accessibilityLabel("Player name: \(player.name)")

                                if player.token != "" {
                                    Text("Token: \(player.token)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .accessibilityLabel("Player token name: \(player.token)")
                                }
                            }
                            .frame(minHeight: 40)

                            Spacer()

                            Text("$\(gameSession.currentState.playerBalances[player.id] ?? 0)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    (gameSession.currentState.playerBalances[player.id] ?? 0) >= 0 ? .green : .red
                                )
                        }
                        .padding(.vertical, 4)
                    }
                    // Swipe-to-delete is armed only inside Edit mode, and a player
                    // who has exchanged money with someone is locked from
                    // individual deletion (see GameSession.hasExchangedMoney).
                    .deleteDisabled(!editMode.isEditing || gameSession.hasExchangedMoney(player.id))
                }
                .onDelete(perform: requestDelete)
                .onMove(perform: movePlayer)
            }
            // Attach editMode at the List level: injecting it on the TabView (in
            // MainTabView) does not activate a tab-hosted List, so the Edit
            // button would show no reorder handles or delete controls (#30).
            .environment(\.editMode, $editMode)

            // While editing, explain why some rows have no delete control.
            if editMode.isEditing
                && gameSession.players.contains(where: { gameSession.hasExchangedMoney($0.id) }) {
                Text("Players who've exchanged money can't be removed individually. Use Reset Players or Delete All Players in Settings.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            }
        }
        .background(Color(.systemGroupedBackground))
        .alert("Delete Player?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                gameSession.deletePlayers(pendingDeletePlayers)
                pendingDeletePlayers = []
            }
            Button("Cancel", role: .cancel) {
                pendingDeletePlayers = []
            }
        } message: {
            if pendingDeletePlayers.count == 1 {
                Text("\(pendingDeletePlayers[0].name) will be removed from the game. This can't be undone.")
            } else {
                Text("The selected players will be removed from the game. This can't be undone.")
            }
        }
    }

    // MARK: - Helper Functions

    // Capture the players targeted by a delete gesture and ask for confirmation
    // before removing — deletion is destructive and there's no undo. Deleting
    // goes through GameSession so a marker is recorded to the Activity Log and
    // the transaction log is preserved.
    private func requestDelete(at offsets: IndexSet) {
        pendingDeletePlayers = offsets.map { gameSession.players[$0] }
        guard !pendingDeletePlayers.isEmpty else { return }
        showingDeleteConfirm = true
    }

    // Function to move players within the list.
    // This is required for the EditButton's reordering functionality.
    private func movePlayer(from source: IndexSet, to destination: Int) {
        gameSession.players.move(fromOffsets: source, toOffset: destination)
    }
}


#if DEBUG
#Preview {
    let sampleGameSession = GameSession()
    // HomeView no longer owns a NavigationStack (MainTabView provides it),
    // so the preview supplies one for the navigation links.
    NavigationStack {
        HomeView(showingAddPlayerSheet: .constant(false),
                 editMode: .constant(.inactive))
    }
    .environmentObject(sampleGameSession)
    .environmentObject(sampleGameSession.settings)
}
#endif
