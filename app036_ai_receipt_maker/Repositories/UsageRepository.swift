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
        let currentPremiumStatus = UniversalPaywallManager.shared.isPremiumActive
        
        do {
            if currentPremiumStatus {
                // Premium users: use daily tracking
                let today = Calendar.current.startOfDay(for: Date())
                let descriptor = FetchDescriptor<UsageTracker>(
                    predicate: #Predicate { $0.date == today && $0.isPremiumUser == true }
                )
                let results = try modelContext.fetch(descriptor)
                
                if let usage = results.first {
                    print("📊 [UsageRepository] Premium user - Today's usage:")
                    print("  - Daily count: \(usage.generationCount)/10")
                    return usage
                }
            } else {
                // Free users: use lifetime tracking (single record)
                let descriptor = FetchDescriptor<UsageTracker>(
                    predicate: #Predicate { $0.isPremiumUser == false }
                )
                let results = try modelContext.fetch(descriptor)
                
                if let usage = results.first {
                    print("📊 [UsageRepository] Free user - Lifetime usage:")
                    print("  - Lifetime count: \(usage.lifetimeUsageCount)/2")
                    print("  - First used: \(usage.firstUsedDate?.description ?? "N/A")")
                    return usage
                }
            }
            
            return nil
        } catch {
            throw AppError.storageError("Failed to fetch usage: \(error.localizedDescription)")
        }
    }
    
    func incrementUsage(isPremium: Bool) throws {
        do {
            if let existingUsage = try getTodayUsage() {
                existingUsage.incrementCount()
                if isPremium {
                    print("📊 [UsageRepository] Premium user - Updated daily count: \(existingUsage.generationCount)/10")
                } else {
                    print("📊 [UsageRepository] Free user - Updated lifetime count: \(existingUsage.lifetimeUsageCount)/2")
                }
            } else {
                let newUsage = UsageTracker(isPremiumUser: isPremium)
                newUsage.incrementCount()
                modelContext.insert(newUsage)
                
                if isPremium {
                    print("📊 [UsageRepository] Created new premium usage tracker: count=1/10")
                } else {
                    print("📊 [UsageRepository] Created new free usage tracker: lifetime=1/2")
                }
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
        // Only reset for premium users (daily tracking)
        // Free users keep their lifetime count
        let isPremium = UniversalPaywallManager.shared.isPremiumActive
        
        if isPremium {
            do {
                let today = Calendar.current.startOfDay(for: Date())
                let descriptor = FetchDescriptor<UsageTracker>(
                    predicate: #Predicate { $0.date == today && $0.isPremiumUser == true }
                )
                let results = try modelContext.fetch(descriptor)
                
                for usage in results {
                    modelContext.delete(usage)
                }
                
                try modelContext.save()
                print("📊 [UsageRepository] Reset daily usage for premium user")
            } catch {
                if error is AppError {
                    throw error
                } else {
                    throw AppError.storageError("Failed to reset daily usage: \(error.localizedDescription)")
                }
            }
        } else {
            print("📊 [UsageRepository] Free user - lifetime usage not reset")
        }
    }
}