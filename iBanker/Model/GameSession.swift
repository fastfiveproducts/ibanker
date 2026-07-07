//
//  GameSession.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/23/25.
//


import Foundation
import SwiftUI
import SwiftData

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

    // SwiftData context for the Activity Log, injected from the view layer (see
    // MainTabView). Optional because GameSession is created before the SwiftData
    // container exists in the environment.
    var modelContext: ModelContext?

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
        logActivity(for: action, by: playerID, at: tx.timestamp)
    }

    // MARK: - Activity Log
    // The Activity Log is a derived side effect of the transaction log: each
    // performed action is also recorded as a human-readable ActivityLogEntry in
    // SwiftData. `perform` stays the single source of truth — the log is never a
    // second source of state.
    private func logActivity(for action: GameAction, by playerID: String, at timestamp: Date) {
        guard let modelContext else { return }
        guard let description = activityDescription(for: action, by: playerID) else { return }
        modelContext.insert(ActivityLogEntry(description, timestamp: timestamp))
    }

    private func playerName(for id: String) -> String {
        players.first(where: { $0.id == id })?.name ?? "A player"
    }

    // Returns a human-readable sentence for the action, or nil to skip logging.
    // `updateSalary` is intentionally not logged: the salary field syncs on every
    // keystroke, which would flood the log.
    private func activityDescription(for action: GameAction, by playerID: String) -> String? {
        let name = playerName(for: playerID)
        switch action {
        case .collectSalary(let amount):
            return "\(name) collected $\(amount) salary."
        case .payPlayer(let recipientID, let amount):
            return "\(name) sent $\(amount) to \(playerName(for: recipientID))."
        case .addMoney(let amount):
            return "\(name) added $\(amount)."
        case .subtractMoney(let amount):
            return "\(name) subtracted $\(amount)."
        case .resetPlayer(let balance, let salary):
            return "\(name) was reset to $\(balance) and $\(salary) salary."
        case .updateSalary:
            return nil
        case .custom(let description):
            return description
        }
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
