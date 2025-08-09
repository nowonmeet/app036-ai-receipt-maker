//
//  UsageRepositoryProtocol.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

protocol UsageRepositoryProtocol {
    func getTodayUsage() throws -> UsageTracker?
    func incrementUsage(isPremium: Bool) throws
    func resetDailyUsage() throws
}