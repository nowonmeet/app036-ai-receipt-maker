//
//  ReceiptFormViewModel.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

@MainActor
final class ReceiptFormViewModel: ObservableObject {
    @Published var storeName = ""
    @Published var items: [ReceiptItemInput] = []
    @Published var useRandomData = true
    
    private let currencyFormatter = CurrencyFormatter()
    
    var isValid: Bool {
        if useRandomData {
            return true
        }
        
        guard !storeName.isEmpty else { return false }
        guard !items.isEmpty else { return false }
        
        return items.allSatisfy { $0.isValid }
    }
    
    func addItem() {
        let newItem = ReceiptItemInput()
        items.append(newItem)
    }
    
    func removeItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
    }
    
    func clearForm() {
        storeName = ""
        items.removeAll()
        useRandomData = true
    }
    
    func calculateTotal() -> Decimal {
        return items.reduce(Decimal(0)) { total, item in
            total + (Decimal(item.price) * Decimal(item.quantity))
        }
    }
    
    func createReceiptData() -> ReceiptData {
        if useRandomData {
            return createRandomReceiptData()
        } else {
            return createUserReceiptData()
        }
    }
    
    func formatPrice(_ price: Decimal) -> String {
        return currencyFormatter.format(price)
    }
    
    // MARK: - Private Methods
    
    private func createUserReceiptData() -> ReceiptData {
        let receiptData = ReceiptData(
            storeName: storeName.isEmpty ? "Store" : storeName,
            currency: currencyFormatter.currencyCode
        )
        
        receiptData.items = items.map { input in
            ReceiptItem(
                name: input.name.isEmpty ? "Item" : input.name,
                price: Decimal(input.price),
                quantity: input.quantity
            )
        }
        
        receiptData.calculateTotal()
        return receiptData
    }
    
    private func createRandomReceiptData() -> ReceiptData {
        let storeNames = ["Coffee Corner", "Quick Mart", "Fresh Grocers", "Tech Store", "Fashion Outlet"]
        let itemOptions = [
            ("Coffee", 4.99), ("Sandwich", 8.50), ("Water", 2.00), ("Chips", 3.25),
            ("Magazine", 5.99), ("Gum", 1.50), ("Banana", 1.25), ("Milk", 3.89)
        ]
        
        let randomStore = storeNames.randomElement()!
        let numberOfItems = Int.random(in: 1...4)
        let selectedItems = itemOptions.shuffled().prefix(numberOfItems)
        
        let receiptData = ReceiptData(
            storeName: randomStore,
            currency: currencyFormatter.currencyCode
        )
        
        receiptData.items = selectedItems.map { item in
            ReceiptItem(name: item.0, price: Decimal(item.1), quantity: 1)
        }
        
        receiptData.calculateTotal()
        return receiptData
    }
}

// MARK: - Receipt Item Input Model

final class ReceiptItemInput: ObservableObject {
    @Published var name: String = ""
    @Published var price: Double = 0.0
    @Published var quantity: Int = 1
    
    var isValid: Bool {
        return !name.isEmpty && price >= 0 && quantity > 0
    }
}