//
//  ContentView.swift
//  ProxiSend
//
//  Created by Jackson Currie on 16/02/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section {
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
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                Section(header:
                    HStack {
                        Text(NSLocalizedString("send_title", comment: "Title for sending the text to a device"))
                            .font(.title3)
                            .foregroundColor(.primary)
                            .textCase(nil)
                        Spacer()
                        ProgressView()
                    }
                    .padding(.bottom, 8)
                    .padding(.top, 8)
                ) {
                    if !viewModel.isEnabled {
                        Text(NSLocalizedString("bluetooth_disabled", comment: "Message when Bluetooth is not enabled"))
                            .foregroundColor(.secondary)
                    } else if viewModel.devices.isEmpty {
                        Text(NSLocalizedString("devices_empty", comment: "Message when no devices are found nearby"))
                            .foregroundColor(.secondary)
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
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                Section(header:
                    HStack {
                        Text(NSLocalizedString("history_title", comment: "History of messages received"))
                            .font(.title3)
                            .foregroundColor(.primary)
                            .textCase(nil)
                        Spacer()
                        ProgressView()
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.bottom, 8)
                    .padding(.top, 8)
                ) {
                    if viewModel.historyItems.isEmpty {
                        Text(NSLocalizedString("no_history", comment: "Message when no history"))
                            .foregroundColor(.secondary)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewModel.historyItems, id: \.self) { item in
                            Button(action: {
                                print("Tapped")
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Jackson's iPhone")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Text("Here is a message that was sent. testing that is was quite long that it went off the side of the screen.")
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .contentShape(Rectangle())
                                .padding(.vertical, 2)
                            }
                            .accentColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle(NSLocalizedString("app_name", comment: "The name of the app"))
            .scrollDismissesKeyboard(.interactively)
        }
        .sheet(isPresented: $viewModel.showPopup) {
            MessageView(text: viewModel.popupText)
                .presentationDetents([.height(340)])
        }
    }
}

#Preview {
    ContentView()
}
