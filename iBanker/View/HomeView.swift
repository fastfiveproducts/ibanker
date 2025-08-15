//
//  HomeView.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/16/25.
//

import SwiftUI

struct HomeView: View {
    // @State property to hold our list of players.
    // @State ensures that the UI updates when this array changes.
    @State private var players: [Player] = []
    @EnvironmentObject var gameSession: GameSession // Access the shared game session
    @State private var showingAddPlayerSheet = false

    var body: some View {
        // NavigationView provides the navigation bar and allows for navigation links.
        NavigationView {
            contentView
                .navigationTitle("Players") // Title for the navigation bar
                .toolbar {
                    toolbarContent
                }
        }

        // The .sheet modifier presents a new view modally when showingAddPlayerSheet is true.
        .sheet(isPresented: $showingAddPlayerSheet) {
            // When the sheet is dismissed, this closure receives the new player.
            AddNewPlayerView { newPlayer in
                players.append(newPlayer) // Add the new player to the list
            }
        }
        /*
        .onAppear {
            // Example: Load players from gameSession or a persistent store
            // For now, let's assume gameSession might have initial players or you load them here
            if gameSession.currentState.players.isEmpty && players.isEmpty {
                // Optionally add some dummy players for testing if needed
                // players = [Player(id: UUID().uuidString, name: "Alice", token: "person", isLocalOnly: true, salary: 200)]
                // gameSession.addPlayer(players.first!)
            } else if players.isEmpty {
                // If gameSession already has players but local players array is empty, sync them
                players = gameSession.currentState.players
            }
            // Ensure player balances in gameSession are initialized if they aren't
            gameSession.initializePlayerBalances(for: players)
        }
        // Observe changes in gameSession.currentState.players to keep players array in sync
        // This is important if players can be added/removed from other parts of the app via gameSession
        .onChange(of: gameSession.currentState.players) { newPlayers in
            players = newPlayers
        }
         */
    }
    
    /// Determines whether to show the empty state or the list of players.
    @ViewBuilder
    private var contentView: some View {
        if players.isEmpty {
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

            NavigationLink(destination: SettingsView()) {
                Text("First, select your game mode in the settings tab!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)

            Divider()

            Button(action: {
                showingAddPlayerSheet = true
            }) {
                Text("To begin, tap here or press the + button to create your first player!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            Divider()

            NavigationLink(destination: ActivityLogView()) {
                Text("Throughout the game, check the Activity Log to review actions!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
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
                ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                    NavigationLink(destination: PlayerView(player: player, playerIndex: index + 1)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(player.name)
                                    .font(.headline)
                                    .accessibilityLabel("Player name: \(player.name)")
                                
                                Text("Token: \(player.token)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .accessibilityLabel("Player token name: \(player.token)")
                            }
                            
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
            Button("Save") {
                gameSession.saveGame()
            }
        }
    }
    
    /// The content for the toolbar.
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if !players.isEmpty {
                EditButton()
            } else {
                // Optionally, add a different leading item for the empty state
                // Text("Setup") // Example
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                showingAddPlayerSheet = true
            }) {
                Image(systemName: "plus")
                    .accessibilityLabel("Add New Player")
            }
        }
    }
    
    // MARK: - Helper Functions
    // Function to add a new placeholder player.
    
    private func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }

    // Function to move players within the list.
    // This is required for the EditButton's reordering functionality.
    private func movePlayer(from source: IndexSet, to destination: Int) {
        players.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    let sampleGameSession = GameSession(players: [])
    HomeView()
        .environmentObject(sampleGameSession)
}
