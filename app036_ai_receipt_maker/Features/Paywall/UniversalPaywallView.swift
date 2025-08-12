import SwiftUI
import RevenueCat
import RevenueCatUI

/// 汎用的なペイウォール表示ビュー
/// 設定とデリゲートパターンで他のアプリでも流用できるよう設計
public struct UniversalPaywallView: View {
    
    // MARK: - Properties
    
    /// ペイウォール管理クラス
    @ObservedObject private var paywallManager: UniversalPaywallManager
    
    /// ペイウォール設定
    private let configuration: PaywallConfiguration
    
    /// ローディング状態
    @State private var isLoading = true
    
    /// 事前ロード済みのOffering
    @State private var preloadedOffering: Offering?
    
    /// Analytics用の時間追跡
    @State private var paywallAppearTime: Date?
    
    // MARK: - Initialization
    
    /// 初期化
    /// - Parameter paywallManager: ペイウォール管理クラス
    public init(paywallManager: UniversalPaywallManager) {
        self.paywallManager = paywallManager
        self.configuration = paywallManager.configuration
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            switch configuration.presentationMode {
            case .embedded:
                // 直接表示（既にシート内など）
                embeddedPaywallContent
            case .sheet:
                // シート表示（従来通り）
                sheetBasedPaywallContent
            }
        }
        .preferredColorScheme(configuration.theme.primaryColor == .white ? .dark : .light)
        .onAppear {
            handleViewAppear()
        }
        .onDisappear {
            handleViewDisappear()
        }
    }
    
    /// 直接表示用のコンテンツ（embeddedモード）
    private var embeddedPaywallContent: some View {
        Group {
            if isLoading {
                // ローディング表示
                loadingView
            } else {
                // ペイウォール本体を直接表示
                paywallSheetContent
            }
        }
    }
    
    /// シート表示用のコンテンツ（sheetモード）
    private var sheetBasedPaywallContent: some View {
        Group {
            if isLoading {
                // ローディング表示
                loadingView
            } else {
                // ペイウォール本体を直接表示（embeddedモードでは追加シート不要）
                paywallSheetContent
            }
        }
    }
    
    // MARK: - Private Views
    
    /// ローディング表示
    private var loadingView: some View {
        VStack(spacing: 20) {
            // ローディングテキストが空でない場合のみ表示
            if !configuration.loadingText.isEmpty {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(configuration.theme.primaryColor)
                
                Text(configuration.loadingText)
                    .font(configuration.theme.fontConfiguration.titleFont)
                    .foregroundColor(configuration.theme.textColor)
                    .fontWeight(.medium)
            }
            
            // スキップボタン（設定で有効な場合のみ表示）
            if configuration.showSkipButton {
                Button(configuration.skipButtonText) {
                    // Analytics: Paywall スキップインタラクション
                    
                    paywallManager.handleSkip()
                }
                .foregroundColor(configuration.theme.textColor.opacity(0.7))
                .font(configuration.theme.fontConfiguration.buttonFont)
                .padding(.top, 20)
            }
        }
    }
    
    /// ペイウォールシートの内容
    private var paywallSheetContent: some View {
        Group {
            if let offering = preloadedOffering {
                RevenueCatUI.PaywallView(offering: offering)
                    .onAppear {
                        if configuration.debugMode {
                            print("🎯 特定のOfferingでPaywallViewを表示:")
                            print("  - Offering ID: '\(offering.identifier)'")
                            print("  - Packages: \(offering.availablePackages.count)個")
                            print("  - Metadata: \(offering.metadata)")
                        }
                    }
            } else {
                RevenueCatUI.PaywallView()
                    .onAppear {
                        if configuration.debugMode {
                            print("🎯 デフォルトのPaywallViewを表示（フォールバック）")
                            print("  - 理由: preloadedOfferingがnil")
                        }
                    }
            }
        }
            .onPurchaseCompleted { customerInfo in
                if configuration.debugMode {
                    print("✅ [UniversalPaywallView] 購入完了")
                    print("  - CustomerID: \(customerInfo.originalAppUserId)")
                    print("  - アクティブサブスクリプション: \(customerInfo.activeSubscriptions)")
                    print("  - アクティブエンタイトルメント: \(customerInfo.entitlements.active.keys)")
                }
                paywallManager.handlePurchaseCompleted(customerInfo: customerInfo)
            }
            .onRestoreCompleted { customerInfo in
                if configuration.debugMode {
                    print("🔄 [UniversalPaywallView] リストア完了")
                    print("  - アクティブサブスクリプション: \(customerInfo.activeSubscriptions)")
                }
                paywallManager.handleRestoreCompleted(customerInfo: customerInfo)
            }
            .onRequestedDismissal {
                if configuration.debugMode {
                    print("❌ [UniversalPaywallView] ペイウォール閉じる要求")
                }
                paywallManager.dismissPaywall()
            }
            .onPurchaseStarted { packageType in
                // Analytics: 購入開始インタラクション
                
                // 購入開始時の処理
                if configuration.debugMode {
                    print("💳 [UniversalPaywallView] 購入開始")
                    print("  - Package: \(packageType)")
                }
            }
            .onPurchaseCancelled {
                // 購入キャンセル時の処理
                if configuration.debugMode {
                    print("❌ [UniversalPaywallView] 購入キャンセル")
                }
            }
            .onPurchaseFailure { error in
                // 購入失敗時の処理
                if configuration.debugMode {
                    print("❌ [UniversalPaywallView] 購入失敗エラー詳細:")
                    print("  - エラー: \(error)")
                    print("  - ローカライズ: \(error.localizedDescription)")
                    if let revenueCatError = error as? RevenueCat.ErrorCode {
                        print("  - RevenueCat ErrorCode: \(revenueCatError)")
                        print("  - ErrorCode RawValue: \(revenueCatError.rawValue)")
                    }
                    print("  - NSError Domain: \((error as NSError).domain)")
                    print("  - NSError Code: \((error as NSError).code)")
                    print("  - NSError UserInfo: \((error as NSError).userInfo)")
                }
                paywallManager.handleError(error)
            }
            .onRestoreStarted {
                // Handle restore start
                if configuration.debugMode {
                    print("🔄 Restore started")
                }
            }
            .onRestoreFailure { error in
                // Handle restore failure
                paywallManager.handleError(error)
            }
    }
    
    // MARK: - Private Methods
    
    /// ビュー表示時の処理
    private func handleViewAppear() {
        paywallAppearTime = Date()
        
        if configuration.debugMode {
            print("📱 UniversalPaywallView display started")
            print("📱 Presentation mode: \(configuration.presentationMode)")
        }
        
        // Analyticsイベントを記録
        let trigger = paywallManager.triggerSource ?? "unknown"
        let bookCount = UserDefaults.standard.integer(forKey: "user_book_count")
        let installDate = UserDefaults.standard.object(forKey: "app_install_date") as? Date ?? Date()
        let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        
        
        // Offeringsを事前にロードしてからペイウォールを表示
        Task {
            await preloadOfferings()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + configuration.displayDelay) {
                isLoading = false
            }
        }
    }
    
    /// Offeringsを事前ロード（RevenueCatのローディング画面を回避）
    private func preloadOfferings() async {
        do {
            if configuration.debugMode {
                print("🔄 Offerings preload started")
                print("🔧 Configuration entitlement key: \(configuration.premiumEntitlementKey)")
                print("🔧 Alternative entitlement keys: \(configuration.alternativeEntitlementKeys)")
                print("🔧 RevenueCat API key: \(configuration.revenueCatAPIKey)")
                
                // 現在のCustomerInfo確認
                if let customerInfo = try? await Purchases.shared.customerInfo() {
                    print("👤 CustomerInfo:")
                    print("  - CustomerID: \(customerInfo.originalAppUserId)")
                    print("  - Active Subscriptions: \(customerInfo.activeSubscriptions)")
                    print("  - Active Entitlements: \(customerInfo.entitlements.active.keys)")
                }
            }
            
            let offerings = try await Purchases.shared.offerings()
            
            await MainActor.run {
                self.preloadedOffering = offerings.current
                
                if configuration.debugMode {
                    print("📋 Available Offerings details:")
                    print("  - Total Offerings: \(offerings.all.count)")
                    print("  - Current Offering: \(offerings.current?.identifier ?? "nil")")
                    
                    for (key, offering) in offerings.all {
                        print("  🎯 Offering ID: '\(key)'")
                        print("    - Identifier: '\(offering.identifier)'")
                        print("    - Description: '\(offering.serverDescription)'")
                        print("    - Metadata: \(offering.metadata)")
                        print("    - Product Count: \(offering.availablePackages.count)")
                        
                        for package in offering.availablePackages {
                            print("      📦 Package: '\(package.identifier)'")
                            print("        - Product ID: '\(package.storeProduct.productIdentifier)'")
                            print("        - Title: '\(package.storeProduct.localizedTitle)'")
                            print("        - Price: '\(package.localizedPriceString)'")
                        }
                        
                        // Check for paywall configuration availability
                        print("    - Has Paywall Config: Investigating...")
                    }
                    
                    if preloadedOffering != nil {
                        print("✅ Offerings preload completed")
                        print("  - Selected Current Offering ID: '\(preloadedOffering?.identifier ?? "unknown")'")
                    } else {
                        print("⚠️ Current offering does not exist")
                        print("  - Available Offerings count: \(offerings.all.count)")
                        print("  - Trying to use first available Offering")
                        
                        // フォールバック: 最初に利用可能なOfferingを使用
                        if let firstOffering = offerings.all.values.first {
                            self.preloadedOffering = firstOffering
                            print("  - Fallback Offering: '\(firstOffering.identifier)'")
                        }
                    }
                }
            }
        } catch {
            if configuration.debugMode {
                print("❌ Offerings preload error: \(error.localizedDescription)")
                if let revenueCatError = error as? ErrorCode {
                    print("  - RevenueCat ErrorCode: \(revenueCatError)")
                    print("  - Error Code Raw Value: \(revenueCatError.rawValue)")
                }
                print("  - Error Domain: \((error as NSError).domain)")
                print("  - Error Code: \((error as NSError).code)")
                print("  - Error UserInfo: \((error as NSError).userInfo)")
            }
            // In case of error, use default PaywallView as fallback
        }
    }
    
    /// ビュー非表示時の処理
    private func handleViewDisappear() {
        guard let appearTime = paywallAppearTime else { return }
        let timeSpent = Date().timeIntervalSince(appearTime)
        
        
        paywallAppearTime = nil
        
        if configuration.debugMode {
            print("📱 UniversalPaywallView disappeared")
            print("  - Time spent: \(Int(timeSpent)) seconds")
        }
    }
}

