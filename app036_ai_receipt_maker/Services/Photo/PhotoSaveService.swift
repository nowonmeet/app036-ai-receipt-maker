//
//  PhotoSaveService.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/13.
//

import Foundation
import Photos
import UIKit

final class PhotoSaveService: PhotoSaveServiceProtocol {
    private let watermarkService: WatermarkServiceProtocol
    
    init(watermarkService: WatermarkServiceProtocol = WatermarkService()) {
        self.watermarkService = watermarkService
    }
    
    func saveImageToPhotos(imageURL: URL, isPremiumUser: Bool) async throws {
        guard let originalImageData = try? Data(contentsOf: imageURL) else {
            throw AppError.storageError("Failed to load image from URL")
        }
        
        let finalImageData: Data
        
        if isPremiumUser {
            // Premium users get original image without watermark
            finalImageData = originalImageData
            print("📸 [PhotoSaveService] Saving original image for premium user")
        } else {
            // Free users get watermarked image
            finalImageData = try watermarkService.addWatermark(
                to: originalImageData,
                text: "AI RECEIPT MAKER"
            )
            print("📸 [PhotoSaveService] Saving watermarked image for free user")
        }
        
        guard let uiImage = UIImage(data: finalImageData) else {
            throw AppError.storageError("Failed to create UIImage from data")
        }
        
        let hasPermission = await requestPhotoLibraryPermission()
        guard hasPermission else {
            throw AppError.storageError("Photo library access denied")
        }
        
        try await saveUIImageToPhotos(uiImage)
    }
    
    func requestPhotoLibraryPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized, .limited:
                    continuation.resume(returning: true)
                case .denied, .restricted, .notDetermined:
                    continuation.resume(returning: false)
                @unknown default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    private func saveUIImageToPhotos(_ image: UIImage) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    print("📸 [PhotoSaveService] Successfully saved image to Photos")
                    continuation.resume()
                } else {
                    let saveError = error ?? AppError.storageError("Failed to save image to Photos")
                    print("❌ [PhotoSaveService] Failed to save image: \(saveError.localizedDescription)")
                    continuation.resume(throwing: saveError)
                }
            }
        }
    }
}