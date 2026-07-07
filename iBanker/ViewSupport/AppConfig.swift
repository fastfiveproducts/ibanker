//
//  AppConfig.swift
//
//  Template created as ViewConfig.swift by Pete Maiser, July 2024 through May 2025
//  Renamed to AppConfig.swift by Claude, Fast Five Products LLC, on 7/6/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/8/26.
//      Template v0.4.3 (updated) — Fast Five Products LLC's public AGPL template.
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
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//


import SwiftUI

// The "AppConfig" ("App Configuration") struct contains branding,
// settings, config, and reference data specific to this implementation

struct AppConfig {
    static let dynamicSizeMax = DynamicTypeSize.xxxLarge

    // MARK: - App-Specific
    // Child projects customize: brand name, URLs, colors, feature flags,
    // appClientKey, bundledFeatureFlags, and timing values below.
    //
    // iBanker is local-only (no Firebase) and launches without the template's
    // splash/overlay choreography, so the template's launch-timing, feature
    // flag, multi-tenancy, video-background, and post-display entries are
    // omitted here — re-add them from the template when adopting those
    // features (see AGENTS.md, Template Relationship).

    static let brandName = "iBanker"

    static let privacyText = "Privacy Policy"
    static let privacyURL = URL(string: "https://www.fastfiveproducts.llc/")!

    static let supportText = "\(brandName) Support"
    static let supportURL = URL(string: "https://www.fastfiveproducts.llc/")!

    // Fixed Colors
    // Neutral, adaptive template defaults. The pre-upgrade AppColor palette is
    // preserved below for future branding:
    //   darkGreen  121/153/78    lightGreen 183/231/118
    //   offWhite   242/242/228   darkGray    41/41/38
    //   lightGray   97/97/84     red        231/118/127
    static let brandColor: Color =
        Color(.secondaryLabel)

    static let linkColor: Color =
        Color.accentColor

    static let bgColor: Color =
        Color(UIColor.systemBackground)

    static let fgColor =
        Color(.label)

}


#if DEBUG

#Preview ("Colors") {
    VStack(spacing: 12) {
        Text("brandColor").foregroundStyle(AppConfig.brandColor)
        Text("linkColor").foregroundStyle(AppConfig.linkColor)
        Text("fgColor on bgColor")
            .foregroundStyle(AppConfig.fgColor)
            .padding()
            .background(AppConfig.bgColor)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .dynamicTypeSize(...AppConfig.dynamicSizeMax)
}
#endif
