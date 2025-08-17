//
//  GameSession.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/23/25.
//


import Foundation
import Combine // For ObservableObject and @Published

class GameSession: ObservableObject {
    @Published var players: [Player]
    @Published var transactions: [GameTransaction]
    
    // Add a direct reference to SettingsStore
    // You could also initialize it here, or inject it from your App struct.
    // For simplicity, let's assume a single, shared instance is acceptable for now.
    // If you plan to have multiple GameSessions (e.g., different saved games),
    // you might want to pass SettingsStore as an initializer parameter.
    var settings: SettingsStore = SettingsStore() // Create or get your shared settings instance
    
    var currentState: GameState {
        GameStateReducer.reduce(players: players, transactions: transactions)
    }
    
    @Published var currentPlayerID: String? // switch with tap in pass-the-phone mode (Future)
        
    // Future: this can map to Google Sheet or Firebase session
    var gameSessionID: String?
    var isSyncedGame: Bool { gameSessionID != nil }
    
    init(players: [Player], transactions: [GameTransaction] = [], currentPlayerID: String? = nil) {
        self.players = players
        self.transactions = transactions
        self.currentPlayerID = currentPlayerID
    }
    
    // Add a transaction
    func perform(_ action: GameAction, by playerID: String) {
        let tx = GameTransaction(
            id: UUID().uuidString,
            timestamp: Date(),
            playerID: playerID,
            action: action,
            note: nil
        )
        transactions.append(tx)
    }
    
    /// Example of how you might implement undo (simplistic, real undo is more complex)
    func undoLastTransaction() {
        if !transactions.isEmpty {
            transactions.removeLast()
        }
    }
    
    // MARK: - Persistence (Example - you'd likely use FileManager, UserDefaults, or CloudKit/Firebase)
    
    // Example: Save to UserDefaults
    func saveGame() {
        if let encodedData = try? JSONEncoder().encode(self.transactions) {
            UserDefaults.standard.set(encodedData, forKey: "gameTransactions")
        }
        if let encodedPlayers = try? JSONEncoder().encode(self.players) {
            UserDefaults.standard.set(encodedPlayers, forKey: "gamePlayers")
        }
        // Save current player ID, etc.
    }
    
    // Example: Load from UserDefaults
    static func loadGame() -> GameSession? {
        if let transactionData = UserDefaults.standard.data(forKey: "gameTransactions"),
           let loadedTransactions = try? JSONDecoder().decode([GameTransaction].self, from: transactionData),
           let playerData = UserDefaults.standard.data(forKey: "gamePlayers"),
           let loadedPlayers = try? JSONDecoder().decode([Player].self, from: playerData) {
            return GameSession(players: loadedPlayers, transactions: loadedTransactions)
        }
        return nil
    }
    
}
