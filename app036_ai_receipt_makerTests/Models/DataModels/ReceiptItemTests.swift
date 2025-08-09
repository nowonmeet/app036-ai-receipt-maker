//
//  ReceiptItemTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
@testable import app036_ai_receipt_maker

struct ReceiptItemTests {
    
    @Test func testReceiptItemInitialization() throws {
        let item = ReceiptItem(
            name: "Coffee",
            price: Decimal(4.99),
            quantity: 2
        )
        
        #expect(item.name == "Coffee")
        #expect(item.price == Decimal(4.99))
        #expect(item.quantity == 2)
    }
    
    @Test func testReceiptItemCalculateTotalPrice() throws {
        let item = ReceiptItem(
            name: "Sandwich",
            price: Decimal(8.50),
            quantity: 3
        )
        
        #expect(item.totalPrice == Decimal(25.50))
    }
    
    @Test func testReceiptItemWithZeroQuantity() throws {
        let item = ReceiptItem(
            name: "Water",
            price: Decimal(2.00),
            quantity: 0
        )
        
        #expect(item.totalPrice == Decimal(0))
    }
    
    @Test func testReceiptItemValidation() throws {
        let validItem = ReceiptItem(
            name: "Valid Item",
            price: Decimal(10.00),
            quantity: 1
        )
        
        #expect(validItem.isValid == true)
        
        let invalidItem1 = ReceiptItem(
            name: "",
            price: Decimal(10.00),
            quantity: 1
        )
        
        #expect(invalidItem1.isValid == false)
        
        let invalidItem2 = ReceiptItem(
            name: "Item",
            price: Decimal(-5.00),
            quantity: 1
        )
        
        #expect(invalidItem2.isValid == false)
        
        let invalidItem3 = ReceiptItem(
            name: "Item",
            price: Decimal(10.00),
            quantity: -1
        )
        
        #expect(invalidItem3.isValid == false)
    }
}