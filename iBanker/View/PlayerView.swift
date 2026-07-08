//
//  PlayerView.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/22/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/8/26.
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

import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var gameSession: GameSession
    
    let player: Player
    let playerIndex: Int
    
    @State private var salaryInput: Int? = nil
    @State private var addInput: Int? = nil
    @State private var subtractInput: Int? = nil
    @State private var sendInput: Int? = nil
    @State private var selectedPlayer: Player? = nil

    // Change/add/remove the player's photo (#20 follow-up; v1.3.0 allowed
    // this from the detail screen). `player` is a by-value copy, so the
    // photo binding reads and writes the live player in gameSession.players
    // — the single source of truth for player identity.
    @State private var showingPhotoDialog = false
    @State private var isLoadingPhoto = false

    private var photoBinding: Binding<Data?> {
        Binding(
            get: { gameSession.players.first(where: { $0.id == player.id })?.imageData },
            set: { newValue in
                if let idx = gameSession.players.firstIndex(where: { $0.id == player.id }) {
                    gameSession.players[idx].imageData = newValue
                }
            }
        )
    }

    private var salaryAmount: Int {
        Int(salaryInput ?? 0)    }
    private var addAmount: Int {
        Int(addInput ?? 0)    }
    private var subtractAmount: Int {
        Int(subtractInput ?? 0)    }
    private var sendAmount: Int {
        Int(sendInput ?? 0)    }
    
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
        VStack {
            // Tappable photo opens the shared change/add/remove flow; the camera badge signals editability.
            Button {
                showingPhotoDialog = true
            } label: {
                if isLoadingPhoto {
                    ProgressView()
                        .frame(width: 60, height: 60)
                } else {
                    PlayerThumbnailView(imageData: photoBinding.wrappedValue, size: 60)
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.white, Color.accentColor)
                                .offset(x: 4, y: 4)
                        }
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Change player photo")
            .padding(.top, 5)

            Text(player.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(5)
            
            Text("Token: \(player.token)")
                .font(.headline)
                .padding(.bottom, 20)
            
            Form {
                Section {
                        HStack {
                            Text("Balance:")
                                .font(.title2)
                                .accessibilityLabel("Text: Balance")
                            
                            Spacer()
                            
                            Text("$\(gameSession.currentState.playerBalances[player.id] ?? 0)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(
                                    (gameSession.currentState.playerBalances[player.id] ?? 0) >= 0 ? .green : .red
                                )
                        }
                        .padding(5)
                        HStack {
                            Text("Salary:")
                                .font(.title2)
                                .accessibilityLabel("Text: Salary")
                            
                            Spacer()
                            
                            TextField("Enter Salary", value: $salaryInput, formatter: integerFormatter)
                                .font(.title2)
                                .fontWeight(.bold)
                                .keyboardType(.numberPad)
                                .autocorrectionDisabled(true)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(5)
                }
                
                Section {
                    Button("Collect $\(salaryAmount) Salary") {
                        gameSession.perform(.collectSalary(amount: salaryAmount), by: player.id)
                    }
                    .font(.title2)
                    .padding(5)
                }
                
                Section {
                    HStack {
                        Text("Add $:")
                            .font(.title2)
                        Spacer()
                        TextField("Enter Amount", value: $addInput, formatter: integerFormatter)
                            .font(.title2)
                            .fontWeight(.bold)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.trailing)
                        Button {
                            gameSession.perform(.addMoney(amount: addAmount), by: player.id)
                            addInput = nil
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(5)
                    HStack {
                        Text("Subtract $:")
                            .font(.title2)
                        Spacer()
                        TextField("Enter Amount", value: $subtractInput, formatter: integerFormatter)
                            .font(.title2)
                            .fontWeight(.bold)
                            .keyboardType(.numberPad)
                            .autocorrectionDisabled(true)
                            .multilineTextAlignment(.trailing)
                        Button {
                            gameSession.perform(.subtractMoney(amount: subtractAmount), by: player.id)
                            subtractInput = nil
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(5)
                    VStack {
                        HStack {
                            Text("Send Amount:")
                                .font(.title2)
                            Spacer()
                            TextField("Enter Amount", value: $sendInput, formatter: integerFormatter)
                                .font(.title2)
                                .fontWeight(.bold)
                                .keyboardType(.numberPad)
                                .autocorrectionDisabled(true)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("to player:")
                                .font(.title2)
                            Spacer()
                            Menu {
                                ForEach(gameSession.players.filter { $0.id != player.id }) { otherPlayer in
                                    Button(action: {
                                        self.selectedPlayer = otherPlayer
                                    }) {
                                        Text(otherPlayer.name)
                                    }
                                }
                            } label: {
                                Label(selectedPlayer?.name ?? "Select Player", systemImage: "chevron.down.circle.fill")
                            }
                            .buttonStyle(.bordered)
                            Button {
                                if let selectedPlayer = selectedPlayer {
                                    gameSession.perform(.payPlayer(selectedPlayer.id, amount: sendAmount), by: player.id)
                                    sendInput = nil
                                }
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title)
                                    .foregroundColor(selectedPlayer == nil ? .gray : .blue)
                            }
                            .disabled(selectedPlayer == nil)
                        }
                    }
                    .padding(5)
                }
            }
            
            Spacer()
        }
        .navigationTitle("Player #\(playerIndex)")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        // Shared photo change/add/remove flow (see PlayerPhotoPicker.swift)
        .playerPhotoPicker(isPresented: $showingPhotoDialog,
                           imageData: photoBinding,
                           isLoading: $isLoadingPhoto)
        .onAppear {
            // Seed the salary field from the stored salary.
            let currentSalary = gameSession.currentState.playerSalaries[player.id] ?? 200
            salaryInput = currentSalary
        }
        .onChange(of: salaryInput) {
            // Persist salary edits immediately so the Collect button label and collect logic stay in sync.
            gameSession.perform(.updateSalary(newSalary: salaryAmount), by: player.id)
        }
    }
}


#if DEBUG
#Preview("Player #1") {
        // GameSession is a class; build it outside the ViewBuilder scope, mutate in onAppear.
        let previewGameSession = GameSession()

        let playerAlice = Player(id: UUID().uuidString, name: "Alice", token: "car", isLocalOnly: true, salary: 200)
        let playerBob = Player(id: UUID().uuidString, name: "Bob", token: "top.hat.fill", isLocalOnly: true, salary: 200)

        NavigationView {
            PlayerView(player: playerAlice, playerIndex: 1)
                .environmentObject(previewGameSession)
                .onAppear {
                    // MARK: - Perform Data Setup INSIDE onAppear
                    previewGameSession.players.append(playerAlice)
                    previewGameSession.players.append(playerBob)

                    previewGameSession.perform(.addMoney(amount: 1500), by: playerAlice.id)
                    previewGameSession.perform(.payPlayer(playerAlice.id, amount: 200), by: playerBob.id)
                    previewGameSession.perform(.subtractMoney(amount: 2000), by: playerAlice.id)
                    previewGameSession.perform(.collectSalary(amount: 200), by: playerBob.id)
                }
        }
}

#Preview("Player #2") {
        // GameSession is a class; build it outside the ViewBuilder scope, mutate in onAppear.
        let previewGameSession = GameSession()

        let playerAlice = Player(id: UUID().uuidString, name: "Alice", token: "red", isLocalOnly: true, salary: 200)
        let playerBob = Player(id: UUID().uuidString, name: "Bob", token: "green", isLocalOnly: true, salary: 200)

        NavigationView {
            PlayerView(player: playerBob, playerIndex: 2)
                .environmentObject(previewGameSession)
                .onAppear {
                    // MARK: - Perform Data Setup INSIDE onAppear
                    previewGameSession.players.append(playerAlice)
                    previewGameSession.players.append(playerBob)

                    previewGameSession.perform(.addMoney(amount: 1500), by: playerAlice.id)
                    previewGameSession.perform(.payPlayer(playerAlice.id, amount: 200), by: playerBob.id)
                    previewGameSession.perform(.subtractMoney(amount: 2000), by: playerAlice.id)
                    previewGameSession.perform(.collectSalary(amount: 200), by: playerBob.id)
                }
        }
}
#endif
