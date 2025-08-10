import SwiftUI
import RevenueCat
import RevenueCatUI

/// Settings画面から表示するペイウォールシート
struct PaywallPageView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var paywallManager: UniversalPaywallManager
    
    init() {
        let config = PaywallConfiguration(
            revenueCatAPIKey: "appl_bPrLQLKIcCNqkFYqmUheReHuvJh", // Same API key as in UniversalPaywallManager
            premiumEntitlementKey: "premium_features",
            theme: .reading,
            showCloseButton: true,
            presentationMode: .embedded,  // Use embedded mode to avoid sheet conflicts
            displayDelay: 0.0,
            debugMode: true
        )
        
        self._paywallManager = StateObject(wrappedValue: UniversalPaywallManager(
            configuration: config,
            delegate: ReadingProgressPaywallDelegate.shared
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
                PaywallView(offering: offering, displayCloseButton: true)
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
                PaywallView(displayCloseButton: true)
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