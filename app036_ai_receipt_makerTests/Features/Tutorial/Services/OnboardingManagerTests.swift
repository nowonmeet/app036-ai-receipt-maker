//
//  OnboardingManagerTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by AI Assistant on 2025/08/14.
//

import Testing
import Foundation
@testable import app036_ai_receipt_maker

struct OnboardingManagerTests {
    
    @Test("OnboardingManager initial state - hasCompletedOnboarding is false")
    func testInitialState() {
        let manager = OnboardingManager(userDefaults: UserDefaults(suiteName: "test")!)
        #expect(manager.hasCompletedOnboarding == false)
    }
    
    @Test("OnboardingManager completeOnboarding sets flag to true")
    func testCompleteOnboarding() {
        let userDefaults = UserDefaults(suiteName: "test")!
        let manager = OnboardingManager(userDefaults: userDefaults)
        
        manager.completeOnboarding()
        
        #expect(manager.hasCompletedOnboarding == true)
        #expect(userDefaults.bool(forKey: OnboardingManager.onboardingKey) == true)
    }
    
    @Test("OnboardingManager resetOnboarding sets flag to false")
    func testResetOnboarding() {
        let userDefaults = UserDefaults(suiteName: "test")!
        let manager = OnboardingManager(userDefaults: userDefaults)
        
        manager.completeOnboarding()
        #expect(manager.hasCompletedOnboarding == true)
        
        manager.resetOnboarding()
        #expect(manager.hasCompletedOnboarding == false)
        #expect(userDefaults.bool(forKey: OnboardingManager.onboardingKey) == false)
    }
    
    @Test("OnboardingManager persists state across instances")
    func testPersistence() {
        let userDefaults = UserDefaults(suiteName: "test")!
        
        let manager1 = OnboardingManager(userDefaults: userDefaults)
        manager1.completeOnboarding()
        
        let manager2 = OnboardingManager(userDefaults: userDefaults)
        #expect(manager2.hasCompletedOnboarding == true)
    }
    
    @Test("OnboardingManager shouldShowOnboarding behavior")
    func testShouldShowOnboarding() {
        let userDefaults = UserDefaults(suiteName: "test_debug")!
        let manager = OnboardingManager(userDefaults: userDefaults)
        
        // Debug mode: should show onboarding until debugOnboardingCompleted is true
        if APIConfiguration.isDebugOnboardingEnabled {
            #expect(manager.shouldShowOnboarding == true)
            #expect(manager.debugOnboardingCompleted == false)
            
            manager.completeOnboarding()
            #expect(manager.shouldShowOnboarding == false)
            #expect(manager.debugOnboardingCompleted == true)
        } else {
            // Production mode: show only if not completed
            #expect(manager.shouldShowOnboarding == true)
            
            manager.completeOnboarding()
            #expect(manager.shouldShowOnboarding == false)
        }
    }
    
    @Test("OnboardingManager resetOnboarding resets debug state")
    func testResetOnboardingResetsDebugState() {
        let userDefaults = UserDefaults(suiteName: "test_debug_reset")!
        let manager = OnboardingManager(userDefaults: userDefaults)
        
        manager.completeOnboarding()
        #expect(manager.hasCompletedOnboarding == true)
        
        if APIConfiguration.isDebugOnboardingEnabled {
            #expect(manager.debugOnboardingCompleted == true)
        }
        
        manager.resetOnboarding()
        #expect(manager.hasCompletedOnboarding == false)
        #expect(manager.debugOnboardingCompleted == false)
        #expect(manager.shouldShowOnboarding == true)
    }
    
    @Test("OnboardingManager shouldShowPaywall property")
    func testShouldShowPaywall() {
        let userDefaults = UserDefaults(suiteName: "test_paywall")!
        let manager = OnboardingManager(userDefaults: userDefaults)
        
        // 初期状態：オンボーディング未完了なのでペイウォールは表示しない
        #expect(manager.shouldShowPaywall == false)
        
        // オンボーディング完了後：ペイウォールを表示する
        manager.completeOnboarding()
        
        // デバッグモードかどうかで動作が異なる
        if APIConfiguration.isDebugOnboardingEnabled {
            // デバッグモード：debugOnboardingCompleted が true になるのでペイウォール表示
            #expect(manager.shouldShowPaywall == true)
        } else {
            // プロダクションモード：hasCompletedOnboarding が true になるのでペイウォール表示
            #expect(manager.shouldShowPaywall == true)
        }
        
        // ペイウォール表示済みフラグをセット：表示しない
        manager.markPaywallShown()
        #expect(manager.shouldShowPaywall == false)
        
        // リセット：初期状態に戻る
        manager.resetOnboarding()
        #expect(manager.shouldShowPaywall == false)
    }
    
    @Test("OnboardingManager markPaywallShown persistence")
    func testMarkPaywallShownPersistence() {
        let userDefaults = UserDefaults(suiteName: "test_paywall_persistence")!
        
        let manager1 = OnboardingManager(userDefaults: userDefaults)
        manager1.completeOnboarding()
        manager1.markPaywallShown()
        
        let manager2 = OnboardingManager(userDefaults: userDefaults)
        #expect(manager2.shouldShowPaywall == false)
    }
}