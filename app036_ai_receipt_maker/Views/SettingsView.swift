//
//  SettingsView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var paywallManager = UniversalPaywallManager.shared
    @State private var showingFeedback = false
    
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
                    paywallManager.showPaywall(triggerSource: "settings_upgrade_button")
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
                
                Button("フィードバックを送信") {
                    showingFeedback = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingFeedback) {
            FeedbackView(feedbackService: FeedbackService(gasEndpointURL: APIConfiguration.feedbackGASEndpointURL))
        }
    }
}

#Preview {
    SettingsView()
}