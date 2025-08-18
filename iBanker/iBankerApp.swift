//
//  ibankerInterfaceDesignApp.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/16/25.
//

import SwiftUI

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
    }
}
