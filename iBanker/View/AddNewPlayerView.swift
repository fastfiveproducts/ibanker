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
    @State private var playerBalance: Double? = nil
    @State private var playerSalary: Int? = nil

    // A closure to pass the new Player object back to the HomeView.
    var onSave: (Player) -> Void
    
    // Formatter for the playerSalary field (integers only)
    private var integerFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        formatter.generatesDecimalNumbers = false
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Player Details") {
                    HStack{
                        Text("Name:")
                        TextField("Player Name", text: $playerName)
                            .autocorrectionDisabled() // Disable autocorrection for names
                            .textInputAutocapitalization(.words) // Capitalize first letter of each word
                    }

                    HStack{
                        Text("Token:")
                        TextField("Player Token", text: $playerToken)
                            .autocorrectionDisabled() // Disable autocorrection for names
                            .textInputAutocapitalization(.words) // Capitalize first letter of each word
                    }

                    HStack {
                        Text("Balance:")
                        HStack(spacing: 0) {
                            Text("$")
                            TextField("Initial Balance", value: $playerBalance, formatter: integerFormatter)
                                .keyboardType(.decimalPad)
                                .autocorrectionDisabled()
                        }
                    }
                    
                    HStack {
                        Text("Salary:")
                        HStack(spacing: 0) {
                            Text("$")
                            TextField("Initial Salary", value: $playerSalary, formatter: integerFormatter)
                                .keyboardType(.numberPad) // Show number pad for balance input
                                .autocorrectionDisabled()
                        }
                    }
                }

                Section {
                    Button("Save Player") {
                        // Safely parse balance and salary, defaulting to 0 if empty or invalid
                        let finalBalance = Int(playerBalance ?? 0.0)
                        let finalSalary = playerSalary ?? 0

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
                        
                        if finalSalary != 0 {
                            gameSession.perform(.updateSalary(newSalary: finalSalary), by: newPlayer.id)
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
                    if playerBalance == nil {
                        self.playerBalance = Double(gameSession.settings.effectiveDefaultBalance)
                    }
                    if playerSalary == nil {
                        self.playerSalary = gameSession.settings.effectiveDefaultSalary
                    }
                }
            }
        }
    }
    
}

#Preview {
    // For preview, you still need a GameSession with a SettingsStore
    let sampleSettings = SettingsStore()
    sampleSettings.selectedGameMode = .zero // Or .custom for testing custom fields

    let sampleGameSession = GameSession() // Add player data if needed for preview
    sampleGameSession.settings = sampleSettings // Inject the sample settings

    return AddNewPlayerView(onSave: { player in
        print("Preview: Player saved: \(player.name)")
    })
    .environmentObject(sampleGameSession) // Provide the environment object for the preview
}
