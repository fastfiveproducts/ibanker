//
//  PlayerView.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/22/25.
//

import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var gameSession: GameSession // Access the shared game session
    
    let player: Player
    let playerIndex: Int
    
    var body: some View {
        VStack {
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
                            // Player Name and Token Name
                            Text("Balance:")
                                .font(.title2)
                                .accessibilityLabel("Text: Balance")
                            
                            Spacer()
                            
                            // Player Balance
                            Text("$\(gameSession.currentState.playerBalances[player.id] ?? 0)")
                                .font(.title2) // Prominent font for the balance
                                .fontWeight(.bold)
                                .foregroundColor(
                                    (gameSession.currentState.playerBalances[player.id] ?? 0) >= 0 ? .green : .red
                                )
                        }
                        .padding(5)
                        HStack {
                            // Player Name and Token Name
                            Text("Salary:")
                                .font(.title2)
                                .accessibilityLabel("Text: Salary")
                            
                            Spacer()
                            
                            // Player Balance
                            /*
                             TextField()
                             .font(.title2) // Prominent font for the balance
                             .fontWeight(.bold)
                             
                             .accessibilityLabel("Player balance: \(player.balance) dollars")
                             */
                        }
                        .padding(5)
                }
                Section {
                    HStack {
                        Text("Add $:")
                            .font(.title2)
                        Spacer()
                    }
                    .padding(5)
                    HStack {
                        Text("Subtract $:")
                            .font(.title2)
                        Spacer()
                    }
                    .padding(5)
                    VStack {
                        HStack {
                            Text("Send Amount:")
                                .font(.title2)
                            Spacer()
                            
                        }
                        HStack {
                            Text("to player:")
                                .font(.title2)
                            Spacer()
                            
                        }
                    }
                    .padding(5)
                }
            }
            
            Spacer()
            // You would add more details and functionality here,
            // such as buttons to modify balance, transaction history, etc.
        }
        .navigationTitle("Player #\(playerIndex)") // Sets the title of the detail view's navigation bar
        .navigationBarTitleDisplayMode(.inline) // Makes the title smaller and centered
        .background(Color(.systemGroupedBackground))
    }
}

#Preview("Player #1") {
        // Create the GameSession instance *outside* the ViewBuilder's direct scope.
        // It's a class, so it's a reference type.
        let previewGameSession = GameSession(players: [])

        // Define your players here
        let playerAlice = Player(id: UUID().uuidString, name: "Alice", token: "car.fill", isLocalOnly: true, salary: 200)
        let playerBob = Player(id: UUID().uuidString, name: "Bob", token: "top.hat.fill", isLocalOnly: true, salary: 200)

        // Now, construct your View. All data manipulation will happen inside onAppear.
        NavigationView {
            PlayerView(player: playerAlice, playerIndex: 1) // Pass the specific player for this preview
                .environmentObject(previewGameSession) // Inject the session
                .onAppear {
                    // MARK: - Perform Data Setup INSIDE onAppear
                    // This closure executes when the view appears in the preview.
                    // Here, imperative code is allowed!
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
        // Create the GameSession instance *outside* the ViewBuilder's direct scope.
        // It's a class, so it's a reference type.
        let previewGameSession = GameSession(players: [])

        // Define your players here
        let playerAlice = Player(id: UUID().uuidString, name: "Alice", token: "red", isLocalOnly: true, salary: 200)
        let playerBob = Player(id: UUID().uuidString, name: "Bob", token: "green", isLocalOnly: true, salary: 200)

        // Now, construct your View. All data manipulation will happen inside onAppear.
        NavigationView {
            PlayerView(player: playerBob, playerIndex: 2) // Pass the specific player for this preview
                .environmentObject(previewGameSession) // Inject the session
                .onAppear {
                    // MARK: - Perform Data Setup INSIDE onAppear
                    // This closure executes when the view appears in the preview.
                    // Here, imperative code is allowed!
                    previewGameSession.players.append(playerAlice)
                    previewGameSession.players.append(playerBob)

                    previewGameSession.perform(.addMoney(amount: 1500), by: playerAlice.id)
                    previewGameSession.perform(.payPlayer(playerAlice.id, amount: 200), by: playerBob.id)
                    previewGameSession.perform(.subtractMoney(amount: 2000), by: playerAlice.id)
                    previewGameSession.perform(.collectSalary(amount: 200), by: playerBob.id)
                }
        }
}
