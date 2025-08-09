//
//  SettingsView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("AI Receipt Maker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Subscription Status")
                        .font(.headline)
                    
                    HStack {
                        Text("Current Plan:")
                        Spacer()
                        Text("Free")
                            .foregroundColor(.orange)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Daily Generations:")
                        Spacer()
                        Text("0 / 2")
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Button("Upgrade to Premium") {
                    // TODO: Implement subscription upgrade
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Spacer()
                
                Text("Premium users get:")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("10 generations per day", systemImage: "checkmark.circle.fill")
                    Label("No watermarks on saved images", systemImage: "checkmark.circle.fill")
                    Label("Priority support", systemImage: "checkmark.circle.fill")
                }
                .foregroundColor(.green)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}