//
//  ActivityLogView.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/5/25.
//
//  Template v0.2.0 — Fast Five Products LLC's public AGPL template.
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

struct ActivityLogView: View, DebugPrintable {
    @EnvironmentObject var gameSession: GameSession
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ActivityLogEntry.timestamp) var logEntries: [ActivityLogEntry]
    
    var showTitle: Bool = true
    
    var body: some View {
        VStack {
            if showTitle {
                HStack {
                    Text("Activity Log")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            
            List {
                if logEntries.isEmpty {
                    Text("No activity logged yet.")
                } else {
                    ForEach(logEntries) { entry in
                        HStack {
                            Text(entry.event)
                            Spacer()
                            Text(entry.timestamp, style: .time)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Spacer()
            Button("Clear All Logs") {
                clearAllLogs()
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private func clearAllLogs() {
        withAnimation {
            for entry in logEntries {
                modelContext.delete(entry)
            }
        }
    }
}



#Preview {
    let sampleGameSession = GameSession()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ActivityLogEntry.self, configurations: config)
    
    for task in ActivityLogEntry.testObjects {
        container.mainContext.insert(task)
    }
    
    return ActivityLogView()
        .modelContainer(container)
        .environmentObject(sampleGameSession)
}

