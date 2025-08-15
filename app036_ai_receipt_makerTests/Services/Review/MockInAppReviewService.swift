//
//  MockInAppReviewService.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/14.
//

import Foundation
@testable import app036_ai_receipt_maker

final class MockInAppReviewService: InAppReviewServiceProtocol {
    var shouldShowReviewReturnValue = false
    var requestReviewCallCount = 0
    var recordReviewRequestCallCount = 0
    var incrementGenerationCallCount = 0
    
    func requestReviewIfAppropriate() {
        requestReviewCallCount += 1
    }
    
    func shouldShowReview() -> Bool {
        return shouldShowReviewReturnValue
    }
    
    func recordReviewRequest() {
        recordReviewRequestCallCount += 1
    }
    
    func incrementGenerationCount() {
        incrementGenerationCallCount += 1
    }
}