//
//  UsageTracker.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
import SwiftData

@Model
final class UsageTracker {
    var date: Date
    var generationCount: Int
    var isPremiumUser: Bool
    var lifetimeUsageCount: Int = 0
    var firstUsedDate: Date?
    
    var dailyLimit: Int {
        return isPremiumUser ? 10 : 2
    }
    
    var remainingGenerations: Int {
        if isPremiumUser {
            let remaining = 10 - generationCount
            return max(0, remaining)
        } else {
            let remaining = 2 - lifetimeUsageCount
            return max(0, remaining)
        }
    }
    
    init(isPremiumUser: Bool) {
        let calendar = Calendar.current
        self.date = calendar.startOfDay(for: Date())
        self.generationCount = 0
        self.isPremiumUser = isPremiumUser
        self.lifetimeUsageCount = 0
        self.firstUsedDate = nil
    }
    
    func canGenerate() -> Bool {
        if isPremiumUser {
            return generationCount < 10
        } else {
            return lifetimeUsageCount < 2
        }
    }
    
    func incrementCount() {
        generationCount += 1
        
        if !isPremiumUser {
            lifetimeUsageCount += 1
            if firstUsedDate == nil {
                firstUsedDate = Date()
            }
        }
    }
}