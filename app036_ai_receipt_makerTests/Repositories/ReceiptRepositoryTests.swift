//
//  ReceiptRepositoryTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
import SwiftData
@testable import app036_ai_receipt_maker

struct ReceiptRepositoryTests {
    
    private func createInMemoryModelContainer() -> ModelContainer {
        let schema = Schema([ReceiptData.self, ReceiptItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try! ModelContainer(for: schema, configurations: [configuration])
    }
    
    @Test func testSaveReceipt() throws {
        let container = createInMemoryModelContainer()
        let repository = ReceiptRepository(modelContext: container.mainContext)
        
        let receiptData = ReceiptData(storeName: "Test Store", currency: "USD")
        receiptData.items = [
            ReceiptItem(name: "Coffee", price: Decimal(4.99), quantity: 1)
        ]
        receiptData.calculateTotal()
        
        try repository.save(receiptData)
        
        let savedReceipts = try repository.fetchAll()
        #expect(savedReceipts.count == 1)
        #expect(savedReceipts.first?.storeName == "Test Store")
        #expect(savedReceipts.first?.totalAmount == Decimal(4.99))
    }
    
    @Test func testFetchAllReceipts() throws {
        let container = createInMemoryModelContainer()
        let repository = ReceiptRepository(modelContext: container.mainContext)
        
        // Save multiple receipts
        let receipt1 = ReceiptData(storeName: "Store 1", currency: "USD")
        let receipt2 = ReceiptData(storeName: "Store 2", currency: "EUR")
        
        try repository.save(receipt1)
        try repository.save(receipt2)
        
        let allReceipts = try repository.fetchAll()
        #expect(allReceipts.count == 2)
        
        let storeNames = allReceipts.compactMap { $0.storeName }
        #expect(storeNames.contains("Store 1"))
        #expect(storeNames.contains("Store 2"))
    }
    
    @Test func testDeleteReceipt() throws {
        let container = createInMemoryModelContainer()
        let repository = ReceiptRepository(modelContext: container.mainContext)
        
        let receiptData = ReceiptData(storeName: "Delete Test", currency: "JPY")
        try repository.save(receiptData)
        
        var allReceipts = try repository.fetchAll()
        #expect(allReceipts.count == 1)
        
        try repository.delete(receiptData)
        
        allReceipts = try repository.fetchAll()
        #expect(allReceipts.count == 0)
    }
    
    @Test func testFetchReceiptsByDateOrder() throws {
        let container = createInMemoryModelContainer()
        let repository = ReceiptRepository(modelContext: container.mainContext)
        
        let oldReceipt = ReceiptData(storeName: "Old Store", currency: "USD")
        let newReceipt = ReceiptData(storeName: "New Store", currency: "USD")
        
        // Manually set creation dates
        oldReceipt.createdAt = Date().addingTimeInterval(-3600) // 1 hour ago
        newReceipt.createdAt = Date() // now
        
        try repository.save(oldReceipt)
        try repository.save(newReceipt)
        
        let allReceipts = try repository.fetchAll()
        #expect(allReceipts.count == 2)
        
        // Should be ordered by creation date (newest first)
        #expect(allReceipts.first?.storeName == "New Store")
        #expect(allReceipts.last?.storeName == "Old Store")
    }
    
    @Test func testSaveReceiptWithItems() throws {
        let container = createInMemoryModelContainer()
        let repository = ReceiptRepository(modelContext: container.mainContext)
        
        let receiptData = ReceiptData(storeName: "Grocery Store", currency: "USD")
        receiptData.items = [
            ReceiptItem(name: "Apple", price: Decimal(2.50), quantity: 3),
            ReceiptItem(name: "Bread", price: Decimal(3.00), quantity: 1)
        ]
        receiptData.calculateTotal()
        
        try repository.save(receiptData)
        
        let savedReceipts = try repository.fetchAll()
        let savedReceipt = savedReceipts.first!
        
        #expect(savedReceipt.items.count == 2)
        #expect(savedReceipt.totalAmount == Decimal(10.50))
    }
}