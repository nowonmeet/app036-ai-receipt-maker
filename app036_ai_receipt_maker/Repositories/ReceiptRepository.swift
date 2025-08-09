//
//  ReceiptRepository.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
import SwiftData

final class ReceiptRepository: ReceiptRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func save(_ receipt: ReceiptData) throws {
        do {
            modelContext.insert(receipt)
            try modelContext.save()
        } catch {
            throw AppError.storageError("Failed to save receipt: \(error.localizedDescription)")
        }
    }
    
    func fetchAll() throws -> [ReceiptData] {
        do {
            let descriptor = FetchDescriptor<ReceiptData>(
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            return try modelContext.fetch(descriptor)
        } catch {
            throw AppError.storageError("Failed to fetch receipts: \(error.localizedDescription)")
        }
    }
    
    func delete(_ receipt: ReceiptData) throws {
        do {
            modelContext.delete(receipt)
            try modelContext.save()
        } catch {
            throw AppError.storageError("Failed to delete receipt: \(error.localizedDescription)")
        }
    }
}