//
//  InAppReviewService.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/14.
//

import Foundation
import StoreKit

protocol InAppReviewServiceProtocol {
    func requestReviewIfAppropriate()
    func shouldShowReview() -> Bool
    func recordReviewRequest()
    func incrementGenerationCount()
}

final class InAppReviewService: InAppReviewServiceProtocol {
    private let userDefaults: UserDefaults
    private let currentDate: () -> Date
    
    private enum Keys {
        static let generationCount = "review_generation_count"
        static let lastReviewRequestDate = "review_last_request_date"
        static let reviewRequestCount = "review_request_count"
    }
    
    private enum Constants {
        static let firstReviewAtGeneration = 1
        static let secondReviewAtGeneration = 5
        static let thirdReviewAtGeneration = 15
        static let daysBetweenRequests = 30
        static let maxReviewRequests = 3
    }
    
    init(userDefaults: UserDefaults = .standard, currentDate: @escaping () -> Date = Date.init) {
        self.userDefaults = userDefaults
        self.currentDate = currentDate
    }
    
    func requestReviewIfAppropriate() {
        guard shouldShowReview() else { return }
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms delay
            SKStoreReviewController.requestReview()
            recordReviewRequest()
        }
    }
    
    func shouldShowReview() -> Bool {
        let generationCount = userDefaults.integer(forKey: Keys.generationCount)
        let requestCount = userDefaults.integer(forKey: Keys.reviewRequestCount)
        
        // Maximum requests reached
        if requestCount >= Constants.maxReviewRequests {
            return false
        }
        
        // Check if enough time has passed since last request
        if let lastRequestDate = userDefaults.object(forKey: Keys.lastReviewRequestDate) as? Date {
            let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastRequestDate, to: currentDate()).day ?? 0
            if daysSinceLastRequest < Constants.daysBetweenRequests {
                return false
            }
        }
        
        // Check if we've reached a milestone
        return generationCount == Constants.firstReviewAtGeneration ||
               generationCount == Constants.secondReviewAtGeneration ||
               generationCount == Constants.thirdReviewAtGeneration
    }
    
    func recordReviewRequest() {
        let currentRequestCount = userDefaults.integer(forKey: Keys.reviewRequestCount)
        userDefaults.set(currentRequestCount + 1, forKey: Keys.reviewRequestCount)
        userDefaults.set(currentDate(), forKey: Keys.lastReviewRequestDate)
    }
    
    func incrementGenerationCount() {
        let currentCount = userDefaults.integer(forKey: Keys.generationCount)
        userDefaults.set(currentCount + 1, forKey: Keys.generationCount)
    }
}