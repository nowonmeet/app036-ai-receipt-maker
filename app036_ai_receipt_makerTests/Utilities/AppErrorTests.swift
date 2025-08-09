//
//  AppErrorTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
@testable import app036_ai_receipt_maker

struct AppErrorTests {
    
    @Test func testNetworkErrorDescription() throws {
        let error = AppError.networkError("Connection failed")
        #expect(error.errorDescription == "Network Error: Connection failed")
    }
    
    @Test func testAPIErrorDescription() throws {
        let error = AppError.apiError("Invalid response")
        #expect(error.errorDescription == "API Error: Invalid response")
    }
    
    @Test func testStorageErrorDescription() throws {
        let error = AppError.storageError("Failed to save")
        #expect(error.errorDescription == "Storage Error: Failed to save")
    }
    
    @Test func testSubscriptionErrorDescription() throws {
        let error = AppError.subscriptionError("Not subscribed")
        #expect(error.errorDescription == "Subscription Error: Not subscribed")
    }
    
    @Test func testValidationErrorDescription() throws {
        let error = AppError.validationError("Invalid input")
        #expect(error.errorDescription == "Validation Error: Invalid input")
    }
    
    @Test func testUsageLimitExceededForFreeUser() throws {
        let error = AppError.usageLimitExceeded(2, false)
        #expect(error.errorDescription == "Daily limit reached (2/2)")
    }
    
    @Test func testUsageLimitExceededForPremiumUser() throws {
        let error = AppError.usageLimitExceeded(10, true)
        #expect(error.errorDescription == "Daily limit reached (10/10)")
    }
}