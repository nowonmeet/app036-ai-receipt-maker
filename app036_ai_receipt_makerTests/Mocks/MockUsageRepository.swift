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
        
        // モックでもプレミアム状態を同期（本番コードの動作を再現）
        if let usage = mockUsage {
            // UniversalPaywallManagerの状態を反映
            // テスト環境では通常falseなので、テスト時は明示的に設定する
            print("📊 [MockUsageRepository] getTodayUsage:")
            print("  - Stored isPremiumUser: \(usage.isPremiumUser)")
            print("  - Daily limit: \(usage.dailyLimit)")
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