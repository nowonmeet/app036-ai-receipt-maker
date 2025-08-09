//
//  WatermarkServiceTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
import UIKit
@testable import app036_ai_receipt_maker

struct WatermarkServiceTests {
    
    private func createTestImageData() -> Data {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData()!
    }
    
    @Test func testAddWatermark() throws {
        let service = WatermarkService()
        let testImageData = createTestImageData()
        
        let watermarkedData = try service.addWatermark(
            to: testImageData,
            text: "AI RECEIPT MAKER"
        )
        
        #expect(watermarkedData != testImageData)
        #expect(watermarkedData.count > 0)
        
        // Verify it's still a valid image
        let watermarkedImage = UIImage(data: watermarkedData)
        #expect(watermarkedImage != nil)
    }
    
    @Test func testAddWatermarkWithEmptyText() throws {
        let service = WatermarkService()
        let testImageData = createTestImageData()
        
        let watermarkedData = try service.addWatermark(
            to: testImageData,
            text: ""
        )
        
        #expect(watermarkedData == testImageData)
    }
    
    @Test func testAddWatermarkToInvalidImage() throws {
        let service = WatermarkService()
        let invalidImageData = "not an image".data(using: .utf8)!
        
        #expect(throws: AppError.self) {
            try service.addWatermark(to: invalidImageData, text: "TEST")
        }
    }
    
    @Test func testAddWatermarkWithCustomText() throws {
        let service = WatermarkService()
        let testImageData = createTestImageData()
        
        let watermarkedData = try service.addWatermark(
            to: testImageData,
            text: "CUSTOM WATERMARK"
        )
        
        #expect(watermarkedData != testImageData)
        #expect(watermarkedData.count > 0)
    }
    
    @Test func testAddWatermarkPreservesImageSize() throws {
        let service = WatermarkService()
        let testImageData = createTestImageData()
        let originalImage = UIImage(data: testImageData)!
        
        let watermarkedData = try service.addWatermark(
            to: testImageData,
            text: "WATERMARK"
        )
        
        let watermarkedImage = UIImage(data: watermarkedData)!
        
        #expect(watermarkedImage.size.width == originalImage.size.width)
        #expect(watermarkedImage.size.height == originalImage.size.height)
    }
}