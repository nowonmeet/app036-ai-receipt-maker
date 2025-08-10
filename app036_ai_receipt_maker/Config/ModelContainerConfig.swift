//
//  ModelContainerConfig.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftData

extension ModelContainer {
    static let shared: ModelContainer = {
        do {
            return try ModelContainer(for: ReceiptData.self, UsageTracker.self)
        } catch {
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }()
}