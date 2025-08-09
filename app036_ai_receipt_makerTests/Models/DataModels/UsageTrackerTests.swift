//
//  UsageTrackerTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
@testable import app036_ai_receipt_maker

struct UsageTrackerTests {
    
    @Test func testUsageTrackerInitialization() throws {
        let tracker = UsageTracker(isPremiumUser: false)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        #expect(calendar.startOfDay(for: tracker.date) == today)
        #expect(tracker.generationCount == 0)
        #expect(tracker.isPremiumUser == false)
    }
    
    @Test func testUsageTrackerForPremiumUser() throws {
        let tracker = UsageTracker(isPremiumUser: true)
        
        #expect(tracker.isPremiumUser == true)
        #expect(tracker.generationCount == 0)
    }
    
    @Test func testIncrementGenerationCount() throws {
        let tracker = UsageTracker(isPremiumUser: false)
        
        tracker.incrementCount()
        #expect(tracker.generationCount == 1)
        
        tracker.incrementCount()
        #expect(tracker.generationCount == 2)
    }
    
    @Test func testCanGenerateForFreeUser() throws {
        let tracker = UsageTracker(isPremiumUser: false)
        
        #expect(tracker.canGenerate() == true)
        
        tracker.generationCount = 1
        #expect(tracker.canGenerate() == true)
        
        tracker.generationCount = 2
        #expect(tracker.canGenerate() == false)
        
        tracker.generationCount = 3
        #expect(tracker.canGenerate() == false)
    }
    
    @Test func testCanGenerateForPremiumUser() throws {
        let tracker = UsageTracker(isPremiumUser: true)
        
        #expect(tracker.canGenerate() == true)
        
        tracker.generationCount = 5
        #expect(tracker.canGenerate() == true)
        
        tracker.generationCount = 9
        #expect(tracker.canGenerate() == true)
        
        tracker.generationCount = 10
        #expect(tracker.canGenerate() == false)
        
        tracker.generationCount = 11
        #expect(tracker.canGenerate() == false)
    }
    
    @Test func testRemainingGenerations() throws {
        let freeTracker = UsageTracker(isPremiumUser: false)
        #expect(freeTracker.remainingGenerations == 2)
        
        freeTracker.generationCount = 1
        #expect(freeTracker.remainingGenerations == 1)
        
        freeTracker.generationCount = 2
        #expect(freeTracker.remainingGenerations == 0)
        
        let premiumTracker = UsageTracker(isPremiumUser: true)
        #expect(premiumTracker.remainingGenerations == 10)
        
        premiumTracker.generationCount = 7
        #expect(premiumTracker.remainingGenerations == 3)
        
        premiumTracker.generationCount = 10
        #expect(premiumTracker.remainingGenerations == 0)
    }
    
    @Test func testDailyLimit() throws {
        let freeTracker = UsageTracker(isPremiumUser: false)
        #expect(freeTracker.dailyLimit == 2)
        
        let premiumTracker = UsageTracker(isPremiumUser: true)
        #expect(premiumTracker.dailyLimit == 10)
    }
}