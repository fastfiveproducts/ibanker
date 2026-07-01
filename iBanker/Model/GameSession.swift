//
//  GameSession.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/23/25.
//


import Foundation
import SwiftUI

class GameSession: ObservableObject {
    @AppStorage("gamePlayers") private var playersData: Data = Data()
    @AppStorage("gameTransactions") private var transactionsData: Data = Data()
    
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
    
    init() {
        // Phase 1: Initialize all stored properties with a default value.
        // We MUST NOT use 'self' here. We use direct access to UserDefaults.
        // This is a special exception to the two-phase initialization rule.
        
        let initialPlayers = (try? JSONDecoder().decode([Player].self, from: UserDefaults.standard.data(forKey: "gamePlayers") ?? Data())) ?? []
        
        let initialTransactions = (try? JSONDecoder().decode([GameTransaction].self, from: UserDefaults.standard.data(forKey: "gameTransactions") ?? Data())) ?? []
        
        self.players = initialPlayers
        self.transactions = initialTransactions
    }
    
    func saveGame() {
        if let encodedPlayers = try? JSONEncoder().encode(self.players) {
            self.playersData = encodedPlayers
            print("Players saved successfully!")
        }
        
        if let encodedTransactions = try? JSONEncoder().encode(self.transactions) {
            self.transactionsData = encodedTransactions
            print("Transactions saved successfully!")
        }
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
    
}
