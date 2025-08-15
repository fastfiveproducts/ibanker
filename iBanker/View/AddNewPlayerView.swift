//
//  AddNewPlayerView.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/22/25.
//

import SwiftUI

struct AddNewPlayerView: View {
    // @Environment(\.dismiss) property to dismiss the sheet.
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameSession: GameSession // Added to access settings

    // @State properties to hold the input values from the form.
    @State private var playerName: String = ""
    @State private var playerToken: String = ""
    @State private var playerBalance: String
    @State private var playerSalary: String

    // A closure to pass the new Player object back to the HomeView.
    var onSave: (Player) -> Void
    
    // Custom initializer to get default values from EnvironmentObject
    init(onSave: @escaping (Player) -> Void) {
        self.onSave = onSave
        // Initialize state properties, they will be set when the environment object is available
        _playerBalance = State(initialValue: "") // Temporary empty string
        _playerSalary = State(initialValue: "")   // Temporary empty string
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Player Details") {
                    TextField("Player Name", text: $playerName)
                        .autocorrectionDisabled() // Disable autocorrection for names
                        .textInputAutocapitalization(.words) // Capitalize first letter of each word
                    
                    TextField("Token", text: $playerToken)
                        .autocorrectionDisabled() // Disable autocorrection for names
                        .textInputAutocapitalization(.words) // Capitalize first letter of each word

                    TextField("Initial Balance", text: $playerBalance)
                        .keyboardType(.numberPad) // Show number pad for balance input
                        .autocorrectionDisabled()
                    
                    TextField("Initial Salary", text: $playerSalary)
                        .keyboardType(.numberPad) // Show number pad for balance input
                        .autocorrectionDisabled()
                }

                Section {
                    /* //OLD SAVE PLAYER BUTTON
                    Button("Save Player") {
                        // Validate balance input
                        if let balance = Int(playerBalance) {
                            if let salary = Int(playerSalary) {
                                let newPlayer = Player(id: UUID().uuidString, name: playerName, token: playerToken, isLocalOnly: true, salary: salary)
                                onSave(newPlayer) // Call the closure to pass the new player back
                                dismiss() // Dismiss the sheet
                            }
                        } else {
                            // Handle invalid balance input (e.g., show an alert)
                            print("Invalid balance input")
                            // In a real app, you might show a more user-friendly error message here.
                        }
                    }
                    .disabled(playerName.isEmpty) // Disable save button if name is empty
                     */
                    Button("Save Player") {
                        // Safely parse balance and salary, defaulting to 0 if empty or invalid
                        let finalBalance = Int(playerBalance) ?? 0
                        let finalSalary = Int(playerSalary) ?? 0

                        let newPlayer = Player(id: UUID().uuidString,
                                               name: playerName.trimmingCharacters(in: .whitespacesAndNewlines),
                                               token: playerToken.trimmingCharacters(in: .whitespacesAndNewlines),
                                               isLocalOnly: true, // You might want to pass this from somewhere if it's dynamic
                                               salary: finalSalary)

                        // Call the closure to pass the new player back
                        onSave(newPlayer)

                        // Add a transaction for the initial balance
                        if finalBalance != 0 {
                            gameSession.perform(.addMoney(amount: finalBalance), by: newPlayer.id)
                        }

                        dismiss() // Dismiss the sheet
                    }
                    .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) // Disable save button if name is empty
                }
            }
            .navigationTitle("Add New Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss() // Dismiss the sheet without saving
                    }
                }
            }
            .onAppear {
                // Set default values from settings when the view appears
                // We need to access settings via EnvironmentObject here, which is available onAppear
                if playerName.isEmpty { // Only set defaults if player name is empty (new player)
                    self.playerBalance = String(gameSession.settings.effectiveDefaultBalance)
                    self.playerSalary = String(gameSession.settings.effectiveDefaultSalary)
                }
            }
        }
    }
}

#Preview {
    // For preview, you still need a GameSession with a SettingsStore
    let sampleSettings = SettingsStore()
    sampleSettings.selectedGameMode = .monopoly // Or .custom for testing custom fields

    let sampleGameSession = GameSession(players: []) // Add player data if needed for preview
    sampleGameSession.settings = sampleSettings // Inject the sample settings

    return AddNewPlayerView(onSave: { player in
        print("Preview: Player saved: \(player.name)")
    })
    .environmentObject(sampleGameSession) // Provide the environment object for the preview
}
