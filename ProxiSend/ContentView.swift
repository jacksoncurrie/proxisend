//
//  ContentView.swift
//  ProxiSend
//
//  Created by Jackson Currie on 16/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var textInput: String = ""
    @State private var showInfoAlert = false
    @State private var showPopup = false
    @State private var nearbyDevices: [String] = [
        "Jackson's iPhone",
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $textInput)
                        .frame(height: 180)
                        .padding(8)
                        .scrollContentBackground(.hidden)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    if textInput.isEmpty {
                        Text("Enter text")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                }
                HStack {
                    Text("Send to device")
                        .font(.title3)
                    Spacer()
                    ProgressView()
                }
                .padding(.top)
                .padding(.bottom, 4)
                if nearbyDevices.isEmpty {
                    Text("Open ProxiSend on another device nearby to see it appear here ready for sharing.")
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(nearbyDevices, id: \.self) { device in
                                DeviceView(
                                    name: device,
                                    isSending: false,
                                    onTap: {
                                        print("Tapped")
                                    }
                                )
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("ProxiSend")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showPopup = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .alert(isPresented: $showInfoAlert) {
                Alert(
                    title: Text("About ProxiSend"),
                    message: Text("ProxiSend lets you send text and data between nearby devices, just open the app on another device to see it show up here."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showPopup) {
                MessageView()
                    .presentationDetents([.height(340)])
            }
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

struct MessageView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: .constant("Here is your message"))
                    .frame(height: 180)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                Button(action: {
                    UIPasteboard.general.string = "Message"
                }) {
                    HStack {
                        Image(systemName: "document.on.document")
                        Text("Copy")
                    }
                }
                .padding(.vertical)
                Spacer()
            }
            .padding()
            .navigationBarTitle("Message recieved", displayMode: .inline)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
