//
//  CustomLabeledContentStyle.swift
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

// custom Text Field LabeledContentStyle, 'Top Labeled':
struct TopLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .font(.caption)
            configuration.content
        }
    }
}

fileprivate struct TopLabelLabeledContentStylePreview: View {
    var labelText: String
    var promptText: String
    var text: Binding<String>
    @FocusState private var focusedFieldIndex: Int?
    var body: some View {
        LabeledContent {
            TextField(promptText, text:text)
                .textInputAutocapitalization(TextInputAutocapitalization.words)
                .disableAutocorrection(true)
                .onSubmit {}
                .focused($focusedFieldIndex, equals: 0)
        } label: { Text(labelText) }
            .labeledContentStyle(TopLabeledContentStyle())
    }
}


#Preview ("TopLabelLabeledContentStyle") {
    Form {
        Section {
            TopLabelLabeledContentStylePreview(
                labelText: "Your Name",
                promptText: "Name or Intitials",
                text: .constant(""))
            TopLabelLabeledContentStylePreview(
                labelText: "More Stuff",
                promptText: "stuff we want to know",
                text: .constant(""))
        }
    }
    .dynamicTypeSize(...ViewConfiguration.dynamicSizeMax)
}

