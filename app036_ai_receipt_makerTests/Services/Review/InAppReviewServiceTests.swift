//
//  InAppReviewServiceTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/14.
//

import Testing
import Foundation
@testable import app036_ai_receipt_maker

final class MockUserDefaults: UserDefaults {
    private var storage: [String: Any] = [:]
    
    override func integer(forKey defaultName: String) -> Int {
        return storage[defaultName] as? Int ?? 0
    }
    
    override func object(forKey defaultName: String) -> Any? {
        return storage[defaultName]
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        storage[defaultName] = value
    }
}

struct InAppReviewServiceTests {
    
    @Test func shouldShowReview_firstGeneration_returnsTrue() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(1, forKey: "review_generation_count")
        
        let service = InAppReviewService(userDefaults: mockUserDefaults)
        
        #expect(service.shouldShowReview() == true)
    }
    
    @Test func shouldShowReview_fifthGeneration_returnsTrue() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(5, forKey: "review_generation_count")
        
        let service = InAppReviewService(userDefaults: mockUserDefaults)
        
        #expect(service.shouldShowReview() == true)
    }
    
    @Test func shouldShowReview_fifteenthGeneration_returnsTrue() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(15, forKey: "review_generation_count")
        
        let service = InAppReviewService(userDefaults: mockUserDefaults)
        
        #expect(service.shouldShowReview() == true)
    }
    
    @Test func shouldShowReview_secondGeneration_returnsFalse() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(2, forKey: "review_generation_count")
        
        let service = InAppReviewService(userDefaults: mockUserDefaults)
        
        #expect(service.shouldShowReview() == false)
    }
    
    @Test func shouldShowReview_maxRequestsReached_returnsFalse() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(1, forKey: "review_generation_count")
        mockUserDefaults.set(3, forKey: "review_request_count") // max reached
        
        let service = InAppReviewService(userDefaults: mockUserDefaults)
        
        #expect(service.shouldShowReview() == false)
    }
    
    @Test func shouldShowReview_recentRequest_returnsFalse() {
        let mockUserDefaults = MockUserDefaults()
        let currentDate = Date()
        let recentDate = Calendar.current.date(byAdding: .day, value: -10, to: currentDate)! // 10 days ago
        
        mockUserDefaults.set(5, forKey: "review_generation_count")
        mockUserDefaults.set(recentDate, forKey: "review_last_request_date")
        
        let service = InAppReviewService(
            userDefaults: mockUserDefaults,
            currentDate: { currentDate }
        )
        
        #expect(service.shouldShowReview() == false)
    }
    
    @Test func shouldShowReview_oldRequest_returnsTrue() {
        let mockUserDefaults = MockUserDefaults()
        let currentDate = Date()
        let oldDate = Calendar.current.date(byAdding: .day, value: -40, to: currentDate)! // 40 days ago
        
        mockUserDefaults.set(5, forKey: "review_generation_count")
        mockUserDefaults.set(oldDate, forKey: "review_last_request_date")
        
        let service = InAppReviewService(
            userDefaults: mockUserDefaults,
            currentDate: { currentDate }
        )
        
        #expect(service.shouldShowReview() == true)
    }
    
    @Test func recordReviewRequest_incrementsCountAndSetsDate() {
        let mockUserDefaults = MockUserDefaults()
        let testDate = Date()
        
        let service = InAppReviewService(
            userDefaults: mockUserDefaults,
            currentDate: { testDate }
        )
        
        service.recordReviewRequest()
        
        #expect(mockUserDefaults.integer(forKey: "review_request_count") == 1)
        
        let savedDate = mockUserDefaults.object(forKey: "review_last_request_date") as? Date
        #expect(savedDate == testDate)
    }
    
    @Test func incrementGenerationCount_incrementsValue() {
        let mockUserDefaults = MockUserDefaults()
        mockUserDefaults.set(3, forKey: "review_generation_count")
        
        let service = InAppReviewService(userDefaults: mockUserDefaults)
        service.incrementGenerationCount()
        
        #expect(mockUserDefaults.integer(forKey: "review_generation_count") == 4)
    }
}