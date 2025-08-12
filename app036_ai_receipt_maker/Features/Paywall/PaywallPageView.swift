import SwiftUI
import RevenueCat
import RevenueCatUI

/// Settings画面から表示するペイウォールシート
struct PaywallPageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var paywallManager: UniversalPaywallManager
    
    init() {
        let config = PaywallConfiguration(
            revenueCatAPIKey: "appl_eKuEEsPvpzKyMHFZeVlReOtBoBi", // AI Receipt Maker用APIキー
            premiumEntitlementKey: "premium_plan",
            theme: .receipt,              // レシートアプリ専用テーマ
            showCloseButton: true,
            presentationMode: .sheet,     // シート表示
            displayDelay: 1.0,
            debugMode: true
        )
        
        self._paywallManager = StateObject(wrappedValue: UniversalPaywallManager(
            configuration: config,
            delegate: ReceiptMakerPaywallDelegate.shared
        ))
    }
    
    var body: some View {
        ZStack {
            // Background with theme
            PaywallTheme.reading.backgroundStyle.makeView()
                .ignoresSafeArea()
            
            // Paywall content with direct dismiss handling
            paywallContent
        }
        .preferredColorScheme(.dark) // Since reading theme has white text
        .onAppear {
            if paywallManager.configuration.debugMode {
                print("🚀 [PaywallPageView] Paywall sheet opened")
            }
        }
        .onDisappear {
            if paywallManager.configuration.debugMode {
                print("🚪 [PaywallPageView] Paywall sheet closed")
            }
        }
    }
    
    private var paywallContent: some View {
        Group {
            if let offering = paywallManager.currentOffering {
                RevenueCatUI.PaywallView(offering: offering)
                    .onRequestedDismissal {
                        if paywallManager.configuration.debugMode {
                            print("❌ [PaywallPageView] Dismiss requested via close button")
                        }
                        dismiss()
                    }
                    .onPurchaseCompleted { customerInfo in
                        if paywallManager.configuration.debugMode {
                            print("✅ [PaywallPageView] Purchase completed - dismissing")
                        }
                        paywallManager.handlePurchaseCompleted(customerInfo: customerInfo)
                        dismiss()
                    }
                    .onRestoreCompleted { customerInfo in
                        if paywallManager.configuration.debugMode {
                            print("🔄 [PaywallPageView] Restore completed - dismissing")
                        }
                        paywallManager.handleRestoreCompleted(customerInfo: customerInfo)
                        dismiss()
                    }
                    .onPurchaseCancelled {
                        if paywallManager.configuration.debugMode {
                            print("❌ [PaywallPageView] Purchase cancelled")
                        }
                    }
                    .onPurchaseFailure { error in
                        if paywallManager.configuration.debugMode {
                            print("❌ [PaywallPageView] Purchase failed: \(error)")
                        }
                        paywallManager.handleError(error)
                    }
            } else {
                RevenueCatUI.PaywallView()
                    .onRequestedDismissal {
                        if paywallManager.configuration.debugMode {
                            print("❌ [PaywallPageView] Dismiss requested via close button (default offering)")
                        }
                        dismiss()
                    }
                    .onPurchaseCompleted { customerInfo in
                        if paywallManager.configuration.debugMode {
                            print("✅ [PaywallPageView] Purchase completed - dismissing (default offering)")
                        }
                        paywallManager.handlePurchaseCompleted(customerInfo: customerInfo)
                        dismiss()
                    }
                    .onRestoreCompleted { customerInfo in
                        if paywallManager.configuration.debugMode {
                            print("🔄 [PaywallPageView] Restore completed - dismissing (default offering)")
                        }
                        paywallManager.handleRestoreCompleted(customerInfo: customerInfo)
                        dismiss()
                    }
                    .onPurchaseCancelled {
                        if paywallManager.configuration.debugMode {
                            print("❌ [PaywallPageView] Purchase cancelled (default offering)")
                        }
                    }
                    .onPurchaseFailure { error in
                        if paywallManager.configuration.debugMode {
                            print("❌ [PaywallPageView] Purchase failed: \(error) (default offering)")
                        }
                        paywallManager.handleError(error)
                    }
            }
        }
        .onAppear {
            // Ensure we load offerings when the paywall appears
            Task {
                await paywallManager.loadCurrentOffering()
            }
        }
    }
}


#Preview {
    PaywallPageView()
}