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
    
    private let userDefaults: UserDefaults
    
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            userDefaults.set(hasCompletedOnboarding, forKey: Self.onboardingKey)
        }
    }
    
    @Published var debugOnboardingCompleted: Bool = false
    
    var shouldShowOnboarding: Bool {
        if APIConfiguration.isDebugOnboardingEnabled {
            return !debugOnboardingCompleted
        }
        return !hasCompletedOnboarding
    }
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.hasCompletedOnboarding = userDefaults.bool(forKey: Self.onboardingKey)
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        if APIConfiguration.isDebugOnboardingEnabled {
            debugOnboardingCompleted = true
        }
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        debugOnboardingCompleted = false
    }
}