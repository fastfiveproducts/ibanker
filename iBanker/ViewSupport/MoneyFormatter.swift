//
//  MoneyFormatter.swift — renamed from IntegerFormatter.swift 7/11/26 (#45)
//
//  Created by Claude, Fast Five Products LLC, on 7/10/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/11/26.
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
    /// The app's one money-entry formatter, shared by every money TextField
    /// (#37). Committed values render like the money displays — "$2,000",
    /// grouped with a leading $ — while typing stays plain digits (the
    /// formatter only touches the text when editing ends). Lenient parsing
    /// re-normalizes whatever an edit leaves behind ("$2,0005" → 20005);
    /// empty text still parses to nil, so clear-to-unset behavior holds.
    /// No decimals — game money is whole dollars.
    static let money: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.generatesDecimalNumbers = false
        formatter.maximumFractionDigits = 0
        formatter.positivePrefix = "$"
        formatter.negativePrefix = "-$"
        formatter.isLenient = true
        return formatter
    }()
}