// MARK: - UniversalPaywallContainer

/// ペイウォール表示を統合管理するコンテナビュー
/// 使用する側のコードをさらに簡潔にするためのラッパー
public struct UniversalPaywallContainer: View {
    
    // MARK: - Properties
    
    /// ペイウォール管理クラス
    @StateObject private var paywallManager: UniversalPaywallManager
    
    /// ペイウォール設定
    private let configuration: PaywallConfiguration
    
    /// フロー制御デリゲート
    private let delegate: PaywallFlowDelegate
    
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
        self._paywallManager = StateObject(wrappedValue: UniversalPaywallManager(
            configuration: configuration,
            delegate: delegate
        ))
    }
    
    // MARK: - Body
    
    public var body: some View {
        UniversalPaywallView(paywallManager: paywallManager)
    }
    
    // MARK: - Public Methods
    
    /// 外部からペイウォールを表示
    /// - Parameter triggerSource: トリガーソース（アナリティクス用）
    public func showPaywall(triggerSource: String? = nil) {
        paywallManager.showPaywall(triggerSource: triggerSource)
    }
    
    /// 外部からペイウォールを閉じる
    public func dismissPaywall() {
        paywallManager.dismissPaywall()
    }
    
    /// 現在のプレミアム状態を取得
    public var isPremiumActive: Bool {
        paywallManager.isPremiumActive
    }
    
    /// ペイウォール表示状態を取得
    public var isShowingPaywall: Bool {
        paywallManager.isShowingPaywall
    }
    
    /// プレミアム機能が必要かチェック
    public func requiresPremiumAccess() -> Bool {
        paywallManager.requiresPremiumAccess()
    }
    
    /// 課金状態を手動でチェック
    public func checkSubscriptionStatus() {
        paywallManager.checkSubscriptionStatus()
    }
    
    /// 内部のペイウォールマネージャーを取得（高度な使用のため）
    public var manager: UniversalPaywallManager {
        paywallManager
    }
}

