//
//  ReceiptItem.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
import SwiftData

@Model
final class ReceiptItem {
    var name: String
    var price: Decimal
    var quantity: Int
    
    var totalPrice: Decimal {
        return price * Decimal(quantity)
    }
    
    var isValid: Bool {
        return !name.isEmpty && price >= 0 && quantity >= 0
    }
    
    init(name: String, price: Decimal, quantity: Int) {
        self.name = name
        self.price = price
        self.quantity = quantity
    }
}