//
//  ContentView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var mainViewModel: MainViewModel
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var paywallManager = UniversalPaywallManager.shared
    @State private var showOnboarding = true
    
    init() {
        let context = ModelContainer.shared.mainContext
        _mainViewModel = StateObject(wrappedValue: MainViewModel(
            dalleService: DALLEService(),
            subscriptionService: SubscriptionService(),
            receiptRepository: ReceiptRepository(modelContext: context),
            usageRepository: UsageRepository(modelContext: context),
            imageStorageService: ImageStorageService(),
            inAppReviewService: InAppReviewService()
        ))
    }
    
    var body: some View {
        Group {
            if showOnboarding {
                OnboardingContainerView(
                    onboardingManager: onboardingManager,
                    onComplete: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showOnboarding = false
                        }
                    }
                )
            } else {
                MainTabView()
                    .environmentObject(mainViewModel)
            }
        }
        .onAppear {
            showOnboarding = onboardingManager.shouldShowOnboarding
        }
        .onChange(of: onboardingManager.shouldShowOnboarding) { _, newValue in
            if !newValue {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showOnboarding = false
                }
            }
        }
        .onChange(of: onboardingManager.debugOnboardingCompleted) { _, _ in
            if !onboardingManager.shouldShowOnboarding {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showOnboarding = false
                }
            }
        }
        .onChange(of: onboardingManager.shouldShowPaywall) { _, shouldShow in
            #if DEBUG
            print("🎯 [ContentView] shouldShowPaywall changed to: \(shouldShow)")
            #endif
            if shouldShow {
                #if DEBUG
                print("🚀 [ContentView] Starting paywall display with 0.8s delay")
                #endif
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    #if DEBUG
                    print("🎯 [ContentView] Showing paywall now")
                    #endif
                    paywallManager.showPaywall(triggerSource: "onboarding_completed")
                    onboardingManager.markPaywallShown()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
