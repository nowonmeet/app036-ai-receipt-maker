//
//  SettingsView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData
import SafariServices

struct SettingsView: View {
    @ObservedObject private var paywallManager = UniversalPaywallManager.shared
    @State private var showingFeedback = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var currentUsage: UsageTracker?
    @Query private var usageTrackers: [UsageTracker]
    
    private var subscriptionService = SubscriptionService()
    
    private let privacyPolicyURL = URL(string: "https://nowonmeet.github.io/legal_common/en/privacy.html")!
    private let termsOfServiceURL = URL(string: "https://nowonmeet.github.io/legal_common/en/terms.html")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    subscriptionStatusCard
                    
                    if !paywallManager.isPremiumActive {
                        upgradeCard
                        premiumFeaturesCard
                    } else {
                        premiumActiveCard
                    }
                    
                    feedbackCard
                    
                    legalCard
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
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
        .sheet(isPresented: $showingPrivacyPolicy) {
            SafariView(url: privacyPolicyURL)
        }
        .sheet(isPresented: $showingTermsOfService) {
            SafariView(url: termsOfServiceURL)
        }
    }
    
    private var subscriptionStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: paywallManager.isPremiumActive ? "crown.fill" : "person.circle")
                    .font(.title2)
                    .foregroundColor(paywallManager.isPremiumActive ? .yellow : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Plan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(paywallManager.isPremiumActive ? "Premium" : "Free")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(paywallManager.isPremiumActive ? .primary : .orange)
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(paywallManager.isPremiumActive ? "Daily Generations" : "Lifetime Generations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(getUsageText())
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: getUsageProgress(),
                    lineWidth: 6
                )
                .frame(width: 50, height: 50)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private var upgradeCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Upgrade to Premium")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    paywallManager.showPaywall(triggerSource: "settings_upgrade_button")
                }
            }) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Get Premium")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private var premiumFeaturesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Premium Features")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "infinity.circle.fill",
                    title: "10 generations per day",
                    color: .green
                )
                
                FeatureRow(
                    icon: "photo.badge.checkmark.fill",
                    title: "No watermarks",
                    color: .blue
                )
                
                FeatureRow(
                    icon: "headphones.circle.fill",
                    title: "Priority support",
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private var premiumActiveCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Premium Active")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Thank you for supporting the app!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.green.opacity(0.1), .blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(16)
    }
    
    private var feedbackCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "envelope.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Send Feedback")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Button(action: {
                showingFeedback = true
            }) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Contact Us")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.orange.opacity(0.1))
                .foregroundColor(.orange)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
    
    private var legalCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("Legal")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                LegalButton(
                    title: "Privacy Policy",
                    icon: "lock.shield.fill",
                    color: .blue
                ) {
                    showingPrivacyPolicy = true
                }
                
                LegalButton(
                    title: "Terms of Service",
                    icon: "doc.plaintext.fill",
                    color: .green
                ) {
                    showingTermsOfService = true
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
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
    
    private func getUsageProgress() -> Double {
        if let usage = currentUsage {
            let maxCount = paywallManager.isPremiumActive ? 10.0 : 2.0
            let currentCount = paywallManager.isPremiumActive ? Double(usage.generationCount) : Double(usage.lifetimeUsageCount)
            return min(currentCount / maxCount, 1.0)
        }
        return 0.0
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct LegalButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor.systemBlue
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    SettingsView()
}