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
    
    @State private var salaryInput: Int? = nil
    @State private var addInput: Int? = nil
    @State private var subtractInput: Int? = nil
    @State private var sendInput: Int? = nil
    @State private var selectedPlayer: Player? = nil

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
            // You would add more details and functionality here,
            // such as buttons to modify balance, transaction history, etc.
        }
        .navigationTitle("Player #\(playerIndex)") // Sets the title of the detail view's navigation bar
        .navigationBarTitleDisplayMode(.inline) // Makes the title smaller and centered
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // When the view loads, set the TextField's text to the stored salary.
            let currentSalary = gameSession.currentState.playerSalaries[player.id] ?? 200
            salaryInput = currentSalary
        }
        // --- MODIFIED ---
        // This modifier watches for any changes to the text field's input.
        .onChange(of: salaryInput) {
            // As soon as the text changes, update the salary in the GameSession.
            // This ensures the button's label and the collect salary logic are always in sync.
            gameSession.perform(.updateSalary(newSalary: salaryAmount), by: player.id)
        }
    }
}

#Preview("Player #1") {
        // Create the GameSession instance *outside* the ViewBuilder's direct scope.
        // It's a class, so it's a reference type.
        let previewGameSession = GameSession()

        // Define your players here
        let playerAlice = Player(id: UUID().uuidString, name: "Alice", token: "car", isLocalOnly: true, salary: 200)
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
        let previewGameSession = GameSession()

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
