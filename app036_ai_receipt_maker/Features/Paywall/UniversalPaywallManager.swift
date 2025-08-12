import Foundation
import SwiftUI
import RevenueCat
import Combine

/// 汎用的なペイウォール管理クラス
/// 他のアプリでも簡単に流用できるよう設計
/// 設定とデリゲートパターンで疎結合を実現
public final class UniversalPaywallManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    
    /// シングルトンインスタンス（アプリ全体で共有）
    public static let shared: UniversalPaywallManager = {
        let config = PaywallConfiguration(
            revenueCatAPIKey: "appl_eKuEEsPvpzKyMHFZeVlReOtBoBi", // AI Receipt Maker用APIキー
            premiumEntitlementKey: "premium_plan",
            theme: .receipt,             // レシートアプリ専用テーマ
            showCloseButton: true,
            presentationMode: .sheet,    // シート表示
            displayDelay: 1.0,           // 1秒の遅延
            debugMode: true
        )
        return UniversalPaywallManager(
            configuration: config,
            delegate: ReceiptMakerPaywallDelegate.shared
        )
    }()
    
    // MARK: - Published Properties
    
    /// ペイウォールを表示中かどうか
    @Published public var isShowingPaywall = false
    
    /// プレミアム機能が有効かどうか
    @Published public private(set) var isPremiumActive = false
    
    /// 課金状態の読み込み中かどうか
    @Published public private(set) var isLoading = false
    
    /// エラー状態
    @Published public private(set) var error: String?
    
    /// 現在のOffering
    @Published public private(set) var currentOffering: Offering?
    
    /// トリガーソース（アナリティクス用）
    public private(set) var triggerSource: String?
    
    // MARK: - Private Properties
    
    /// ペイウォール設定
    public let configuration: PaywallConfiguration
    
    /// フロー制御デリゲート
    private weak var delegate: PaywallFlowDelegate?
    
    /// 課金状態管理（内部で使用）
    private var subscriptionManager: UniversalSubscriptionManager
    
    /// 更新処理中フラグ（重複処理防止）
    private var isUpdating = false
    
    /// Combine用のキャンセラー
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// 初期化
    /// - Parameters:
    ///   - configuration: ペイウォール設定
    ///   - delegate: フロー制御デリゲート
    public init(
        configuration: PaywallConfiguration,
        delegate: PaywallFlowDelegate
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.subscriptionManager = UniversalSubscriptionManager(configuration: configuration)
        
        super.init()
        
        setupRevenueCat()
        setupSubscriptionBinding()
        
        // Offeringを非同期で読み込み
        Task {
            await loadCurrentOffering()
        }
        
        if configuration.debugMode {
            print("🚀 UniversalPaywallManager initialization completed")
            print("  - APIKey: \(configuration.revenueCatAPIKey)")
            print("  - EntitlementKey: \(configuration.premiumEntitlementKey)")
            print("  - DebugMode: \(configuration.debugMode)")
        }
    }
    
    deinit {
        if configuration.debugMode {
            print("🗑️ UniversalPaywallManager deallocated")
        }
    }
    
    // MARK: - Public Methods
    
    /// ペイウォールを表示
    /// - Parameter triggerSource: トリガーソース（アナリティクス用）
    public func showPaywall(triggerSource: String? = nil) {
        guard !isShowingPaywall else {
            if configuration.debugMode {
                print("⚠️ Paywall already showing")
            }
            return
        }
        
        let source = triggerSource ?? "unknown"
        self.triggerSource = source
        
        delegate?.willShowPaywall()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.displayDelay) {
            self.isShowingPaywall = true
            self.delegate?.didShowPaywall()
        }
    }
    
    /// ペイウォールを閉じる
    public func dismissPaywall() {
        if configuration.debugMode {
            print("🚪 [PaywallManager] Paywall dismiss process started")
            print("  - Current isShowingPaywall: \(isShowingPaywall)")
        }
        
        // Analyticsイベントを記録 (AnalyticsService未実装のためコメントアウト)
        // AnalyticsService.shared.logPaywallDismissed(reason: "close_button")
        
        DispatchQueue.main.async {
            self.isShowingPaywall = false
            if self.configuration.debugMode {
                print("🚪 [PaywallManager] Set isShowingPaywall to false")
            }
        }
        
        delegate?.didCancelPaywall()
        
        if configuration.debugMode {
            print("🚪 [PaywallManager] Paywall dismiss process completed")
        }
    }
    
    /// 購入完了処理
    /// - Parameter customerInfo: RevenueCatから取得した顧客情報
    public func handlePurchaseCompleted(customerInfo: CustomerInfo) {
        if configuration.debugMode {
            print("🎉 Purchase completion process started")
        }
        
        // Analyticsイベントを記録 (AnalyticsService未実装のためコメントアウト)
        // AnalyticsService.shared.logTrialStarted()
        
        isShowingPaywall = false
        
        // 即座にプレミアム状態を有効化（UI反映のため）
        DispatchQueue.main.async {
            self.isPremiumActive = true
            if self.configuration.debugMode {
                print("🎉 Purchase completed: isPremiumActive immediately activated")
            }
        }
        
        delegate?.didCompletePurchase(customerInfo: customerInfo)
        
        // バックグラウンドで課金状態を確実に更新
        subscriptionManager.forcePremiumActivation()
    }
    
    /// リストア完了処理
    /// - Parameter customerInfo: RevenueCatから取得した顧客情報
    public func handleRestoreCompleted(customerInfo: CustomerInfo) {
        if configuration.debugMode {
            print("🔄 Restore completion process started")
        }
        
        isShowingPaywall = false
        
        // 即座にプレミアム状態を有効化（UI反映のため）  
        DispatchQueue.main.async {
            self.isPremiumActive = true
            if self.configuration.debugMode {
                print("🔄 Restore completed: isPremiumActive immediately activated")
            }
        }
        
        delegate?.didCompleteRestore(customerInfo: customerInfo)
        
        // バックグラウンドで課金状態を確実に更新
        subscriptionManager.forcePremiumActivation()
    }
    
    /// スキップ処理
    public func handleSkip() {
        if configuration.debugMode {
            print("⏭️ Paywall skip process")
        }
        
        isShowingPaywall = false
        delegate?.didSkipPaywall()
    }
    
    /// エラー処理
    /// - Parameter error: 発生したエラー
    public func handleError(_ error: Error) {
        if configuration.debugMode {
            print("❌ Paywall error: \(error)")
        }
        
        self.error = error.localizedDescription
        delegate?.didEncounterError(error)
    }
    
    /// エラー状態をクリア
    public func clearError() {
        error = nil
    }
    
    /// 課金状態を手動でチェック
    public func checkSubscriptionStatus() {
        subscriptionManager.checkSubscriptionStatus()
    }
    
    /// プレミアム機能が必要かチェック
    /// - Returns: プレミアム機能が必要な場合true
    public func requiresPremiumAccess() -> Bool {
        return subscriptionManager.requiresPremiumAccess()
    }
    
    /// 現在のOfferingを読み込み
    public func loadCurrentOffering() async {
        do {
            if configuration.debugMode {
                print("🔄 [UniversalPaywallManager] Loading current offering...")
            }
            
            let offerings = try await Purchases.shared.offerings()
            
            await MainActor.run {
                self.currentOffering = offerings.current
                
                if configuration.debugMode {
                    if let offering = self.currentOffering {
                        print("✅ [UniversalPaywallManager] Current offering loaded: \(offering.identifier)")
                    } else {
                        print("⚠️ [UniversalPaywallManager] No current offering available")
                        // フォールバック: 最初のOfferingを使用
                        if let firstOffering = offerings.all.values.first {
                            self.currentOffering = firstOffering
                            print("📦 [UniversalPaywallManager] Using first available offering: \(firstOffering.identifier)")
                        }
                    }
                }
            }
        } catch {
            if configuration.debugMode {
                print("❌ [UniversalPaywallManager] Failed to load offerings: \(error)")
            }
            handleError(error)
        }
    }
    
    // MARK: - Debug Methods
    
    /// デバッグ用：課金状態を手動でトグル（デバッグビルドのみ）
    public func togglePremiumForDebug() {
        #if DEBUG
        let newState = !isPremiumActive
        
        DispatchQueue.main.async {
            self.isPremiumActive = newState
            if self.configuration.debugMode {
                print("🔧 Debug toggle: isPremiumActive = \(newState)")
            }
        }
        
        // subscriptionManagerも更新
        subscriptionManager.setIsPremiumActive(newState)
        
        // デリゲートに通知
        delegate?.didUpdatePremiumStatus(isPremium: newState, customerInfo: nil)
        #endif
    }
    
    /// デバッグ用：課金状態を無課金にリセット（デバッグビルドのみ）
    public func resetToFreeUserForDebug() {
        #if DEBUG
        DispatchQueue.main.async {
            self.isPremiumActive = false
            if self.configuration.debugMode {
                print("🔧 Debug reset: Changed to free user status")
            }
        }
        
        // subscriptionManagerも更新
        subscriptionManager.setIsPremiumActive(false)
        
        // デリゲートに通知
        delegate?.didUpdatePremiumStatus(isPremium: false, customerInfo: nil)
        #endif
    }
    
    /// デバッグ用：課金状態をプレミアムに設定（デバッグビルドのみ）
    public func setPremiumForDebug() {
        #if DEBUG
        DispatchQueue.main.async {
            self.isPremiumActive = true
            if self.configuration.debugMode {
                print("🔧 Debug setting: Changed to premium status")
            }
        }
        
        // subscriptionManagerも更新
        subscriptionManager.setIsPremiumActive(true)
        
        // デリゲートに通知
        delegate?.didUpdatePremiumStatus(isPremium: true, customerInfo: nil)
        #endif
    }
    
    // MARK: - Private Methods
    
    /// RevenueCatの初期化設定
    private func setupRevenueCat() {
        // AppDelegateで初期化済みの場合は設定のみ更新
        if Purchases.isConfigured {
            Purchases.logLevel = configuration.debugMode ? .debug : .info
            if configuration.debugMode {
                print("✅ RevenueCat configuration updated (already initialized)")
            }
        } else {
            // 初期化されていない場合のみ設定
            Purchases.logLevel = configuration.debugMode ? .debug : .info
            Purchases.configure(withAPIKey: configuration.revenueCatAPIKey)
            if configuration.debugMode {
                print("✅ RevenueCat initialization completed")
            }
        }
    }
    
    /// 課金状態の監視設定
    private func setupSubscriptionBinding() {
        // 課金状態の変更を監視
        subscriptionManager.$isPremiumActive
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPremium in
                guard let self = self else { return }
                
                if self.configuration.debugMode {
                    print("🔄 [UniversalPaywallManager] subscriptionManager status change notification:")
                    print("  - New status: \(isPremium)")
                    print("  - Current status: \(self.isPremiumActive)")
                }
                
                let wasChanged = self.isPremiumActive != isPremium
                self.isPremiumActive = isPremium
                
                if self.configuration.debugMode {
                    print("🔄 [UniversalPaywallManager] isPremiumActive update completed: \(self.isPremiumActive)")
                    print("  - Changed: \(wasChanged)")
                }
                
                if wasChanged {
                    if self.configuration.debugMode {
                        print("🔔 [UniversalPaywallManager] Notifying delegate of status change")
                    }
                    
                    self.delegate?.didUpdatePremiumStatus(
                        isPremium: isPremium,
                        customerInfo: nil
                    )
                }
            }
            .store(in: &cancellables)
        
        // ローディング状態の監視
        subscriptionManager.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        // エラー状態の監視
        subscriptionManager.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.error = errorMessage
            }
            .store(in: &cancellables)
    }
}

