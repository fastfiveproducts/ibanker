//
//  GameSession.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/23/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/7/26.
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
    
    // Add a transaction. An optional note is stored on the transaction and,
    // when present, replaces the generated Activity Log sentence (e.g. the
    // spinner's "won the spin!" line).
    func perform(_ action: GameAction, by playerID: String, note: String? = nil) {
        // Money-movement actions with no dollars do nothing — no transaction,
        // no Activity Log entry, no sound. (Tapping Add/Subtract/Send — or
        // Collect Salary in a $0-salary mode — with an empty or $0 amount was
        // creating noisy zero-dollar transactions.)
        switch action {
        case .addMoney(let amount), .subtractMoney(let amount),
             .collectSalary(let amount), .payPlayer(_, let amount):
            guard amount > 0 else { return }
        case .updateSalary, .resetPlayer, .custom:
            break
        }

        let balanceBefore = currentState.playerBalances[playerID] ?? 0
        let tx = GameTransaction(
            id: UUID().uuidString,
            timestamp: Date(),
            playerID: playerID,
            action: action,
            note: note
        )
        transactions.append(tx)
        logActivity(for: action, by: playerID, at: tx.timestamp, note: note)
        // Actions carrying a custom note are specialized flows (e.g. the
        // spinner award) whose caller owns the sound — otherwise the win
        // sound and the generic money sound would overlap.
        if note == nil {
            playSound(for: action, by: playerID, balanceBefore: balanceBefore)
        }
    }

    // MARK: - Sound Effects
    // Like the Activity Log, sounds are a derived side effect of perform —
    // the sound-to-event map matches v1.3.0 (see SoundPlayer.swift).
    // Reset-players plays its (single) shake sound at the Settings level, not
    // here, so resetting N players doesn't play N sounds.
    private func playSound(for action: GameAction, by playerID: String, balanceBefore: Int) {
        switch action {
        case .addMoney, .collectSalary:
            SoundPlayer.shared.play(.cashRegister)
        case .subtractMoney:
            SoundPlayer.shared.play(.coinDrop)
        case .payPlayer:
            SoundPlayer.shared.play(.happy)
        case .updateSalary, .resetPlayer, .custom:
            break
        }

        // When a money-out action takes the acting player's balance from
        // non-negative to negative, follow with the sad sound (queued so it
        // plays after the action's own sound, matching v1.3.0).
        switch action {
        case .subtractMoney, .payPlayer:
            let balanceAfter = currentState.playerBalances[playerID] ?? 0
            if balanceBefore >= 0 && balanceAfter < 0 {
                SoundPlayer.shared.playQueued(.sad)
            }
        default:
            break
        }
    }

    // MARK: - Activity Log
    // The Activity Log is a derived side effect of the transaction log: each
    // performed action is also recorded as a human-readable ActivityLogEntry in
    // SwiftData. `perform` stays the single source of truth — the log is never a
    // second source of state.
    private func logActivity(for action: GameAction, by playerID: String, at timestamp: Date, note: String?) {
        guard let modelContext else { return }
        guard let description = note ?? activityDescription(for: action, by: playerID) else { return }
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
