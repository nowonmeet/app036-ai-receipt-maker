//
//  CurrencyFormatter.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

final class CurrencyFormatter {
    private let numberFormatter: NumberFormatter
    private let locale: Locale
    
    var currencyCode: String {
        return locale.currency?.identifier ?? "USD"
    }
    
    init(locale: Locale? = nil) {
        if let locale = locale {
            self.locale = locale
        } else {
            self.locale = Locale.current.currency != nil ? Locale.current : Locale(identifier: "en_US")
        }
        
        self.numberFormatter = NumberFormatter()
        self.numberFormatter.numberStyle = .currency
        self.numberFormatter.locale = self.locale
    }
    
    func format(_ amount: Decimal) -> String {
        return numberFormatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}