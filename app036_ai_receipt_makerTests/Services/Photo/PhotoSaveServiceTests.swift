//
//  PhotoSaveServiceTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/13.
//

import Testing
import Foundation
import UIKit
@testable import app036_ai_receipt_maker

@MainActor
struct PhotoSaveServiceTests {
    
    private func createMockWatermarkService() -> MockWatermarkService {
        return MockWatermarkService()
    }
    
    private func createTestImageURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let imageURL = tempDir.appendingPathComponent("test_image.png")
        
        // Create a simple test image
        let testImageData = UIImage(systemName: "photo")?.pngData() ?? Data()
        try! testImageData.write(to: imageURL)
        
        return imageURL
    }
    
    @Test func testPhotoSaveServiceInitialization() throws {
        let mockWatermarkService = createMockWatermarkService()
        let photoSaveService = PhotoSaveService(watermarkService: mockWatermarkService)
        
        #expect(photoSaveService != nil)
    }
    
    @Test func testSaveImageForPremiumUser() async throws {
        let mockWatermarkService = createMockWatermarkService()
        let photoSaveService = PhotoSaveService(watermarkService: mockWatermarkService)
        let testImageURL = createTestImageURL()
        
        // Note: This test would require mocking PHPhotoLibrary for full testing
        // For now, we test the logic without actual photo library interaction
        do {
            try await photoSaveService.saveImageToPhotos(imageURL: testImageURL, isPremiumUser: true)
            // If we reach here without error, the logic is working
            // In a real test environment, we would mock PHPhotoLibrary
        } catch {
            // Expected in test environment without photo library access
            #expect(error is AppError)
        }
        
        // Verify watermark service was not called for premium user
        #expect(mockWatermarkService.addWatermarkCallCount == 0)
    }
    
    @Test func testSaveImageForFreeUser() async throws {
        let mockWatermarkService = createMockWatermarkService()
        mockWatermarkService.shouldSucceed = true
        
        let photoSaveService = PhotoSaveService(watermarkService: mockWatermarkService)
        let testImageURL = createTestImageURL()
        
        do {
            try await photoSaveService.saveImageToPhotos(imageURL: testImageURL, isPremiumUser: false)
        } catch {
            // Expected in test environment without photo library access
            #expect(error is AppError)
        }
        
        // Verify watermark service was called for free user
        #expect(mockWatermarkService.addWatermarkCallCount == 1)
        #expect(mockWatermarkService.lastWatermarkText == "AI RECEIPT MAKER")
    }
    
    @Test func testSaveImageWithInvalidURL() async throws {
        let mockWatermarkService = createMockWatermarkService()
        let photoSaveService = PhotoSaveService(watermarkService: mockWatermarkService)
        let invalidURL = URL(fileURLWithPath: "/non/existent/path.png")
        
        await #expect(throws: AppError.self) {
            try await photoSaveService.saveImageToPhotos(imageURL: invalidURL, isPremiumUser: true)
        }
    }
}