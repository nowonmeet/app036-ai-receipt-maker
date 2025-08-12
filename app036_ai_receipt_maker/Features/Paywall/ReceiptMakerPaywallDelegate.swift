import Foundation
import RevenueCat
import SwiftUI

/// AI Receipt Maker用のペイウォールデリゲート実装
/// レシート作成アプリ固有のペイウォール処理を管理
final class ReceiptMakerPaywallDelegate: PaywallFlowDelegate {
    
    // MARK: - Properties
    
    /// シングルトンインスタンス
    static let shared = ReceiptMakerPaywallDelegate()
    
    /// 成功メッセージ表示用のバインディング
    @Published var showSuccessAlert = false
    @Published var successMessage = ""
    
    /// エラーメッセージ表示用のバインディング
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    
    /// 初期化
    private init() {}
    
    // MARK: - PaywallFlowDelegate Implementation
    
    func willShowPaywall() {
        print("📄 AI Receipt Maker: Paywall display starting")
    }
    
    func didShowPaywall() {
        print("📱 AI Receipt Maker: Paywall display completed")
    }
    
    func didCompletePurchase(customerInfo: CustomerInfo) {
        print("========== [ReceiptMakerPaywallDelegate] Purchase completion started ==========")
        print("🎉 AI Receipt Maker: Purchase completed")
        print("  - Customer ID: \(customerInfo.originalAppUserId)")
        print("  - Active Subscriptions: \(customerInfo.activeSubscriptions)")
        print("  - Non Subscriptions: \(customerInfo.nonSubscriptions)")
        print("  - Active Entitlements: \(customerInfo.entitlements.active.keys)")
        
        // Log all entitlement details
        for (key, entitlement) in customerInfo.entitlements.all {
            print("  - Entitlement[\(key)]: isActive=\(entitlement.isActive), willRenew=\(entitlement.willRenew)")
        }
        
        // Update premium status for receipt features
        Task {
            await updateReceiptFeaturePremiumStatus(true)
        }
        
        // Show success message
        showSuccessMessage("Premium features are now available!\nEnjoy unlimited receipt generation and advanced features.")
        
        print("========== [ReceiptMakerPaywallDelegate] Purchase completion finished ==========")
    }
    
    func didCompleteRestore(customerInfo: CustomerInfo) {
        print("🔄 AI Receipt Maker: Restore completed")
        print("  - Active Subscriptions: \(customerInfo.activeSubscriptions)")
        print("  - Non Subscriptions: \(customerInfo.nonSubscriptions)")
        
        // Update premium status for receipt features
        Task {
            await updateReceiptFeaturePremiumStatus(true)
        }
        
        // Show restore success message
        showSuccessMessage("Purchase history restored successfully!\nEnjoy unlimited receipt generation and advanced features.")
    }
    
    func didCancelPaywall() {
        print("❌ AI Receipt Maker: Paywall cancelled")
    }
    
    func didSkipPaywall() {
        print("⏭️ AI Receipt Maker: Paywall skipped")
    }
    
    func didUpdatePremiumStatus(isPremium: Bool, customerInfo: CustomerInfo?) {
        print("🔄 AI Receipt Maker: Premium status updated - isPremium: \(isPremium)")
        
        // Update receipt generation limits
        Task {
            await updateReceiptFeaturePremiumStatus(isPremium)
        }
    }
    
    func didEncounterError(_ error: Error) {
        print("❌ AI Receipt Maker: Error occurred - \(error.localizedDescription)")
        
        // Show error message
        showErrorMessage("An error occurred during the purchase process.\nPlease try again later.")
    }
    
    
    // MARK: - Private Methods
    
    /// Show success message
    private func showSuccessMessage(_ message: String) {
        DispatchQueue.main.async {
            self.successMessage = message
            self.showSuccessAlert = true
            print("✅ Success: \(message)")
        }
    }
    
    /// Show error message
    private func showErrorMessage(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showErrorAlert = true
            print("❌ Error: \(message)")
        }
    }
    
    /// Update receipt feature premium status
    private func updateReceiptFeaturePremiumStatus(_ isPremium: Bool) async {
        print("🔄 AI Receipt Maker: Receipt feature premium status update started - isPremium: \(isPremium)")
        
        // Send notification about premium status update
        await MainActor.run {
            NotificationCenter.default.post(
                name: .receiptMakerPremiumStatusUpdated,
                object: nil,
                userInfo: ["isPremium": isPremium]
            )
        }
        print("📢 AI Receipt Maker: Premium status update notification sent - isPremium: \(isPremium)")
        
        // Update local receipt generation limits
        updateLocalReceiptLimits(isPremium: isPremium)
    }
    
    /// Update local receipt generation limits
    private func updateLocalReceiptLimits(isPremium: Bool) {
        // Update receipt limit in UserDefaults or local storage
        UserDefaults.standard.set(isPremium, forKey: "isPremiumUser")
        
        if isPremium {
            print("📄 AI Receipt Maker: Premium activated - Unlimited receipt generation enabled")
            // Remove receipt count limits
            UserDefaults.standard.set(-1, forKey: "maxReceiptCount") // -1 for unlimited
        } else {
            print("📄 AI Receipt Maker: Free tier - Limited receipt generation enforced")
            // Set free tier limit (e.g., 5 receipts per month)
            UserDefaults.standard.set(5, forKey: "maxReceiptCount")
        }
        
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let receiptMakerPremiumStatusUpdated = Notification.Name("receiptMakerPremiumStatusUpdated")
}