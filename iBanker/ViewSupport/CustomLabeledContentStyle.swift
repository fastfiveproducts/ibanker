//
//  CustomLabeledContentStyle.swift
//  iBanker
//
//  Created by Elizabeth Maiser on 8/16/25.
//  Copyright © 2025 Pete Maiser. All rights reserved.
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

