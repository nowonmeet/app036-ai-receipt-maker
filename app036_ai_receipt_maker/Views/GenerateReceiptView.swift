//
//  GenerateReceiptView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData

struct GenerateReceiptView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var mainViewModel: MainViewModel
    @StateObject private var formViewModel = ReceiptFormViewModel()
    @State private var showingError = false
    @State private var isPremium = UniversalPaywallManager.shared.isPremiumActive
    @State private var showingReceiptDetail = false
    @State private var currentReceiptForDetail: ReceiptData?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Usage status display
                UsageStatusView(isPremium: isPremium)
                    .padding(.horizontal)
                
                if formViewModel.useRandomData {
                    VStack(spacing: 16) {
                        Text("Generate Random Receipt")
                            .font(.headline)
                        
                        Text("Create a receipt with random store and items")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Generate Random Receipt") {
                            Task {
                                await generateRandomReceiptWithModal()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    ReceiptFormView(
                        viewModel: formViewModel,
                        onGenerate: { receiptData in
                            Task {
                                await generateReceiptWithModal(receiptData: receiptData)
                            }
                        }
                    )
                }
                
                Toggle("Use Random Data", isOn: $formViewModel.useRandomData)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Generate")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(mainViewModel.isGenerating)
            .alert("Error", isPresented: $showingError) {
                Button("OK") {
                    mainViewModel.clearError()
                }
            } message: {
                Text(mainViewModel.errorMessage ?? "An error occurred")
            }
            .onReceive(mainViewModel.$errorMessage) { errorMessage in
                showingError = errorMessage != nil
            }
            .onAppear {
                isPremium = UniversalPaywallManager.shared.isPremiumActive
            }
            .sheet(isPresented: $showingReceiptDetail) {
                if let receipt = currentReceiptForDetail {
                    ReceiptDetailView(
                        receipt: receipt,
                        isGenerating: mainViewModel.isGenerating
                    )
                }
            }
        }
    }
    
    private func generateRandomReceiptWithModal() async {
        let randomReceiptData = createRandomReceiptData()
        await generateReceiptWithModal(receiptData: randomReceiptData)
    }
    
    private func generateReceiptWithModal(receiptData: ReceiptData) async {
        // モーダルを即座に表示
        currentReceiptForDetail = receiptData
        showingReceiptDetail = true
        
        // レシート生成を開始
        await mainViewModel.generateReceipt(receiptData: receiptData)
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
}

#Preview {
    GenerateReceiptView()
        .modelContainer(for: [ReceiptData.self, UsageTracker.self])
}