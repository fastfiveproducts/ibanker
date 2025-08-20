//
//  ActivityLogEntry.swift
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



extension ActivityLogEntry {
    static let testObjects: [ActivityLogEntry] = [
        ActivityLogEntry("test event"),
        ActivityLogEntry("another test event")
    ]
}

