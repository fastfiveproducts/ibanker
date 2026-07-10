//
//  IntegerFormatter.swift
//
//  Created by Claude, Fast Five Products LLC, on 7/10/26.
//
//  Copyright © 2026 Fast Five Products LLC. All rights reserved.
//
//  This file is part of a project licensed under the GNU Affero General Public License v3.0.
//  See the LICENSE file at the root of this repository for full terms.
//
//  An exception applies: Fast Five Products LLC retains the right to use this code and
//  derivative works in proprietary software without being subject to the AGPL terms.
//  See LICENSE-EXCEPTIONS.md for details.
//

import Foundation

extension NumberFormatter {
    /// The app's one money-entry formatter: plain integers — no grouping
    /// separators, no decimals. Shared by every money TextField (#37).
    static let integer: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        formatter.generatesDecimalNumbers = false
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}