// MARK: - UniversalSubscriptionManager

/// 汎用的な課金状態管理クラス
/// 他のアプリでも直接使用可能（ペイウォール表示が不要な場合）
public final class UniversalSubscriptionManager: NSObject, ObservableObject, PurchasesDelegate {
    
    // MARK: - Published Properties
    
    @Published public private(set) var isPremiumActive = false
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: String?
    
    // MARK: - Private Properties
    
    private let configuration: PaywallConfiguration
    private var isUpdating = false
    
    // MARK: - Initialization
    
    public init(configuration: PaywallConfiguration) {
        self.configuration = configuration
        super.init()
        
        Purchases.shared.delegate = self
        
        // アプリ起動時に課金状態をチェック
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkSubscriptionStatus()
        }
    }
    
    deinit {
        if Purchases.shared.delegate === self {
            Purchases.shared.delegate = nil
        }
    }
    
    // MARK: - Public Methods
    
    public func checkSubscriptionStatus() {
        if configuration.debugMode {
            print("========== Subscription status check started ==========")
        }
        
        isLoading = true
        error = nil
        
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    if self?.configuration.debugMode == true {
                        print("❌ Subscription status fetch error: \(error.localizedDescription)")
                    }
                    self?.error = error.localizedDescription
                    self?.isPremiumActive = false
                    return
                }
                
                guard let customerInfo = customerInfo else {
                    if self?.configuration.debugMode == true {
                        print("❌ customerInfo is nil")
                    }
                    self?.isPremiumActive = false
                    return
                }
                
                self?.updatePremiumStatus(from: customerInfo)
            }
        }
    }
    
    public func requiresPremiumAccess() -> Bool {
        return !isPremiumActive
    }
    
    public func forcePremiumActivation() {
        if configuration.debugMode {
            print("🚀 Force activate subscription status")
        }
        
        DispatchQueue.main.async {
            self.isPremiumActive = true
        }
        
        let checkTimes: [Double] = [0.1, 0.5, 1.0, 2.0, 3.0]
        for (index, delay) in checkTimes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if self.configuration.debugMode {
                    print("🔄 Post-purchase \(delay)s check (\(index + 1)/\(checkTimes.count))")
                }
                self.checkSubscriptionStatus()
            }
        }
    }
    
    public func togglePremiumForDebug() {
        #if DEBUG
        if configuration.debugMode {
            print("🔧 Debug: Toggle subscription status")
        }
        DispatchQueue.main.async {
            self.isPremiumActive.toggle()
            if self.configuration.debugMode {
                print("🔧 Debug: isPremiumActive = \(self.isPremiumActive)")
            }
        }
        #endif
    }
    
    /// エラー状態をクリア
    public func clearError() {
        DispatchQueue.main.async {
            self.error = nil
        }
    }
    
    /// 内部用：プレミアム状態を直接設定
    public func setIsPremiumActive(_ value: Bool) {
        DispatchQueue.main.async {
            self.isPremiumActive = value
            if self.configuration.debugMode {
                print("🔄 Direct set isPremiumActive: \(value)")
            }
        }
    }
    
    // MARK: - PurchasesDelegate
    
    public func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        guard !isUpdating else {
            if configuration.debugMode {
                print("🔄 PurchasesDelegate update: Skipped due to processing")
            }
            return
        }
        
        if configuration.debugMode {
            print("📢 PurchasesDelegate: Received CustomerInfo update")
        }
        
        updatePremiumStatus(from: customerInfo)
    }
    
    // MARK: - Private Methods
    
    private func updatePremiumStatus(from customerInfo: CustomerInfo) {
        isUpdating = true
        defer { isUpdating = false }
        
        if configuration.debugMode {
            print("========== [UniversalSubscriptionManager] updatePremiumStatus started ==========")
            print("📝 CustomerInfo update: \(customerInfo.originalAppUserId)")
            print("📝 Active subscriptions: \(customerInfo.activeSubscriptions)")
            print("📝 All entitlements: \(customerInfo.entitlements)")
            print("📝 One-time purchases: \(customerInfo.nonSubscriptions)")
            print("📝 Current isPremiumActive: \(self.isPremiumActive)")
        }
        
        var foundActiveEntitlement = false
        
        // 設定されたエンタイトルメントキーをすべてチェック
        for key in configuration.allEntitlementKeys {
            if configuration.debugMode {
                print("🔍 Entitlement check: \(key)")
            }
            
            if let entitlement = customerInfo.entitlements[key] {
                if configuration.debugMode {
                    print("  - Entitlement exists: \(entitlement.identifier)")
                    print("  - isActive: \(entitlement.isActive)")
                    print("  - willRenew: \(entitlement.willRenew)")
                    print("  - periodType: \(entitlement.periodType)")
                }
                
                if entitlement.isActive {
                    if configuration.debugMode {
                        print("✅ Active entitlement found: \(key)")
                    }
                    foundActiveEntitlement = true
                    break
                }
            } else {
                if configuration.debugMode {
                    print("  - Entitlement not found: \(key)")
                }
            }
        }
        
        // アクティブなサブスクリプションのチェック
        if !foundActiveEntitlement && !customerInfo.activeSubscriptions.isEmpty {
            if configuration.debugMode {
                print("✅ Active subscription found: \(customerInfo.activeSubscriptions)")
            }
            foundActiveEntitlement = true
        }
        
        // ワンタイム購入のチェック
        if !foundActiveEntitlement && !customerInfo.nonSubscriptions.isEmpty {
            if configuration.debugMode {
                print("✅ One-time purchase found: \(customerInfo.nonSubscriptions)")
                for nonSub in customerInfo.nonSubscriptions {
                    print("  - Product ID: \(nonSub.productIdentifier)")
                    print("  - Purchase date: \(nonSub.purchaseDate)")
                }
            }
            foundActiveEntitlement = true
        }
        
        if configuration.debugMode {
            print("🎯 Final determination: isPremiumActive = \(foundActiveEntitlement)")
            print("📝 Before change: \(self.isPremiumActive) → After change: \(foundActiveEntitlement)")
        }
        
        DispatchQueue.main.async {
            let oldValue = self.isPremiumActive
            self.isPremiumActive = foundActiveEntitlement
            
            if self.configuration.debugMode {
                print("🔄 [UniversalSubscriptionManager] isPremiumActive update completed on main thread")
                print("  - Before change: \(oldValue)")
                print("  - After change: \(self.isPremiumActive)")
                print("========== updatePremiumStatus completed ==========")
            }
        }
    }
}