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
                gameSession.players.append(newPlayer) // Add the new player to the list
            }
        }
        
        .onAppear {
            
        }
         
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

            NavigationLink(destination: SettingsView()) {
                Text("Select your game mode in the settings tab!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
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
                ForEach(Array(gameSession.players.enumerated()), id: \.element.id) { index, player in
                    NavigationLink(destination: PlayerView(player: player, playerIndex: index + 1)) {
                        HStack {
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
            Button("Save") {
                gameSession.saveGame()
            }
        }

        .background(Color(.systemGroupedBackground))
    }
    
    /// The content for the toolbar.
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if !gameSession.players.isEmpty {
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
        gameSession.players.remove(atOffsets: offsets)
    }

    // Function to move players within the list.
    // This is required for the EditButton's reordering functionality.
    private func movePlayer(from source: IndexSet, to destination: Int) {
        gameSession.players.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    let sampleGameSession = GameSession()
    HomeView()
        .environmentObject(sampleGameSession)
}
