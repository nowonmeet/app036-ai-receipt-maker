//
//  ImageStorageService.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

final class ImageStorageService: ImageStorageServiceProtocol {
    private let documentsDirectory: URL
    
    init() {
        self.documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
    }
    
    func saveImage(_ data: Data, fileName: String) throws -> URL {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            throw AppError.storageError("Failed to save image: \(error.localizedDescription)")
        }
    }
    
    func loadImage(fileName: String) throws -> Data {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw AppError.storageError("Image file not found: \(fileName)")
        }
        
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            throw AppError.storageError("Failed to load image: \(error.localizedDescription)")
        }
    }
    
    func deleteImage(fileName: String) throws {
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw AppError.storageError("Image file not found: \(fileName)")
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            throw AppError.storageError("Failed to delete image: \(error.localizedDescription)")
        }
    }
    
    func generateSecureFileName() -> String {
        return "\(UUID().uuidString).png"
    }
}