// MARK: - Preview

#if DEBUG
/// プレビュー用のサンプルデリゲート
private class PreviewPaywallDelegate: PaywallFlowDelegate {
    func didCompletePurchase(customerInfo: CustomerInfo) {
        print("🎉 プレビュー: 購入完了")
    }
    
    func didCompleteRestore(customerInfo: CustomerInfo) {
        print("🔄 プレビュー: リストア完了")
    }
    
    func didCancelPaywall() {
        print("❌ プレビュー: ペイウォールキャンセル")
    }
}

#Preview("デフォルトテーマ") {
    let config = PaywallConfiguration(
        revenueCatAPIKey: "preview_key",
        premiumEntitlementKey: "premium_plan",
        theme: .default,
        showSkipButton: true,
        debugMode: true
    )
    
    return UniversalPaywallContainer(
        configuration: config,
        delegate: PreviewPaywallDelegate()
    )
}

#Preview("ライトテーマ") {
    let config = PaywallConfiguration(
        revenueCatAPIKey: "preview_key",
        premiumEntitlementKey: "premium_plan",
        theme: .light,
        showSkipButton: false,
        debugMode: true
    )
    
    return UniversalPaywallContainer(
        configuration: config,
        delegate: PreviewPaywallDelegate()
    )
}

#Preview("ダークテーマ") {
    let config = PaywallConfiguration(
        revenueCatAPIKey: "preview_key",
        premiumEntitlementKey: "premium_plan",
        theme: .dark,
        showSkipButton: true,
        loadingText: "Loading Premium Features...",
        skipButtonText: "Skip for now",
        debugMode: true
    )
    
    return UniversalPaywallContainer(
        configuration: config,
        delegate: PreviewPaywallDelegate()
    )
}
#endif