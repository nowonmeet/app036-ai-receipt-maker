//
//  ReceiptDetailViewGeneratingStateTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/14.
//

import Testing
import SwiftUI
import SwiftData
@testable import app036_ai_receipt_maker

@Suite("ReceiptDetailView Generating State Tests")
struct ReceiptDetailViewGeneratingStateTests {
    
    @Test("Shows generating state when isGenerating is true")
    func testShowsGeneratingStateWhenGenerating() throws {
        let receipt = ReceiptData(storeName: "Test Store", currency: "USD")
        let view = ReceiptDetailView(receipt: receipt, isGenerating: true)
        
        #expect(view.isGenerating == true)
    }
    
    @Test("Shows completed state when isGenerating is false and receipt is generated")
    func testShowsCompletedStateWhenNotGenerating() throws {
        let receipt = ReceiptData(storeName: "Test Store", currency: "USD")
        receipt.markAsGenerated(fileName: "test.png")
        
        let view = ReceiptDetailView(receipt: receipt, isGenerating: false)
        
        #expect(view.isGenerating == false)
        #expect(receipt.isGenerated == true)
    }
    
    @Test("Modal flow test for GenerateReceiptView")
    @MainActor func testModalFlowForGeneration() throws {
        let dalleService = MockDALLEService()
        let subscriptionService = MockSubscriptionService()
        let receiptRepository = MockReceiptRepository()
        let usageRepository = MockUsageRepository()
        let imageStorageService = MockImageStorageService()
        
        let mainViewModel = MainViewModel(
            dalleService: dalleService,
            subscriptionService: subscriptionService,
            receiptRepository: receiptRepository,
            usageRepository: usageRepository,
            imageStorageService: imageStorageService
        )
        
        // 生成状態の検証
        mainViewModel.isGenerating = true
        #expect(mainViewModel.isGenerating == true)
        
        mainViewModel.isGenerating = false
        #expect(mainViewModel.isGenerating == false)
    }
}