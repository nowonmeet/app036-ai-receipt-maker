//
//  MainViewModel.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

@MainActor
final class MainViewModel: ObservableObject {
    @Published var receipts: [ReceiptData] = []
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var showPaywall = false
    
    private let dalleService: DALLEServiceProtocol
    private let subscriptionService: SubscriptionServiceProtocol
    private let receiptRepository: ReceiptRepositoryProtocol
    private let usageRepository: UsageRepositoryProtocol
    private let imageStorageService: ImageStorageServiceProtocol
    
    init(
        dalleService: DALLEServiceProtocol,
        subscriptionService: SubscriptionServiceProtocol,
        receiptRepository: ReceiptRepositoryProtocol,
        usageRepository: UsageRepositoryProtocol,
        imageStorageService: ImageStorageServiceProtocol
    ) {
        self.dalleService = dalleService
        self.subscriptionService = subscriptionService
        self.receiptRepository = receiptRepository
        self.usageRepository = usageRepository
        self.imageStorageService = imageStorageService
    }
    
    func loadReceipts() async {
        do {
            let fetchedReceipts = try receiptRepository.fetchAll()
            receipts = fetchedReceipts
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func generateReceipt(receiptData: ReceiptData) async {
        // Check usage limits first
        let canGenerate = await checkUsageLimit()
        guard canGenerate else {
            showPaywall = true
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        do {
            // Generate prompt
            let prompt = generatePrompt(from: receiptData)
            
            // Generate image using DALL-E
            let imageData = try await dalleService.generateReceiptImage(prompt: prompt)
            
            // Save image to storage
            let fileName = generateSecureFileName()
            _ = try imageStorageService.saveImage(imageData, fileName: fileName)
            
            // Update receipt data
            receiptData.markAsGenerated(fileName: fileName)
            
            // Save receipt to repository
            try receiptRepository.save(receiptData)
            
            // Increment usage count
            try usageRepository.incrementUsage(isPremium: subscriptionService.isPremiumUser)
            
            // Reload receipts
            await loadReceipts()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isGenerating = false
    }
    
    func generateRandomReceipt() async {
        let randomReceiptData = createRandomReceiptData()
        await generateReceipt(receiptData: randomReceiptData)
    }
    
    func deleteReceipt(_ receipt: ReceiptData) async {
        do {
            // Delete image file if exists
            if !receipt.imageFileName.isEmpty {
                try? imageStorageService.deleteImage(fileName: receipt.imageFileName)
            }
            
            // Delete from repository
            try receiptRepository.delete(receipt)
            
            // Reload receipts
            await loadReceipts()
            
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func checkUsageLimit() async -> Bool {
        do {
            guard let usage = try usageRepository.getTodayUsage() else {
                return true // No usage today, can generate
            }
            
            return usage.canGenerate()
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func dismissPaywall() {
        showPaywall = false
    }
    
    // MARK: - Private Methods
    
    private func generatePrompt(from receiptData: ReceiptData) -> String {
        if let dalleService = dalleService as? DALLEService {
            return dalleService.generatePrompt(from: receiptData)
        }
        
        // Fallback prompt generation
        let storeName = receiptData.storeName ?? "Store"
        return "Generate a realistic receipt from \(storeName)"
    }
    
    private func createRandomReceiptData() -> ReceiptData {
        let storeNames = ["Coffee Corner", "Quick Mart", "Fresh Grocers", "Tech Store", "Fashion Outlet"]
        let items = [
            ("Coffee", 4.99), ("Sandwich", 8.50), ("Water", 2.00), ("Chips", 3.25),
            ("Magazine", 5.99), ("Gum", 1.50), ("Banana", 1.25), ("Milk", 3.89)
        ]
        
        let randomStore = storeNames.randomElement()!
        let numberOfItems = Int.random(in: 1...4)
        let selectedItems = items.shuffled().prefix(numberOfItems)
        
        let receiptData = ReceiptData(storeName: randomStore, currency: "USD")
        receiptData.items = selectedItems.map { item in
            ReceiptItem(name: item.0, price: Decimal(item.1), quantity: 1)
        }
        receiptData.calculateTotal()
        
        return receiptData
    }
    
    private func generateSecureFileName() -> String {
        return "\(UUID().uuidString).png"
    }
}