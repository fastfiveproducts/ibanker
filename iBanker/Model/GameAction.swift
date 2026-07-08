//
//  GameAction.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 7/23/25.
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


import Foundation
enum GameAction: Codable, Equatable {
    case collectSalary(amount: Int)
    case payPlayer(_ playerID: String, amount: Int)
    case addMoney(amount: Int)
    case subtractMoney(amount: Int)
    case updateSalary(newSalary: Int)
    case resetPlayer(balance: Int, salary: Int)
    case createPlayer(balance: Int, salary: Int)
    case custom(description: String)
}
