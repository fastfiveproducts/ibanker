//
//  PlayerPhotoPicker.swift
//
//  Created by Pete Maiser, Fast Five Products LLC, on 7/8/26.
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
import PhotosUI

/// The shared player-photo capture flow (issue #20's photo feature and its
/// change-photo follow-up, shipped with PR #29): a confirmation dialog
/// offering camera (when available) or photo library — mirroring v1.3.0's
/// action sheet — plus a confirmed Remove Photo when one is set. Handles the
/// async library load with supersede cancellation, surfaces load failure as
/// an alert, and stores a small square JPEG via PlayerImageMaker.
/// Used by AddNewPlayerView (creation) and PlayerView (change/remove).
struct PlayerPhotoPickerModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var imageData: Data?
    @Binding var isLoading: Bool

    @State private var showingCameraPicker = false
    @State private var showingLibraryPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var photoLoadTask: Task<Void, Never>? = nil
    @State private var showingLoadFailedAlert = false
    @State private var showingRemoveConfirm = false

    // A later user action (camera capture, photo removal) must beat any
    // slow library load still in flight — cancel it so the stale load
    // can't land afterwards and overwrite the user's last choice.
    private func supersedeInFlightLoad() {
        photoLoadTask?.cancel()
        isLoading = false
    }

    func body(content: Content) -> some View {
        content
            .confirmationDialog("Player Photo", isPresented: $isPresented, titleVisibility: .visible) {
                if CameraImagePicker.isCameraAvailable {
                    Button("Take Picture") { showingCameraPicker = true }
                }
                Button("Photo Library") { showingLibraryPicker = true }
                if imageData != nil {
                    Button("Remove Photo", role: .destructive) { showingRemoveConfirm = true }
                }
                Button("Cancel", role: .cancel) { }
            }
            .photosPicker(isPresented: $showingLibraryPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) {
                guard let item = selectedPhotoItem else { return }
                // Supersede any in-flight load so a re-pick can't be
                // overwritten by an older, slower load finishing last.
                photoLoadTask?.cancel()
                isLoading = true
                photoLoadTask = Task {
                    let data = try? await item.loadTransferable(type: Data.self)
                    guard !Task.isCancelled else { return }  // a newer pick owns the state now
                    if let data,
                       let uiImage = UIImage(data: data),
                       let squareData = PlayerImageMaker.squareJPEGData(from: uiImage) {
                        imageData = squareData
                    } else {
                        // Async result the user waited on -> alert, not silence
                        showingLoadFailedAlert = true
                    }
                    isLoading = false
                    selectedPhotoItem = nil
                }
            }
            // Camera capture must be full screen (Apple documents iPad camera
            // capture as full-screen-only; a page sheet can distort the preview).
            .fullScreenCover(isPresented: $showingCameraPicker) {
                CameraImagePicker { uiImage in
                    supersedeInFlightLoad()
                    imageData = PlayerImageMaker.squareJPEGData(from: uiImage)
                }
                .ignoresSafeArea()
            }
            .alert("Could Not Load Photo", isPresented: $showingLoadFailedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The selected photo could not be loaded. Please try another photo.")
            }
            .alert("Remove Photo?", isPresented: $showingRemoveConfirm) {
                Button("Remove", role: .destructive) {
                    supersedeInFlightLoad()
                    imageData = nil
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("The player's photo will be removed.")
            }
    }
}

extension View {
    /// Attach the shared player-photo capture flow; present it by setting
    /// `isPresented` (e.g. from a photo-row button or a tappable thumbnail).
    func playerPhotoPicker(isPresented: Binding<Bool>,
                           imageData: Binding<Data?>,
                           isLoading: Binding<Bool>) -> some View {
        modifier(PlayerPhotoPickerModifier(isPresented: isPresented,
                                           imageData: imageData,
                                           isLoading: isLoading))
    }
}
