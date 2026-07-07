//
//  MainTabView.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/22/25.
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
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//

import SwiftUI
import SwiftData

// MARK: - Main Tab Bar View
struct MainTabView: View {
    @EnvironmentObject private var gameSession: GameSession
    @Environment(\.modelContext) private var modelContext

    // State to keep track of the currently selected tab
    @State private var selectedTab: Tab = .home

    var body: some View {
        // TabView is the container for the tab bar
        TabView(selection: $selectedTab) {
            // Home Page
            HomeView()
                .tabItem {
                    // Label for the tab item, including a token and text
                    Label("Home", systemImage: "house.fill")
                }
                // Assign a tag to each view so TabView can identify them
                .tag(Tab.home)
            
            // Activity Log Page
            ActivityLogView()
                .tabItem {
                    Label("Activity", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(Tab.activityLog)

            // Settings Page
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear.circle.fill")
                }
                .tag(Tab.settings)
        }
        // Apply the accent color to the selected tab item
        .accentColor(.accentColor) // Using .accentColor will pick up the accent color defined in your Asset Catalog or the system default
        // Hand the shared GameSession the SwiftData context so performed actions
        // are recorded to the Activity Log (see GameSession.perform).
        .task {
            gameSession.modelContext = modelContext
        }
    }
}

// MARK: - Enum for Tabs
// Define an enum to clearly represent each tab
enum Tab {
    case home
    case settings
    case activityLog
}

#Preview {
    let previewGameSession = GameSession()
    MainTabView()
        .environmentObject(previewGameSession)
        .environmentObject(previewGameSession.settings)
        .modelContainer(for: ActivityLogEntry.self, inMemory: true)
}
