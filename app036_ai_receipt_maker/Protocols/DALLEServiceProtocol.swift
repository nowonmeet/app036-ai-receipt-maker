//
//  DALLEServiceProtocol.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

protocol DALLEServiceProtocol {
    func generateReceiptImage(prompt: String) async throws -> Data
}