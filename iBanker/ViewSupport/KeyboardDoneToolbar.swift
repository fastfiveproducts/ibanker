//
//  KeyboardDoneToolbar.swift
//
//  Created by Claude, Fast Five Products LLC, on 7/9/26.
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

extension View {
    /// A "Done" accessory above the keyboard that clears the given focus to
    /// dismiss it — the standard system answer to number pads having no Return
    /// key (#35). Apply once per screen: a second keyboard toolbar in the same
    /// hierarchy would duplicate the button. Shared by every numeric-entry
    /// screen; #6's K/M/000 shortcut buttons would extend this same accessory.
    func keyboardDoneToolbar<Field: Hashable>(focus: FocusState<Field?>.Binding) -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus.wrappedValue = nil }
            }
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
