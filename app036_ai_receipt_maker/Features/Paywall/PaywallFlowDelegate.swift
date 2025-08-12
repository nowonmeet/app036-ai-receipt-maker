import Foundation
import RevenueCat

// MARK: - PaywallFlowDelegate

/// ペイウォールの表示フローをアプリ側でハンドリングするためのデリゲート
/// すべてのメソッドはオプショナルにしたいので、デフォルト実装を extension で提供する
public protocol PaywallFlowDelegate: AnyObject {
    /// ペイウォール表示直前
    func willShowPaywall()
    /// ペイウォールが画面に表示された
    func didShowPaywall()
    /// 購入完了
    func didCompletePurchase(customerInfo: CustomerInfo)
    /// リストア完了
    func didCompleteRestore(customerInfo: CustomerInfo)
    /// ユーザーが閉じる/キャンセルをタップして閉じた
    func didCancelPaywall()
    /// スキップボタンでスキップ
    func didSkipPaywall()
    /// プレミアム状態が変化した（サーバーからのプッシュ等）
    func didUpdatePremiumStatus(isPremium: Bool, customerInfo: CustomerInfo?)
    /// エラー発生
    func didEncounterError(_ error: Error)
}

// デフォルト実装を空で提供
public extension PaywallFlowDelegate {
    func willShowPaywall() {}
    func didShowPaywall() {}
    func didCompletePurchase(customerInfo: CustomerInfo) {}
    func didCompleteRestore(customerInfo: CustomerInfo) {}
    func didCancelPaywall() {}
    func didSkipPaywall() {}
    func didUpdatePremiumStatus(isPremium: Bool, customerInfo: CustomerInfo?) {}
    func didEncounterError(_ error: Error) {}
}

// MARK: - PaywallEvent

/// UniversalPaywallManager 内部で使用するアナリティクスイベント定義
enum PaywallEvent {
    case willShow
    case didShow
    case skipped
    case cancelled
    case purchaseStarted
    case purchaseCompleted(CustomerInfo)
    case restoreStarted
    case restoreCompleted(CustomerInfo)
    case premiumStatusUpdated(Bool, CustomerInfo?)
    case errorOccurred(Error)

    var eventName: String {
        switch self {
        case .willShow: return "paywall_will_show"
        case .didShow: return "paywall_did_show"
        case .skipped: return "paywall_skipped"
        case .cancelled: return "paywall_cancelled"
        case .purchaseStarted: return "paywall_purchase_started"
        case .purchaseCompleted: return "paywall_purchase_completed"
        case .restoreStarted: return "paywall_restore_started"
        case .restoreCompleted: return "paywall_restore_completed"
        case .premiumStatusUpdated: return "paywall_premium_status_updated"
        case .errorOccurred: return "paywall_error"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .willShow, .didShow, .skipped, .cancelled, .purchaseStarted, .restoreStarted:
            return [:]
        case let .purchaseCompleted(info):
            return ["activeSubscriptions": info.activeSubscriptions]
        case let .restoreCompleted(info):
            return ["activeSubscriptions": info.activeSubscriptions]
        case let .premiumStatusUpdated(isPremium, _):
            return ["isPremium": isPremium]
        case let .errorOccurred(error):
            return ["description": error.localizedDescription]
        }
    }
} 