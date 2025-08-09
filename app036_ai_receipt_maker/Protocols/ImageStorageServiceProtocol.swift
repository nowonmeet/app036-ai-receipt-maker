//
//  ImageStorageServiceProtocol.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

protocol ImageStorageServiceProtocol {
    func saveImage(_ data: Data, fileName: String) throws -> URL
    func loadImage(fileName: String) throws -> Data
    func deleteImage(fileName: String) throws
}