//
//  SettingsView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @ObservedObject private var paywallManager = UniversalPaywallManager.shared
    @State private var showingFeedback = false
    @State private var currentUsage: UsageTracker?
    @Query private var usageTrackers: [UsageTracker]
    
    private var subscriptionService = SubscriptionService()
    
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
                        Text(paywallManager.isPremiumActive ? "Premium" : "Free")
                            .foregroundColor(paywallManager.isPremiumActive ? .green : .orange)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text(paywallManager.isPremiumActive ? "Daily Generations:" : "Lifetime Generations:")
                        Spacer()
                        Text(getUsageText())
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                if !paywallManager.isPremiumActive {
                    Button("Upgrade to Premium") {
                        paywallManager.showPaywall(triggerSource: "settings_upgrade_button")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Premium Active")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer()
                
                if !paywallManager.isPremiumActive {
                    Text("Premium users get:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("10 generations per day", systemImage: "checkmark.circle.fill")
                        Label("No watermarks on saved images", systemImage: "checkmark.circle.fill")
                        Label("Priority support", systemImage: "checkmark.circle.fill")
                    }
                    .foregroundColor(.green)
                }
                
                Spacer()
                
                Button("Send Feedback") {
                    showingFeedback = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .onAppear {
                refreshUsageStatus()
            }
            .onChange(of: paywallManager.isPremiumActive) { _, _ in
                refreshUsageStatus()
            }
        }
        .sheet(isPresented: $showingFeedback) {
            FeedbackView(feedbackService: FeedbackService(gasEndpointURL: APIConfiguration.feedbackGASEndpointURL))
        }
    }
    
    private func getUsageText() -> String {
        if let usage = currentUsage {
            if paywallManager.isPremiumActive {
                return "\(usage.generationCount) / 10"
            } else {
                return "\(usage.lifetimeUsageCount) / 2"
            }
        }
        return paywallManager.isPremiumActive ? "0 / 10" : "0 / 2"
    }
    
    private func refreshUsageStatus() {
        let isPremium = paywallManager.isPremiumActive
        
        if isPremium {
            let today = Calendar.current.startOfDay(for: Date())
            currentUsage = usageTrackers.first { tracker in
                tracker.date == today && tracker.isPremiumUser == true
            }
        } else {
            currentUsage = usageTrackers.first { tracker in
                tracker.isPremiumUser == false
            }
        }
    }
}

#Preview {
    SettingsView()
}