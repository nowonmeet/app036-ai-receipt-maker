import Foundation
import RevenueCat
import SwiftUI

/// Reading Progress App用のペイウォールデリゲート実装
/// 読書進捗管理アプリ固有のペイウォール処理を管理
final class ReadingProgressPaywallDelegate: PaywallFlowDelegate {
    
    // MARK: - Properties
    
    /// シングルトンインスタンス
    static let shared = ReadingProgressPaywallDelegate()
    
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
        print("📚 Reading Progress: Paywall display starting")
    }
    
    func didShowPaywall() {
        print("📱 Reading Progress: Paywall display completed")
    }
    
    func didCompletePurchase(customerInfo: CustomerInfo) {
        print("========== [ReadingProgressPaywallDelegate] Purchase completion started ==========")
        print("🎉 Reading Progress: Purchase completed")
        print("  - Customer ID: \(customerInfo.originalAppUserId)")
        print("  - Active Subscriptions: \(customerInfo.activeSubscriptions)")
        print("  - Non Subscriptions: \(customerInfo.nonSubscriptions)")
        print("  - Active Entitlements: \(customerInfo.entitlements.active.keys)")
        
        // Log all entitlement details
        for (key, entitlement) in customerInfo.entitlements.all {
            print("  - Entitlement[\(key)]: isActive=\(entitlement.isActive), willRenew=\(entitlement.willRenew)")
        }
        
        // Update premium status for book management
        Task {
            await updateBookLimitServicePremiumStatus(true)
        }
        
        // Show success message
        showSuccessMessage("Premium features are now available!\nEnjoy unlimited book tracking and advanced statistics.")
        
        print("========== [ReadingProgressPaywallDelegate] Purchase completion finished ==========")
    }
    
    func didCompleteRestore(customerInfo: CustomerInfo) {
        print("🔄 Reading Progress: Restore completed")
        print("  - Active Subscriptions: \(customerInfo.activeSubscriptions)")
        print("  - Non Subscriptions: \(customerInfo.nonSubscriptions)")
        
        // Update premium status for book management
        Task {
            await updateBookLimitServicePremiumStatus(true)
        }
        
        // Show restore success message
        showSuccessMessage("Purchase history restored successfully!\nEnjoy unlimited book tracking and advanced statistics.")
    }
    
    func didCancelPaywall() {
        print("❌ Reading Progress: Paywall cancelled")
    }
    
    func didSkipPaywall() {
        print("⏭️ Reading Progress: Paywall skipped")
    }
    
    func didUpdatePremiumStatus(isPremium: Bool, customerInfo: CustomerInfo?) {
        print("🔄 Reading Progress: Premium status updated - isPremium: \(isPremium)")
        
        // Update book management limits
        Task {
            await updateBookLimitServicePremiumStatus(isPremium)
        }
    }
    
    func didEncounterError(_ error: Error) {
        print("❌ Reading Progress: Error occurred - \(error.localizedDescription)")
        
        // Show error message
        showErrorMessage("An error occurred during the purchase process.\nPlease try again later.")
    }
    
    func shouldSendAnalytics(eventName: String, parameters: [String: Any]) {
        // Log analytics events (can be integrated with Firebase/other analytics later)
        print("📊 Reading Progress: Analytics - \(eventName)")
        print("  - Parameters: \(parameters)")
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
    
    /// Update book limit service premium status
    private func updateBookLimitServicePremiumStatus(_ isPremium: Bool) async {
        print("🔄 Reading Progress: Book limit service premium status update started - isPremium: \(isPremium)")
        
        // Send notification about premium status update
        await MainActor.run {
            NotificationCenter.default.post(
                name: .premiumStatusUpdated,
                object: nil,
                userInfo: ["isPremium": isPremium]
            )
        }
        print("📢 Reading Progress: Premium status update notification sent - isPremium: \(isPremium)")
        
        // Update local book management limits
        updateLocalBookLimits(isPremium: isPremium)
    }
    
    /// Update local book management limits
    private func updateLocalBookLimits(isPremium: Bool) {
        // Update book limit in UserDefaults or local storage
        UserDefaults.standard.set(isPremium, forKey: "isPremiumUser")
        
        if isPremium {
            print("📚 Reading Progress: Premium activated - Unlimited books enabled")
            // Remove book count limits
            UserDefaults.standard.set(-1, forKey: "maxBookCount") // -1 for unlimited
        } else {
            print("📚 Reading Progress: Free tier - 10 book limit enforced")
            // Set free tier limit
            UserDefaults.standard.set(10, forKey: "maxBookCount")
        }
        
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let premiumStatusUpdated = Notification.Name("premiumStatusUpdated")
}