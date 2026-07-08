//
//  iBankerApp.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/16/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/7/26.
//
//  Template v0.2.0 (updated) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025, 2026 Fast Five Products LLC. All rights reserved.
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

import SwiftUI
import SwiftData

@main
struct iBankerApp: App {

    @StateObject private var gameSession = GameSession()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(gameSession) // This line is key!
                .environmentObject(gameSession.settings) // Single shared SettingsStore (#13)
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
