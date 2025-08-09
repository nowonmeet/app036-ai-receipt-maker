//
//  MockSubscriptionService.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
@testable import app036_ai_receipt_maker

final class MockSubscriptionService: SubscriptionServiceProtocol {
    var isPremiumUser: Bool = false
    var shouldFailStatusCheck = false
    var shouldFailPaywall = false
    
    func checkSubscriptionStatus() async throws -> Bool {
        if shouldFailStatusCheck {
            throw AppError.subscriptionError("Mock subscription error")
        }
        return isPremiumUser
    }
    
    func presentPaywall() async throws {
        if shouldFailPaywall {
            throw AppError.subscriptionError("Mock paywall error")
        }
    }
}