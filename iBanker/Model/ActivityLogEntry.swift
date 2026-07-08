//
//  ActivityLogEntry.swift
//
//  Template file created by Elizabeth Maiser, Fast Five Products LLC, on 7/5/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/3/26.
//      Template v0.4.0 (updated) — Fast Five Products LLC's public AGPL template.
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


import Foundation
import SwiftData

@Model
final class ActivityLogEntry {
    var event: String
    var timestamp: Date
    
    init(_ event: String, timestamp: Date = Date()) {
        self.event = event
        self.timestamp = timestamp
    }
}


// MARK: - Retention
extension ActivityLogEntry {
    static let retentionCap = 1000

    // Trim to the retention cap: delete the oldest entries and insert a marker.
    // The marker takes the newest DELETED entry's timestamp so it sorts at the trim
    // point (top) in this timestamp-sorted @Query. It counts toward the cap — one
    // extra entry is deleted so the total lands exactly at the cap, and no further
    // trim runs until real growth exceeds the cap again (that trim clears the prior
    // marker too). Failure handling is soft (try? + guard): log maintenance must
    // never crash launch; a skipped trim self-heals on the next load.
    @MainActor
    static func trimToCap(in context: ModelContext, cap: Int = retentionCap) {
        guard let count = try? context.fetchCount(FetchDescriptor<ActivityLogEntry>()), count > cap else { return }
        var descriptor = FetchDescriptor<ActivityLogEntry>(sortBy: [SortDescriptor(\.timestamp, order: .forward)])
        descriptor.fetchLimit = count - cap + 1
        guard let oldest = try? context.fetch(descriptor), !oldest.isEmpty else { return }
        let markerTimestamp = oldest.last?.timestamp ?? Date()
        for entry in oldest { context.delete(entry) }
        context.insert(ActivityLogEntry("Oldest \(oldest.count) entries deleted to limit log size", timestamp: markerTimestamp))
        try? context.save()
    }
}


#if DEBUG
extension ActivityLogEntry {
    static let testObjects: [ActivityLogEntry] = [
        ActivityLogEntry("test event"),
        ActivityLogEntry("another test event")
    ]

    // Generator for large-log previews (windowing / "Show Earlier" behavior)
    static func makeTestObjects(count: Int) -> [ActivityLogEntry] {
        let now = Date()
        return (0..<count).map { i in
            ActivityLogEntry("test event #\(i + 1)", timestamp: now.addingTimeInterval(Double(i - count) * 60))
        }
    }
}
#endif
