//
//  ReceiptFormViewModelTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
@testable import app036_ai_receipt_maker

@MainActor
struct ReceiptFormViewModelTests {
    
    @Test func testInitialState() throws {
        let viewModel = ReceiptFormViewModel()
        
        #expect(viewModel.storeName.isEmpty)
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.useRandomData == true)
        #expect(viewModel.isValid == false)
    }
    
    @Test func testAddItem() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.addItem()
        
        #expect(viewModel.items.count == 1)
        #expect(viewModel.items.first?.name.isEmpty == true)
        #expect(viewModel.items.first?.price == 0)
        #expect(viewModel.items.first?.quantity == 1)
    }
    
    @Test func testRemoveItem() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.addItem()
        viewModel.addItem()
        #expect(viewModel.items.count == 2)
        
        viewModel.removeItem(at: 0)
        #expect(viewModel.items.count == 1)
    }
    
    @Test func testValidationWithValidData() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.storeName = "Test Store"
        viewModel.useRandomData = false
        viewModel.addItem()
        viewModel.items[0].name = "Coffee"
        viewModel.items[0].price = 4.99
        viewModel.items[0].quantity = 1
        
        #expect(viewModel.isValid == true)
    }
    
    @Test func testValidationWithInvalidData() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.storeName = "" // Empty store name
        viewModel.useRandomData = false
        viewModel.addItem()
        viewModel.items[0].name = "Coffee"
        viewModel.items[0].price = 4.99
        
        #expect(viewModel.isValid == false)
    }
    
    @Test func testValidationWithRandomData() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.useRandomData = true
        
        #expect(viewModel.isValid == true) // Random data is always valid
    }
    
    @Test func testCreateReceiptDataWithUserData() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.storeName = "Coffee Shop"
        viewModel.useRandomData = false
        viewModel.addItem()
        viewModel.items[0].name = "Latte"
        viewModel.items[0].price = 5.50
        viewModel.items[0].quantity = 2
        
        let receiptData = viewModel.createReceiptData()
        
        #expect(receiptData.storeName == "Coffee Shop")
        #expect(receiptData.items.count == 1)
        #expect(receiptData.items.first?.name == "Latte")
        #expect(receiptData.items.first?.price == Decimal(5.50))
        #expect(receiptData.items.first?.quantity == 2)
        #expect(receiptData.totalAmount == Decimal(11.00))
    }
    
    @Test func testCreateReceiptDataWithRandomData() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.useRandomData = true
        
        let receiptData1 = viewModel.createReceiptData()
        let receiptData2 = viewModel.createReceiptData()
        
        #expect(receiptData1.storeName != nil)
        #expect(receiptData1.items.count > 0)
        #expect(receiptData1.storeName != receiptData2.storeName) // Should be different
    }
    
    @Test func testClearForm() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.storeName = "Test Store"
        viewModel.addItem()
        viewModel.items[0].name = "Test Item"
        viewModel.useRandomData = false
        
        viewModel.clearForm()
        
        #expect(viewModel.storeName.isEmpty)
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.useRandomData == true)
    }
    
    @Test func testCalculateTotal() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.addItem()
        viewModel.items[0].price = 10.00
        viewModel.items[0].quantity = 2
        
        viewModel.addItem()
        viewModel.items[1].price = 5.50
        viewModel.items[1].quantity = 1
        
        let total = viewModel.calculateTotal()
        #expect(total == Decimal(25.50))
    }
    
    @Test func testCalculateTotalWithEmptyItems() throws {
        let viewModel = ReceiptFormViewModel()
        
        let total = viewModel.calculateTotal()
        #expect(total == Decimal(0))
    }
    
    @Test func testItemValidation() throws {
        let viewModel = ReceiptFormViewModel()
        
        viewModel.addItem()
        
        // Invalid item (empty name)
        viewModel.items[0].name = ""
        viewModel.items[0].price = 5.00
        viewModel.items[0].quantity = 1
        
        #expect(viewModel.items[0].isValid == false)
        
        // Valid item
        viewModel.items[0].name = "Valid Item"
        #expect(viewModel.items[0].isValid == true)
    }
    
    @Test func testFormattedPrice() throws {
        let viewModel = ReceiptFormViewModel()
        
        let formatted1 = viewModel.formatPrice(Decimal(12.99))
        #expect(!formatted1.isEmpty)
        
        let formatted2 = viewModel.formatPrice(Decimal(0))
        #expect(!formatted2.isEmpty)
    }
}