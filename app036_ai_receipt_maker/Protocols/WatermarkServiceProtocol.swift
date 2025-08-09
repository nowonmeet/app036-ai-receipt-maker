//
//  WatermarkServiceProtocol.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

protocol WatermarkServiceProtocol {
    func addWatermark(to imageData: Data, text: String) throws -> Data
}