//
//  ContentView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var mainViewModel: MainViewModel
    
    init() {
        let context = ModelContainer.shared.mainContext
        _mainViewModel = StateObject(wrappedValue: MainViewModel(
            dalleService: DALLEService(),
            subscriptionService: SubscriptionService(),
            receiptRepository: ReceiptRepository(modelContext: context),
            usageRepository: UsageRepository(modelContext: context),
            imageStorageService: ImageStorageService()
        ))
    }
    
    var body: some View {
        MainTabView()
            .environmentObject(mainViewModel)
    }
}

#Preview {
    ContentView()
}
