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
    @State private var showOnboarding = true
    
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
    }
}

#Preview {
    ContentView()
}
