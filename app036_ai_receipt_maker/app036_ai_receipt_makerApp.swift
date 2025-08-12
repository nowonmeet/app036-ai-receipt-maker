//
//  app036_ai_receipt_makerApp.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct app036_ai_receipt_makerApp: App {
    let modelContainer: ModelContainer
    
    init() {
        // RevenueCat初期化（最初に実行）
        Purchases.logLevel = .debug  // デバッグモード有効
        Purchases.configure(withAPIKey: "appl_eKuEEsPvpzKyMHFZeVlReOtBoBi")
        print("✅ RevenueCat initialized for AI Receipt Maker")
        
        // ModelContainer初期化
        do {
            modelContainer = try ModelContainer(for: ReceiptData.self, UsageTracker.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
