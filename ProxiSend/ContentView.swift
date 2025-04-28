//
//  ContentView.swift
//  ProxiSend
//
//  Created by Jackson Currie on 16/02/2025.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State private var showInfoAlert = false

    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("app_name", comment: "The name of the app"))
                .font(.largeTitle)
                .bold()
                .padding(.top)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.textInput)
                    .frame(height: 180)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                if viewModel.textInput.isEmpty {
                    Text(NSLocalizedString("textbox_hint", comment: "Placeholder to show where to enter text"))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                        .allowsHitTesting(false)
                }
            }
            HStack {
                Text(NSLocalizedString("send_title", comment: "Title for sending the text to a device"))
                    .font(.title3)
                Spacer()
                ProgressView()
            }
            .padding(.top)
            .padding(.bottom, 4)
            if !viewModel.isEnabled {
                Text(NSLocalizedString("bluetooth_disabled", comment: "Message when Bluetooth is not enabled"))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            } else if viewModel.devices.isEmpty {
                Text(NSLocalizedString("devices_empty", comment: "Message when no devices are found nearby"))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.devices, id: \.identifier) { device in
                            DeviceView(
                                name: device.name ?? "Unknown",
                                isSending: device.identifier == viewModel.loadingDevice,
                                onTap: {
                                    guard viewModel.loadingDevice == nil else { return }
                                    viewModel.tapDevice(device)
                                }
                            )
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            Spacer()
        }
        .frame(maxWidth: 600)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .sheet(isPresented: $viewModel.showPopup) {
            MessageView(text: viewModel.popupText)
                .presentationDetents([.height(340)])
        }
    }
}

struct DeviceView: View {
    let name: String
    let isSending: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.7))
                    .frame(width: 60, height: 60)
                
                if isSending {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                } else {
                    Text(String(name.prefix(1).uppercased()))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
            }

            Text(name)
                .font(.footnote)
                .bold()
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .truncationMode(.tail)
            
            Spacer()
        }
        .frame(width: 80, height: 108)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

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
    ContentView()
}
