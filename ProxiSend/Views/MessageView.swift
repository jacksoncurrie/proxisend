//
//  MessageView.swift
//  ProxiSend
//
//  Created by Jackson Currie on 29/04/2025.
//

import SwiftUI
import UIKit

struct SelectableTextView: UIViewRepresentable {
    let text: String
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}

struct MessageView: View {
    @Environment(\.dismiss) var dismiss
    let text: String
    
    var body: some View {
        NavigationView {
            VStack {
                SelectableTextView(text: text)
                    .frame(height: 180)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                Button(action: {
                    UIPasteboard.general.string = text
                }) {
                    HStack {
                        Image(systemName: "document.on.document")
                        Text(NSLocalizedString("copy", comment: "Copy text to clipboard"))
                    }
                }
                .padding(.vertical)
                Spacer()
            }
            .padding()
            .navigationBarTitle(NSLocalizedString("message_received", comment: "Title for new message"), displayMode: .inline)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .accessibilityLabel(NSLocalizedString("close", comment: "Close button"))
                    }
                }
            }
        }
    }
}

#Preview {
    MessageView(text: "Test message")
}

