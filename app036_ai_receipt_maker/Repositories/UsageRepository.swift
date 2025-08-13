//
//  UsageRepository.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
import SwiftData

final class UsageRepository: UsageRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getTodayUsage() throws -> UsageTracker? {
        let today = Calendar.current.startOfDay(for: Date())
        
        do {
            let descriptor = FetchDescriptor<UsageTracker>(
                predicate: #Predicate { $0.date == today }
            )
            let results = try modelContext.fetch(descriptor)
            
            // 取得時に常に最新のプレミアム状態に更新
            if let usage = results.first {
                let currentPremiumStatus = UniversalPaywallManager.shared.isPremiumActive
                
                print("📊 [UsageRepository] getTodayUsage:")
                print("  - Stored isPremiumUser: \(usage.isPremiumUser)")
                print("  - Current premium status: \(currentPremiumStatus)")
                print("  - Daily limit before: \(usage.dailyLimit)")
                
                if usage.isPremiumUser != currentPremiumStatus {
                    print("  ⚠️ Premium status mismatch detected, updating...")
                    usage.isPremiumUser = currentPremiumStatus
                    try modelContext.save()
                    print("  ✅ Updated isPremiumUser to: \(currentPremiumStatus)")
                    print("  - Daily limit after: \(usage.dailyLimit)")
                }
            }
            
            return results.first
        } catch {
            throw AppError.storageError("Failed to fetch today's usage: \(error.localizedDescription)")
        }
    }
    
    func incrementUsage(isPremium: Bool) throws {
        do {
            if let existingUsage = try getTodayUsage() {
                existingUsage.incrementCount()
                existingUsage.isPremiumUser = isPremium // Update premium status
                print("📊 [UsageRepository] Updated existing usage: count=\(existingUsage.generationCount), isPremium=\(isPremium)")
            } else {
                let newUsage = UsageTracker(isPremiumUser: isPremium)
                newUsage.incrementCount()
                modelContext.insert(newUsage)
                print("📊 [UsageRepository] Created new usage: count=1, isPremium=\(isPremium)")
            }
            
            try modelContext.save()
        } catch {
            if error is AppError {
                throw error
            } else {
                throw AppError.storageError("Failed to increment usage: \(error.localizedDescription)")
            }
        }
    }
    
    func resetDailyUsage() throws {
        do {
            if let todayUsage = try getTodayUsage() {
                modelContext.delete(todayUsage)
                try modelContext.save()
            }
        } catch {
            if error is AppError {
                throw error
            } else {
                throw AppError.storageError("Failed to reset daily usage: \(error.localizedDescription)")
            }
        }
    }
}