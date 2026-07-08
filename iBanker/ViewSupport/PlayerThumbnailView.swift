//
//  PlayerThumbnailView.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 7/7/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/8/26.
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

import SwiftUI

/// The single reusable player-photo thumbnail, shared by HomeView rows,
/// the PlayerView header, and AddNewPlayerView's photo row: a rounded
/// square (v1.3.0 style) with an SF-Symbol placeholder when the player has
/// no photo.
struct PlayerThumbnailView: View {
    let imageData: Data?
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.square.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(.systemGray3))
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .accessibilityLabel(imageData == nil ? "No player photo" : "Player photo")
    }
}


#if DEBUG
#Preview {
    HStack(spacing: 20) {
        PlayerThumbnailView(imageData: nil)
        PlayerThumbnailView(imageData: nil, size: 60)
    }
    .padding()
}
#endif
