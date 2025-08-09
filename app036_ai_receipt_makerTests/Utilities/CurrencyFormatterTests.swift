//
//  CurrencyFormatterTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
@testable import app036_ai_receipt_maker

struct CurrencyFormatterTests {
    
    @Test func testFormatUSDCurrency() throws {
        let formatter = CurrencyFormatter(locale: Locale(identifier: "en_US"))
        
        let result1 = formatter.format(Decimal(12.99))
        #expect(result1 == "$12.99")
        
        let result2 = formatter.format(Decimal(1000))
        #expect(result2 == "$1,000.00")
        
        let result3 = formatter.format(Decimal(0))
        #expect(result3 == "$0.00")
    }
    
    @Test func testFormatEURCurrency() throws {
        let formatter = CurrencyFormatter(locale: Locale(identifier: "de_DE"))
        
        let result1 = formatter.format(Decimal(12.99))
        #expect(result1 == "12,99 €")
        
        let result2 = formatter.format(Decimal(1000))
        #expect(result2 == "1.000,00 €")
    }
    
    @Test func testFormatJPYCurrency() throws {
        let formatter = CurrencyFormatter(locale: Locale(identifier: "ja_JP"))
        
        let result1 = formatter.format(Decimal(1299))
        #expect(result1 == "¥1,299")
        
        let result2 = formatter.format(Decimal(10000))
        #expect(result2 == "¥10,000")
    }
    
    @Test func testFormatGBPCurrency() throws {
        let formatter = CurrencyFormatter(locale: Locale(identifier: "en_GB"))
        
        let result = formatter.format(Decimal(15.50))
        #expect(result == "£15.50")
    }
    
    @Test func testFormatCADCurrency() throws {
        let formatter = CurrencyFormatter(locale: Locale(identifier: "en_CA"))
        
        let result = formatter.format(Decimal(25.75))
        #expect(result == "$25.75")
    }
    
    @Test func testCurrentLocaleFormatter() throws {
        let formatter = CurrencyFormatter()
        
        let result = formatter.format(Decimal(100))
        #expect(result != nil)
        #expect(!result.isEmpty)
    }
    
    @Test func testFormatNegativeAmount() throws {
        let formatter = CurrencyFormatter(locale: Locale(identifier: "en_US"))
        
        let result = formatter.format(Decimal(-50.00))
        #expect(result == "-$50.00")
    }
    
    @Test func testGetCurrencyCode() throws {
        let formatterUS = CurrencyFormatter(locale: Locale(identifier: "en_US"))
        #expect(formatterUS.currencyCode == "USD")
        
        let formatterEU = CurrencyFormatter(locale: Locale(identifier: "de_DE"))
        #expect(formatterEU.currencyCode == "EUR")
        
        let formatterJP = CurrencyFormatter(locale: Locale(identifier: "ja_JP"))
        #expect(formatterJP.currencyCode == "JPY")
    }
    
    @Test func testDefaultToUSDWhenUnknown() throws {
        let formatter = CurrencyFormatter(locale: nil)
        #expect(formatter.currencyCode == "USD")
        
        let result = formatter.format(Decimal(10.50))
        #expect(result == "$10.50")
    }
}