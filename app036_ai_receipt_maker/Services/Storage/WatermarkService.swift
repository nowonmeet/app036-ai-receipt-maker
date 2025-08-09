//
//  WatermarkService.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
import UIKit
import CoreGraphics

final class WatermarkService: WatermarkServiceProtocol {
    
    func addWatermark(to imageData: Data, text: String) throws -> Data {
        guard !text.isEmpty else {
            return imageData
        }
        
        guard let originalImage = UIImage(data: imageData) else {
            throw AppError.storageError("Invalid image data for watermark")
        }
        
        let watermarkedImage = addWatermarkToImage(originalImage, text: text)
        
        guard let watermarkedData = watermarkedImage.pngData() else {
            throw AppError.storageError("Failed to convert watermarked image to data")
        }
        
        return watermarkedData
    }
    
    private func addWatermarkToImage(_ image: UIImage, text: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        return renderer.image { context in
            // Draw original image
            image.draw(at: .zero)
            
            // Configure watermark text attributes
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: min(image.size.width, image.size.height) * 0.08),
                .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                .strokeColor: UIColor.black.withAlphaComponent(0.8),
                .strokeWidth: -3.0
            ]
            
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedString.size()
            
            // Calculate center position
            let textRect = CGRect(
                x: (image.size.width - textSize.width) / 2,
                y: (image.size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            // Draw watermark text
            attributedString.draw(in: textRect)
        }
    }
}