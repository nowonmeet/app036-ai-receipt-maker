//
//  MockWatermarkService.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/13.
//

import Foundation
@testable import app036_ai_receipt_maker

final class MockWatermarkService: WatermarkServiceProtocol {
    var shouldSucceed = true
    var addWatermarkCallCount = 0
    var lastImageData: Data?
    var lastWatermarkText: String?
    var mockWatermarkedData = "watermarked_image_data".data(using: .utf8)!
    
    func addWatermark(to imageData: Data, text: String) throws -> Data {
        addWatermarkCallCount += 1
        lastImageData = imageData
        lastWatermarkText = text
        
        if shouldSucceed {
            return mockWatermarkedData
        } else {
            throw AppError.storageError("Mock watermark error")
        }
    }
    
    func reset() {
        shouldSucceed = true
        addWatermarkCallCount = 0
        lastImageData = nil
        lastWatermarkText = nil
    }
}