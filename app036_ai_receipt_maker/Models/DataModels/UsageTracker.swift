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
    
    var dailyLimit: Int {
        return isPremiumUser ? 10 : 2
    }
    
    var remainingGenerations: Int {
        let remaining = dailyLimit - generationCount
        return max(0, remaining)
    }
    
    init(isPremiumUser: Bool) {
        let calendar = Calendar.current
        self.date = calendar.startOfDay(for: Date())
        self.generationCount = 0
        self.isPremiumUser = isPremiumUser
    }
    
    func canGenerate() -> Bool {
        return generationCount < dailyLimit
    }
    
    func incrementCount() {
        generationCount += 1
    }
}