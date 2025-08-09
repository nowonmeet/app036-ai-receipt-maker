//
//  MockUsageRepository.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
@testable import app036_ai_receipt_maker

final class MockUsageRepository: UsageRepositoryProtocol {
    var mockUsage: UsageTracker?
    var shouldExceedLimit = false
    var shouldFailIncrement = false
    var shouldFailReset = false
    
    func getTodayUsage() throws -> UsageTracker? {
        if shouldExceedLimit {
            let usage = UsageTracker(isPremiumUser: false)
            usage.generationCount = 2 // Exceed free limit
            return usage
        }
        return mockUsage
    }
    
    func incrementUsage(isPremium: Bool) throws {
        if shouldFailIncrement {
            throw AppError.storageError("Mock increment error")
        }
        
        if let usage = mockUsage {
            usage.incrementCount()
        } else {
            let newUsage = UsageTracker(isPremiumUser: isPremium)
            newUsage.incrementCount()
            mockUsage = newUsage
        }
    }
    
    func resetDailyUsage() throws {
        if shouldFailReset {
            throw AppError.storageError("Mock reset error")
        }
        mockUsage = nil
    }
}