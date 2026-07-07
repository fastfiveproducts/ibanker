//
//  ViewConfiguration.swift
//
//  Created by Elizabeth Maiser, Fast Five Products LLC, on 8/16/25.
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

// The "ViewConfiguration" struct contains smallish settings, config, and ref data
// specific to SwiftUI and this application that are generally hard-coded
// here or inferred quickly upon app startup
struct ViewConfiguration {
    
    static let dynamicSizeMax = DynamicTypeSize.xxxLarge
    
}


#if DEBUG
var isPreview: Bool { return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
#endif
