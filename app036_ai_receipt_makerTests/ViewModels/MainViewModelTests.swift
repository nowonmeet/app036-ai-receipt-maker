//
//  MainViewModelTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Testing
import Foundation
import SwiftData
@testable import app036_ai_receipt_maker

@MainActor
struct MainViewModelTests {
    
    private func createMockServices() -> (
        dalleService: MockDALLEService,
        subscriptionService: MockSubscriptionService,
        receiptRepository: MockReceiptRepository,
        usageRepository: MockUsageRepository,
        imageStorageService: MockImageStorageService
    ) {
        return (
            dalleService: MockDALLEService(),
            subscriptionService: MockSubscriptionService(),
            receiptRepository: MockReceiptRepository(),
            usageRepository: MockUsageRepository(),
            imageStorageService: MockImageStorageService()
        )
    }
    
    @Test func testInitialState() throws {
        let services = createMockServices()
        let viewModel = MainViewModel(
            dalleService: services.dalleService,
            subscriptionService: services.subscriptionService,
            receiptRepository: services.receiptRepository,
            usageRepository: services.usageRepository,
            imageStorageService: services.imageStorageService
        )
        
        #expect(viewModel.receipts.isEmpty)
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func testLoadReceiptsSuccess() async throws {
        let services = createMockServices()
        let mockReceipts = [
            ReceiptData(storeName: "Test Store 1", currency: "USD"),
            ReceiptData(storeName: "Test Store 2", currency: "EUR")
        ]
        services.receiptRepository.mockReceipts = mockReceipts
        
        let viewModel = MainViewModel(
            dalleService: services.dalleService,
            subscriptionService: services.subscriptionService,
            receiptRepository: services.receiptRepository,
            usageRepository: services.usageRepository,
            imageStorageService: services.imageStorageService
        )
        
        await viewModel.loadReceipts()
        
        #expect(viewModel.receipts.count == 2)
        #expect(viewModel.receipts.first?.storeName == "Test Store 1")
    }
    
    @Test func testGenerateReceiptWithUsageLimitExceeded() async throws {
        let services = createMockServices()
        services.usageRepository.shouldExceedLimit = true
        
        let viewModel = MainViewModel(
            dalleService: services.dalleService,
            subscriptionService: services.subscriptionService,
            receiptRepository: services.receiptRepository,
            usageRepository: services.usageRepository,
            imageStorageService: services.imageStorageService
        )
        
        let receiptData = ReceiptData(storeName: "Test Store", currency: "USD")
        await viewModel.generateReceipt(receiptData: receiptData)
        
        // Paywall is shown through UniversalPaywallManager, not in ViewModel
        #expect(viewModel.isGenerating == false)
    }
    
    @Test func testGenerateReceiptSuccess() async throws {
        let services = createMockServices()
        services.dalleService.shouldSucceed = true
        services.imageStorageService.shouldSucceed = true
        
        let viewModel = MainViewModel(
            dalleService: services.dalleService,
            subscriptionService: services.subscriptionService,
            receiptRepository: services.receiptRepository,
            usageRepository: services.usageRepository,
            imageStorageService: services.imageStorageService
        )
        
        let receiptData = ReceiptData(storeName: "Test Store", currency: "USD")
        await viewModel.generateReceipt(receiptData: receiptData)
        
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.errorMessage == nil)
        #expect(services.receiptRepository.savedReceipts.count == 1)
    }
    
    @Test func testGenerateReceiptFailure() async throws {
        let services = createMockServices()
        services.dalleService.shouldSucceed = false
        
        let viewModel = MainViewModel(
            dalleService: services.dalleService,
            subscriptionService: services.subscriptionService,
            receiptRepository: services.receiptRepository,
            usageRepository: services.usageRepository,
            imageStorageService: services.imageStorageService
        )
        
        let receiptData = ReceiptData(storeName: "Test Store", currency: "USD")
        await viewModel.generateReceipt(receiptData: receiptData)
        
        #expect(viewModel.isGenerating == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test func testDeleteReceipt() async throws {
        let services = createMockServices()
        let receiptToDelete = ReceiptData(storeName: "Delete Me", currency: "USD")
        services.receiptRepository.mockReceipts = [receiptToDelete]
        
        let viewModel = MainViewModel(
            dalleService: services.dalleService,
            subscriptionService: services.subscriptionService,
            receiptRepository: services.receiptRepository,
            usageRepository: services.usageRepository,
            imageStorageService: services.imageStorageService
        )
        
        await viewModel.loadReceipts()
        #expect(viewModel.receipts.count == 1)
        
        await viewModel.deleteReceipt(receiptToDelete)
        
        #expect(viewModel.receipts.count == 0)
    }
    
    @Test func testGenerateRandomReceipt() async throws {
        let services = createMockServices()
        services.dalleService.shouldSucceed = true
        services.imageStorageService.shouldSucceed = true
        
        let viewModel = MainViewModel(
            dalleService: services.dalleService,
            subscriptionService: services.subscriptionService,
            receiptRepository: services.receiptRepository,
            usageRepository: services.usageRepository,
            imageStorageService: services.imageStorageService
        )
        
        await viewModel.generateRandomReceipt()
        
        #expect(viewModel.isGenerating == false)
        #expect(services.receiptRepository.savedReceipts.count == 1)
        #expect(services.receiptRepository.savedReceipts.first?.storeName != nil)
    }
    
    @Test func testCheckUsageLimit() async throws {
        let services = createMockServices()
        let mockUsage = UsageTracker(isPremiumUser: false)
        mockUsage.generationCount = 1
        services.usageRepository.mockUsage = mockUsage
        
        let viewModel = MainViewModel(
            dalleService: services.dalleService,
            subscriptionService: services.subscriptionService,
            receiptRepository: services.receiptRepository,
            usageRepository: services.usageRepository,
            imageStorageService: services.imageStorageService
        )
        
        let canGenerate = await viewModel.checkUsageLimit()
        #expect(canGenerate == true) // 1/2 for free user
        
        mockUsage.generationCount = 2
        let canGenerateAfterLimit = await viewModel.checkUsageLimit()
        #expect(canGenerateAfterLimit == false) // 2/2 for free user
    }
}