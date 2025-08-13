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
    @Published var address = ""
    @Published var phoneNumber = ""
    @Published var receiptDate = Date()
    @Published var useCustomDate = false
    @Published var items: [ReceiptItemInput] = []
    @Published var useRandomData = true
    
    private let currencyFormatter = CurrencyFormatter()
    
    var isValid: Bool {
        if useRandomData {
            return true
        }
        
        // 店名のみ必須、他はオプショナル
        guard !storeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { 
            return false 
        }
        
        // アイテムがある場合はバリデーション
        if !items.isEmpty {
            return items.allSatisfy { $0.isValid }
        }
        
        return true // アイテムが空でもOK（AIに委ねる）
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
        address = ""
        phoneNumber = ""
        receiptDate = Date()
        useCustomDate = false
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
        let cleanStoreName = storeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPhoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let receiptData = ReceiptData(
            storeName: cleanStoreName.isEmpty ? "Store" : cleanStoreName,
            address: cleanAddress.isEmpty ? nil : cleanAddress,
            phoneNumber: cleanPhoneNumber.isEmpty ? nil : cleanPhoneNumber,
            receiptDate: useCustomDate ? receiptDate : nil,
            currency: currencyFormatter.currencyCode
        )
        
        // アイテムが入力されている場合のみ設定（空の場合はAIに委ねる）
        if !items.isEmpty {
            receiptData.items = items.map { input in
                ReceiptItem(
                    name: input.name.isEmpty ? "Item" : input.name,
                    price: Decimal(input.price),
                    quantity: input.quantity
                )
            }
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