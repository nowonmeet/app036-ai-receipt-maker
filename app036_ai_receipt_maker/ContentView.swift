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
    
    init() {
        let context = ModelContainer.shared.mainContext
        _mainViewModel = StateObject(wrappedValue: MainViewModel(
            dalleService: DALLEService(),
            subscriptionService: SubscriptionService(),
            receiptRepository: ReceiptRepository(modelContext: context),
            usageRepository: UsageRepository(modelContext: context),
            imageStorageService: ImageStorageService()
        ))
    }
    
    var body: some View {
        Group {
            if onboardingManager.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(mainViewModel)
            } else {
                OnboardingContainerView(
                    onboardingManager: onboardingManager,
                    onComplete: {
                        // Completion handled by OnboardingManager
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.5), value: onboardingManager.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
}
