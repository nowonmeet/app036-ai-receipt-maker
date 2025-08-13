//
//  PhotoSaveServiceProtocol.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/13.
//

import Foundation

protocol PhotoSaveServiceProtocol {
    func saveImageToPhotos(imageURL: URL, isPremiumUser: Bool) async throws
    func requestPhotoLibraryPermission() async -> Bool
}