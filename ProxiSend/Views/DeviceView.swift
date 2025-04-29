//
//  DeviceView.swift
//  ProxiSend
//
//  Created by Jackson Currie on 29/04/2025.
//

import SwiftUI

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

#Preview {
    DeviceView(name: "Test device", isSending: false, onTap: {})
}
