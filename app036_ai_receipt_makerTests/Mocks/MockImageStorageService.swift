//
//  MockImageStorageService.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
@testable import app036_ai_receipt_maker

final class MockImageStorageService: ImageStorageServiceProtocol {
    var shouldSucceed = true
    var savedImages: [String: Data] = [:]
    
    func saveImage(_ data: Data, fileName: String) throws -> URL {
        if !shouldSucceed {
            throw AppError.storageError("Mock save error")
        }
        
        savedImages[fileName] = data
        return URL(fileURLWithPath: "/mock/path/\(fileName)")
    }
    
    func loadImage(fileName: String) throws -> Data {
        if !shouldSucceed {
            throw AppError.storageError("Mock load error")
        }
        
        guard let data = savedImages[fileName] else {
            throw AppError.storageError("Mock image not found")
        }
        return data
    }
    
    func deleteImage(fileName: String) throws {
        if !shouldSucceed {
            throw AppError.storageError("Mock delete error")
        }
        
        savedImages.removeValue(forKey: fileName)
    }
}