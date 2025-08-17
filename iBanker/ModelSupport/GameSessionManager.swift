//
//  GameSessionManager.swift
//  iBanker
//
//  Created by Elizabeth Maiser on 8/17/25.
//  Copyright © 2025 Pete Maiser. All rights reserved.
//
/*
import Foundation

class GameSessionManager: ObservableObject {
    @Published var activeSession: GameSession?

    init() {
        // When the manager is created (at app launch),
        // it immediately tries to load a session.
        self.activeSession = GameSession.loadGame()
    }

    /// Creates a brand new game session, replacing any existing one.
    func startNewGame(players: [Player]) {
        let newSession = GameSession(players: players)
        self.activeSession = newSession
        self.activeSession?.saveGame() // Save the new game immediately
    }

    /// Ends the current game and deletes it from storage.
    func endGame() {
        GameSession.deleteSavedGame()
        self.activeSession = nil
    }
}
*/
