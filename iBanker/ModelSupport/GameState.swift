//
//  GameState.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/23/25.
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


import Foundation
struct GameState: Equatable, Codable {
    var playerBalances: [String: Int] // Player ID -> current balance
    var playerSalaries: [String: Int]
}
