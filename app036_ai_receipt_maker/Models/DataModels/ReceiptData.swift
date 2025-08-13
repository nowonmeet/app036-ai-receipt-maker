//
//  ReceiptData.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation
import SwiftData

@Model
final class ReceiptData {
    var id: UUID
    var storeName: String?
    var address: String?
    var phoneNumber: String?
    var items: [ReceiptItem]
    var totalAmount: Decimal?
    var currency: String
    var imageFileName: String
    var createdAt: Date
    var isGenerated: Bool
    
    var isValid: Bool {
        guard let storeName = storeName, !storeName.isEmpty else { return false }
        guard !currency.isEmpty else { return false }
        return true
    }
    
    init(storeName: String? = nil, address: String? = nil, phoneNumber: String? = nil, currency: String = "USD") {
        self.id = UUID()
        self.storeName = storeName
        self.address = address
        self.phoneNumber = phoneNumber
        self.items = []
        self.totalAmount = nil
        self.currency = currency
        self.imageFileName = ""
        self.createdAt = Date()
        self.isGenerated = false
    }
    
    func calculateTotal() {
        if items.isEmpty {
            totalAmount = Decimal(0)
        } else {
            totalAmount = items.reduce(Decimal(0)) { $0 + $1.totalPrice }
        }
    }
    
    func markAsGenerated(fileName: String) {
        self.isGenerated = true
        self.imageFileName = fileName
    }
}