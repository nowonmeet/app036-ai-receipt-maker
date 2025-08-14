//
//  OnboardingManager.swift
//  app036_ai_receipt_maker
//
//  Created by AI Assistant on 2025/08/14.
//

import Foundation
import SwiftUI

final class OnboardingManager: ObservableObject {
    static let onboardingKey = "hasCompletedOnboarding"
    static let paywallShownKey = "hasShownOnboardingPaywall"
    
    private let userDefaults: UserDefaults
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            userDefaults.set(hasCompletedOnboarding, forKey: Self.onboardingKey)
        }
    }
    
    @Published var debugOnboardingCompleted: Bool = false
    
    @Published var hasShownPaywall: Bool {
        didSet {
            userDefaults.set(hasShownPaywall, forKey: Self.paywallShownKey)
        }
    }
    
    var shouldShowOnboarding: Bool {
        if APIConfiguration.isDebugOnboardingEnabled {
            return !debugOnboardingCompleted
        }
        return !hasCompletedOnboarding
    }
    
    var shouldShowPaywall: Bool {
        let result: Bool
        
        if APIConfiguration.isDebugOnboardingEnabled {
            // デバッグモードでは debugOnboardingCompleted も考慮
            result = debugOnboardingCompleted && !hasShownPaywall
        } else {
            result = hasCompletedOnboarding && !hasShownPaywall
        }
        
        #if DEBUG
        print("🔍 [OnboardingManager] shouldShowPaywall check:")
        print("  - APIConfiguration.isDebugOnboardingEnabled: \(APIConfiguration.isDebugOnboardingEnabled)")
        print("  - hasCompletedOnboarding: \(hasCompletedOnboarding)")
        print("  - debugOnboardingCompleted: \(debugOnboardingCompleted)")
        print("  - hasShownPaywall: \(hasShownPaywall)")
        print("  - shouldShowPaywall: \(result)")
        #endif
        return result
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.hasCompletedOnboarding = userDefaults.bool(forKey: Self.onboardingKey)
        self.hasShownPaywall = userDefaults.bool(forKey: Self.paywallShownKey)
    }
    
    func completeOnboarding() {
        #if DEBUG
        print("🎯 [OnboardingManager] completeOnboarding called")
        print("  - Before: hasCompletedOnboarding = \(hasCompletedOnboarding)")
        print("  - Before: hasShownPaywall = \(hasShownPaywall)")
        #endif
        
        hasCompletedOnboarding = true
        if APIConfiguration.isDebugOnboardingEnabled {
            debugOnboardingCompleted = true
        }
        
        #if DEBUG
        print("  - After: hasCompletedOnboarding = \(hasCompletedOnboarding)")
        print("  - After: shouldShowPaywall = \(shouldShowPaywall)")
        #endif
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        debugOnboardingCompleted = false
        hasShownPaywall = false
    }
    
    func markPaywallShown() {
        hasShownPaywall = true
    }
}