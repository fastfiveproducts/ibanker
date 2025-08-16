//
//  ViewConfiguration.swift
//  iBanker
//
//  Created by Elizabeth Maiser on 8/16/25.
//  Copyright © 2025 Pete Maiser. All rights reserved.
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
