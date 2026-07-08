//
//  PlayerModel.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/22/25.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/7/26.
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


import Foundation

struct Player: Identifiable, Codable, Equatable {
    var id: String         // Could be UUID for now; later can be userID/email
    var name: String
    var token: String
    var isLocalOnly: Bool  // true for pass-the-phone mode
    var authProviderID: String? // Later: Google/Firebase ID
    var sheetRowIndex: Int?     // Optional: where in shared Sheet this player maps
    var salary: Int
    var imageData: Data?   // Small square JPEG (see PlayerImageMaker); optional so
                           // players persisted before photos existed decode unchanged
}
