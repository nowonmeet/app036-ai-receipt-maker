//
//  SubscriptionServiceProtocol.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

protocol SubscriptionServiceProtocol {
    var isPremiumUser: Bool { get }
    func checkSubscriptionStatus() async throws -> Bool
    func presentPaywall() async throws
}