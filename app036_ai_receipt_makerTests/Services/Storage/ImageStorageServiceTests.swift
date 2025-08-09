//
//  ImageStorageServiceTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
@testable import app036_ai_receipt_maker

struct ImageStorageServiceTests {
    
    let testImageData = "Test Image Data".data(using: .utf8)!
    let testFileName = "test_receipt_\(UUID().uuidString).png"
    
    @Test func testSaveImage() throws {
        let service = ImageStorageService()
        
        let url = try service.saveImage(testImageData, fileName: testFileName)
        
        #expect(url.lastPathComponent == testFileName)
        #expect(FileManager.default.fileExists(atPath: url.path))
        
        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }
    
    @Test func testLoadImage() throws {
        let service = ImageStorageService()
        
        // First save an image
        let savedURL = try service.saveImage(testImageData, fileName: testFileName)
        
        // Then load it
        let loadedData = try service.loadImage(fileName: testFileName)
        
        #expect(loadedData == testImageData)
        
        // Cleanup
        try? FileManager.default.removeItem(at: savedURL)
    }
    
    @Test func testDeleteImage() throws {
        let service = ImageStorageService()
        
        // First save an image
        let savedURL = try service.saveImage(testImageData, fileName: testFileName)
        #expect(FileManager.default.fileExists(atPath: savedURL.path))
        
        // Then delete it
        try service.deleteImage(fileName: testFileName)
        
        #expect(!FileManager.default.fileExists(atPath: savedURL.path))
    }
    
    @Test func testLoadNonExistentImage() throws {
        let service = ImageStorageService()
        
        #expect(throws: AppError.self) {
            try service.loadImage(fileName: "nonexistent.png")
        }
    }
    
    @Test func testDeleteNonExistentImage() throws {
        let service = ImageStorageService()
        
        #expect(throws: AppError.self) {
            try service.deleteImage(fileName: "nonexistent.png")
        }
    }
    
    @Test func testSecureFileName() throws {
        let service = ImageStorageService()
        let fileName = service.generateSecureFileName()
        
        #expect(fileName.hasSuffix(".png"))
        #expect(fileName.count > 36) // UUID + ".png"
    }
}