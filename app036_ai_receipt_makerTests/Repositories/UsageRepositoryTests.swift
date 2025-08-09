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
        #expect(todayUsage?.generationCount == 1)
        #expect(todayUsage?.isPremiumUser == false)
    }
    
    @Test func testIncrementUsageUpdatesExistingRecord() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        try repository.incrementUsage(isPremium: false)
        try repository.incrementUsage(isPremium: false)
        
        let todayUsage = try repository.getTodayUsage()
        #expect(todayUsage?.generationCount == 2)
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
        
        // Create usage record
        try repository.incrementUsage(isPremium: false)
        try repository.incrementUsage(isPremium: false)
        
        var todayUsage = try repository.getTodayUsage()
        #expect(todayUsage?.generationCount == 2)
        
        // Reset usage
        try repository.resetDailyUsage()
        
        todayUsage = try repository.getTodayUsage()
        #expect(todayUsage == nil)
    }
    
    @Test func testGetTodayUsageIgnoresOldRecords() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        // Create old usage tracker
        let oldTracker = UsageTracker(isPremiumUser: false)
        oldTracker.date = Calendar.current.startOfDay(for: Date().addingTimeInterval(-86400)) // Yesterday
        oldTracker.generationCount = 5
        
        container.mainContext.insert(oldTracker)
        try container.mainContext.save()
        
        // Should not find today's usage
        let todayUsage = try repository.getTodayUsage()
        #expect(todayUsage == nil)
        
        // Create today's usage
        try repository.incrementUsage(isPremium: true)
        
        let newTodayUsage = try repository.getTodayUsage()
        #expect(newTodayUsage?.generationCount == 1)
        #expect(newTodayUsage?.isPremiumUser == true)
    }
    
    @Test func testCanGenerateBasedOnUsage() throws {
        let container = createInMemoryModelContainer()
        let repository = UsageRepository(modelContext: container.mainContext)
        
        // Free user - should be able to generate 2 times
        try repository.incrementUsage(isPremium: false)
        var todayUsage = try repository.getTodayUsage()
        #expect(todayUsage?.canGenerate() == true)
        
        try repository.incrementUsage(isPremium: false)
        todayUsage = try repository.getTodayUsage()
        #expect(todayUsage?.canGenerate() == false) // Reached limit
        
        // Reset and test premium user
        try repository.resetDailyUsage()
        
        // Premium user - should be able to generate 10 times
        for i in 1...9 {
            try repository.incrementUsage(isPremium: true)
            todayUsage = try repository.getTodayUsage()
            #expect(todayUsage?.canGenerate() == true)
        }
        
        try repository.incrementUsage(isPremium: true)
        todayUsage = try repository.getTodayUsage()
        #expect(todayUsage?.canGenerate() == false) // Reached premium limit
    }
}