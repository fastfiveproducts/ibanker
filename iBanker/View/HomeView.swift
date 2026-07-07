//
//  HomeView.swift
//
//  Template created by Pete Maiser, July 2024 through May 2025
//  Split from MenuView ~restored by Pete Maiser, Fast Five Products LLC, on 10/23/25.
//  App-specific content created by Elizabeth Maiser, Fast Five Products LLC, on 7/16/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/8/26.
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

    // The add-player sheet and tab selection are owned by MainTabView (with
    // its toolbar entry points); these bindings let the empty state's inline
    // buttons present the sheet and switch tabs.
    @Binding var showingAddPlayerSheet: Bool
    @Binding var selectedTab: Tab

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

            Button(action: {
                selectedTab = .settings
            }) {
                Text("Select your game mode in the settings tab!")
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

            Button(action: {
                selectedTab = .activityLog
            }) {
                Text("Throughout the game, check the Activity Log to review actions!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    /// The view displaying the list of players.
    private var playersListView: some View {
        VStack {
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
                }
                .onDelete(perform: deletePlayer)
                .onMove(perform: movePlayer)
            }
            Spacer()
        }

        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Helper Functions
    // Function to add a new placeholder player.
    
    private func deletePlayer(at offsets: IndexSet) {
        gameSession.players.remove(atOffsets: offsets)
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
                 selectedTab: .constant(.home))
    }
    .environmentObject(sampleGameSession)
    .environmentObject(sampleGameSession.settings)
}
#endif
