//
//  UsageRepositoryTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
import SwiftData
@testable import app036_ai_receipt_maker

@MainActor
struct UsageRepositoryTests {
    
    private func createInMemoryModelContainer() -> ModelContainer {
        let schema = Schema([UsageTracker.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }
    
    @Test func testGetTodayUsageWhenNoRecord() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        let todayUsage = try repository.getTodayUsage()
        #expect(todayUsage == nil)
    }
    
    @Test func testIncrementUsageCreatesNewRecord() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        try repository.incrementUsage(isPremium: false)
        
        let todayUsage = try repository.getTodayUsage()
        #expect(todayUsage != nil)
        #expect(todayUsage?.lifetimeUsageCount == 1)
        #expect(todayUsage?.isPremiumUser == false)
    }
    
    @Test func testIncrementUsageUpdatesExistingRecord() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        try repository.incrementUsage(isPremium: false)
        try repository.incrementUsage(isPremium: false)
        
        let todayUsage = try repository.getTodayUsage()
        #expect(todayUsage?.lifetimeUsageCount == 2)
        #expect(todayUsage?.firstUsedDate != nil)
    }
    
    @Test func testIncrementUsageForPremiumUser() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        try repository.incrementUsage(isPremium: true)
        
        let todayUsage = try repository.getTodayUsage()
        #expect(todayUsage?.generationCount == 1)
        #expect(todayUsage?.isPremiumUser == true)
    }
    
    @Test func testResetDailyUsage() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        // Free user - usage should not be reset
        try repository.incrementUsage(isPremium: false)
        try repository.incrementUsage(isPremium: false)
        
        var freeUsage = try repository.getTodayUsage()
        #expect(freeUsage?.lifetimeUsageCount == 2)
        
        // Reset usage (should not affect free user)
        try repository.resetDailyUsage()
        
        freeUsage = try repository.getTodayUsage()
        #expect(freeUsage?.lifetimeUsageCount == 2) // Still 2 for free user
    }
    
    @Test func testFreeUserLifetimeTracking() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        // Create free user usage
        try repository.incrementUsage(isPremium: false)
        
        // Should retrieve same record regardless of date
        let usage1 = try repository.getTodayUsage()
        #expect(usage1?.lifetimeUsageCount == 1)
        
        // Increment again (should update same record)
        try repository.incrementUsage(isPremium: false)
        
        let usage2 = try repository.getTodayUsage()
        #expect(usage2?.lifetimeUsageCount == 2)
        #expect(usage2?.canGenerate() == false) // Reached lifetime limit
    }
    
    @Test func testCanGenerateBasedOnUsage() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        // Free user - should be able to generate 2 times (lifetime)
        try repository.incrementUsage(isPremium: false)
        var freeUsage = try repository.getTodayUsage()
        #expect(freeUsage?.canGenerate() == true)
        
        try repository.incrementUsage(isPremium: false)
        freeUsage = try repository.getTodayUsage()
        #expect(freeUsage?.canGenerate() == false) // Reached lifetime limit
    }
    
    @Test func testPremiumUserDailyLimit() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        // Premium user - should be able to generate 10 times per day
        for i in 1...9 {
            try repository.incrementUsage(isPremium: true)
            let usage = try repository.getTodayUsage()
            #expect(usage?.canGenerate() == true)
        }
        
        try repository.incrementUsage(isPremium: true)
        let finalUsage = try repository.getTodayUsage()
        #expect(finalUsage?.canGenerate() == false) // Reached daily limit
    }
}