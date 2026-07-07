//
//  ibankerInterfaceDesignApp.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/16/25.
//

import SwiftUI
import SwiftData

@main
struct iBankerApp: App {

    @StateObject private var gameSession = GameSession()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(gameSession) // This line is key!
                .onDisappear {
                    // Call the save function when the app is closed or backgrounded
                    gameSession.saveGame()
                }
        }
        // Provide the SwiftData container for the Activity Log. Without this the
        // Activity tab's @Query has no container and crashes at runtime.
        .modelContainer(for: ActivityLogEntry.self)
    }
}
