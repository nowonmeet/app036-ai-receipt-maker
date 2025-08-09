//
//  ReceiptDataTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
@testable import app036_ai_receipt_maker

struct ReceiptDataTests {
    
    @Test func testReceiptDataInitialization() throws {
        let receiptData = ReceiptData(
            storeName: "Coffee Shop",
            currency: "USD"
        )
        
        #expect(receiptData.id != nil)
        #expect(receiptData.storeName == "Coffee Shop")
        #expect(receiptData.items.isEmpty)
        #expect(receiptData.totalAmount == nil)
        #expect(receiptData.currency == "USD")
        #expect(receiptData.imageFileName == "")
        #expect(receiptData.isGenerated == false)
    }
    
    @Test func testReceiptDataWithItems() throws {
        let receiptData = ReceiptData(
            storeName: "Grocery Store",
            currency: "USD"
        )
        
        let item1 = ReceiptItem(name: "Apple", price: Decimal(2.50), quantity: 3)
        let item2 = ReceiptItem(name: "Bread", price: Decimal(3.00), quantity: 2)
        
        receiptData.items = [item1, item2]
        receiptData.calculateTotal()
        
        #expect(receiptData.items.count == 2)
        #expect(receiptData.totalAmount == Decimal(13.50))
    }
    
    @Test func testReceiptDataValidation() throws {
        let validReceipt = ReceiptData(
            storeName: "Valid Store",
            currency: "USD"
        )
        validReceipt.items = [
            ReceiptItem(name: "Item1", price: Decimal(10.00), quantity: 1)
        ]
        
        #expect(validReceipt.isValid == true)
        
        let invalidReceipt1 = ReceiptData(
            storeName: "",
            currency: "USD"
        )
        
        #expect(invalidReceipt1.isValid == false)
        
        let invalidReceipt2 = ReceiptData(
            storeName: "Store",
            currency: ""
        )
        
        #expect(invalidReceipt2.isValid == false)
    }
    
    @Test func testReceiptDataGeneratedFlag() throws {
        let receiptData = ReceiptData(
            storeName: "Test Store",
            currency: "JPY"
        )
        
        #expect(receiptData.isGenerated == false)
        
        receiptData.markAsGenerated(fileName: "receipt_123.png")
        
        #expect(receiptData.isGenerated == true)
        #expect(receiptData.imageFileName == "receipt_123.png")
    }
    
    @Test func testReceiptDataEmptyItemsTotal() throws {
        let receiptData = ReceiptData(
            storeName: "Empty Store",
            currency: "EUR"
        )
        
        receiptData.calculateTotal()
        
        #expect(receiptData.totalAmount == Decimal(0))
    }
}