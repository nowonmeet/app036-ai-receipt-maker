//
//  MockDALLEService.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
@testable import app036_ai_receipt_maker

final class MockDALLEService: DALLEServiceProtocol {
    var shouldSucceed = true
    var mockImageData = "Mock Image Data".data(using: .utf8)!
    
    func generateReceiptImage(prompt: String) async throws -> Data {
        if shouldSucceed {
            return mockImageData
        } else {
            throw AppError.apiError("Mock API Error")
        }
    }
}