//
//  AppError.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

enum AppError: LocalizedError {
    case networkError(String)
    case apiError(String)
    case storageError(String)
    case subscriptionError(String)
    case validationError(String)
    case usageLimitExceeded(Int, Bool)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .apiError(let message):
            return "API Error: \(message)"
        case .storageError(let message):
            return "Storage Error: \(message)"
        case .subscriptionError(let message):
            return "Subscription Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .usageLimitExceeded(let count, let isPremium):
            let limit = isPremium ? 10 : 2
            return "Daily limit reached (\(count)/\(limit))"
        }
    }
}