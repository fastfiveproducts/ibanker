//
//  PlayerImageMaker.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 7/7/26.
//
//  Template v0.2.0 — Fast Five Products LLC's public AGPL template.
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
//  For licensing inquiries, contact: licenses@fastfiveproducts.com
//

import UIKit

/// SwiftUI-era analog of v1.3.0's GameImageMaker.makeSquareImage(size:):
/// aspect-fill center-crop a picked image to a small square and JPEG-compress
/// it, so the stored blob stays small enough to live inline in the players
/// @AppStorage JSON. Rounded corners are applied at display time by
/// PlayerThumbnailView rather than baked into the stored pixels.
enum PlayerImageMaker {

    /// 120px ≈ a 2x-Retina version of v1.3.0's 54pt thumbnail.
    static let defaultSide: CGFloat = 120

    static func squareJPEGData(from image: UIImage,
                               side: CGFloat = defaultSide,
                               compressionQuality: CGFloat = 0.7) -> Data? {
        guard image.size.width > 0, image.size.height > 0, side > 0 else { return nil }

        let targetSize = CGSize(width: side, height: side)

        // Scale to fill the square while keeping aspect ratio, then center.
        let ratio = max(targetSize.width / image.size.width,
                        targetSize.height / image.size.height)
        let scaledSize = CGSize(width: image.size.width * ratio,
                                height: image.size.height * ratio)
        let origin = CGPoint(x: (targetSize.width - scaledSize.width) / 2.0,
                             y: (targetSize.height - scaledSize.height) / 2.0)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1  // stored pixels are exactly side x side
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let squared = renderer.image { _ in
            image.draw(in: CGRect(origin: origin, size: scaledSize))
        }
        return squared.jpegData(compressionQuality: compressionQuality)
    }
}
