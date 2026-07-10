//
//  KeyboardDoneToolbar.swift
//
//  Created by Claude, Fast Five Products LLC, on 7/9/26.
//  Modified by Pete Maiser, Fast Five Products LLC, on 7/10/26.
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

/// A "Done" accessory above the keyboard that clears the given focus to
/// dismiss it — the standard system answer to number pads having no Return
/// key (#35). Placement rules, established empirically in #35/#37 (each
/// wrong placement was shipped once):
/// - Pushed screens and sheets: apply `.keyboardDoneToolbar(focus:)` once,
///   on the screen's Form/List/container itself.
/// - TAB-hosted Forms (e.g. SettingsView): Form-level and mainToolbar
///   attachments never render — keyboard toolbar items reach the keyboard
///   only when declared inside a list cell. Attach to exactly ONE row:
///   every row's declaration contributes a button simultaneously, so a
///   multi-row (Section-level) attachment shows multiple Done buttons.
/// #6's K/M/000 shortcut buttons would extend this same accessory.
struct KeyboardDoneToolbar<Field: Hashable>: ToolbarContent {
    var focus: FocusState<Field?>.Binding

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button("Done") { focus.wrappedValue = nil }
        }
    }
}

extension View {
    /// Attach the shared Done accessory to a pushed/sheet screen's container
    /// (see KeyboardDoneToolbar's placement rules).
    func keyboardDoneToolbar<Field: Hashable>(focus: FocusState<Field?>.Binding) -> some View {
        toolbar {
            KeyboardDoneToolbar(focus: focus)
        }
    }
}


#if DEBUG
private struct KeyboardDoneToolbarPreview: View {
    private enum Field { case amount }
    @FocusState private var focusedField: Field?
    @State private var amount: Int? = nil

    var body: some View {
        Form {
            TextField("Enter Amount", value: $amount, format: .number)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .amount)
        }
        .keyboardDoneToolbar(focus: $focusedField)
    }
}

#Preview {
    KeyboardDoneToolbarPreview()
}
#endif
