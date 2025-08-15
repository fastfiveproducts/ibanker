//
//  MainTabView.swift
//  ibankerInterfaceDesign
//
//  Created by Elizabeth Maiser on 7/22/25.
//

import SwiftUI

// MARK: - Main Tab Bar View
struct MainTabView: View {
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
    MainTabView()
}
