//
//  MockReceiptRepository.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
@testable import app036_ai_receipt_maker

final class MockReceiptRepository: ReceiptRepositoryProtocol {
    var mockReceipts: [ReceiptData] = []
    var savedReceipts: [ReceiptData] = []
    var shouldFailSave = false
    var shouldFailFetch = false
    var shouldFailDelete = false
    
    func save(_ receipt: ReceiptData) throws {
        if shouldFailSave {
            throw AppError.storageError("Mock save error")
        }
        savedReceipts.append(receipt)
    }
    
    func fetchAll() throws -> [ReceiptData] {
        if shouldFailFetch {
            throw AppError.storageError("Mock fetch error")
        }
        return mockReceipts
    }
    
    func delete(_ receipt: ReceiptData) throws {
        if shouldFailDelete {
            throw AppError.storageError("Mock delete error")
        }
        mockReceipts.removeAll { $0.id == receipt.id }
        savedReceipts.removeAll { $0.id == receipt.id }
    }
}