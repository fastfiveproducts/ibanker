//
//  ibankerInterfaceDesignApp.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/16/25.
//

import SwiftUI

@main
struct ibankerInterfaceDesignApp: App {
    // 1. Declare and initialize your GameSession using @StateObject
     @StateObject private var gameSession: GameSession = {
         // This closure runs only once when the app starts.

         // Example: Try to load a saved game first
         if let loadedSession = GameSession.loadGame() {
             print("Game loaded successfully!")
             return loadedSession
         } else {
             // If no saved game, create a brand new one with NO default players.
             // The `players` array is empty here.
             print("Starting a new game with no default players.")
             return GameSession(players: [])
         }
     }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(gameSession) // This line is key!
                .onDisappear {
                    // This is a good place to save the game when the app is being closed
                    // or moved to the background.
                    gameSession.saveGame()
                }
        }
    }
}
