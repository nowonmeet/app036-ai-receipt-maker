//
//  SubscriptionService.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

final class SubscriptionService: SubscriptionServiceProtocol {
    
    var isPremiumUser: Bool {
        // UniversalPaywallManagerの課金状態を直接参照
        let isPremium = UniversalPaywallManager.shared.isPremiumActive
        
        // デバッグログ
        print("🔍 [SubscriptionService] isPremiumUser check:")
        print("  - UniversalPaywallManager.isPremiumActive: \(isPremium)")
        
        return isPremium
    }
    
    init() {
        // Initialize subscription service
        // UniversalPaywallManagerはapp036_ai_receipt_makerApp.swiftで初期化済み
        print("✅ [SubscriptionService] Initialized as proxy to UniversalPaywallManager")
    }
    
    func checkSubscriptionStatus() async throws -> Bool {
        // UniversalPaywallManagerの状態をチェック
        await MainActor.run {
            UniversalPaywallManager.shared.checkSubscriptionStatus()
        }
        
        // 少し待機して状態更新を待つ
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        let status = UniversalPaywallManager.shared.isPremiumActive
        print("🔍 [SubscriptionService] checkSubscriptionStatus: \(status)")
        
        return status
    }
    
    func presentPaywall() async throws {
        // UniversalPaywallManagerのペイウォールを表示
        await MainActor.run {
            UniversalPaywallManager.shared.showPaywall(triggerSource: "manual_presentation")
        }
        
        // ペイウォール表示の完了を待つ
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        print("✅ [SubscriptionService] Paywall presented via UniversalPaywallManager")
    }
    
    // MARK: - Additional Methods for Testing and State Management
    
    func updateSubscriptionStatus(isPremium: Bool) {
        // テスト用：UniversalPaywallManagerのデバッグメソッドを使用
        #if DEBUG
        if isPremium {
            UniversalPaywallManager.shared.setPremiumForDebug()
        } else {
            UniversalPaywallManager.shared.resetToFreeUserForDebug()
        }
        print("🔧 [SubscriptionService] Debug update: isPremium = \(isPremium)")
        #endif
    }
    
    func handleSubscriptionExpiration() {
        // UniversalPaywallManagerをフリーユーザーにリセット
        #if DEBUG
        UniversalPaywallManager.shared.resetToFreeUserForDebug()
        print("🔧 [SubscriptionService] Debug: Subscription expired")
        #endif
    }
    
    func validatePurchase(transactionId: String) async -> Bool {
        guard !transactionId.isEmpty else {
            return false
        }
        
        // UniversalPaywallManagerの状態を確認
        let isPremium = UniversalPaywallManager.shared.isPremiumActive
        print("🔍 [SubscriptionService] validatePurchase: transactionId=\(transactionId), isPremium=\(isPremium)")
        
        return isPremium
    }
    
    func restorePurchases() async -> Bool {
        // UniversalPaywallManagerを通じてリストア
        await MainActor.run {
            UniversalPaywallManager.shared.checkSubscriptionStatus()
        }
        
        // リストア処理の完了を待つ
        try? await Task.sleep(nanoseconds: 250_000_000) // 0.25 seconds
        
        let restored = UniversalPaywallManager.shared.isPremiumActive
        print("🔍 [SubscriptionService] restorePurchases: restored=\(restored)")
        
        return restored
    }
}