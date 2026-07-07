//
//  AddNewPlayerView.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/22/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/8/26.
//
//  Template v0.2.0 (updated) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025 Fast Five Products LLC. All rights reserved.
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

struct AddNewPlayerView: View {
    // @Environment(\.dismiss) property to dismiss the sheet.
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var gameSession: GameSession
    // The single shared SettingsStore, injected from iBankerApp (#13)
    @EnvironmentObject var settings: SettingsStore

    // @State properties to hold the input values from the form.
    @State private var playerName: String = ""
    @State private var playerToken: String = ""
    @State private var playerBalance: Double? = nil
    @State private var playerSalary: Int? = nil

    // Player photo capture (#20) — flow provided by .playerPhotoPicker
    @State private var playerImageData: Data? = nil
    @State private var showingPhotoDialog = false
    @State private var isLoadingPhoto = false

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
        NavigationStack {
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
                        Text("Photo:")
                        Spacer()
                        if isLoadingPhoto {
                            ProgressView()
                                .frame(width: 44, height: 44)
                        } else {
                            PlayerThumbnailView(imageData: playerImageData, size: 44)
                        }
                        Button(playerImageData == nil ? "Add Photo" : "Change") {
                            showingPhotoDialog = true
                        }
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
                                               salary: finalSalary,
                                               imageData: playerImageData)

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
                    .disabled(playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                              || isLoadingPhoto) // Disable save if name is empty or a photo load is in flight
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
            // Photo capture: the shared flow — v1.3.0-style dialog, camera
            // (front-facing first) when available, library via PhotosPicker.
            // See PlayerPhotoPicker.swift.
            .playerPhotoPicker(isPresented: $showingPhotoDialog,
                               imageData: $playerImageData,
                               isLoading: $isLoadingPhoto)
            .onAppear {
                // Set default values from the shared settings when the view appears (#13)
                if playerName.isEmpty { // Only set defaults if player name is empty (new player)
                    if playerBalance == nil {
                        self.playerBalance = Double(settings.effectiveDefaultBalance)
                    }
                    if playerSalary == nil {
                        self.playerSalary = settings.effectiveDefaultSalary
                    }
                }
            }
        }
    }
    
}


#if DEBUG
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
    .environmentObject(sampleSettings)
}
#endif
