//
//  MainTabView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject private var paywallManager = UniversalPaywallManager.shared
    
    var body: some View {
        TabView {
            GenerateReceiptView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Generate")
                }
            
            ReceiptGalleryView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle")
                    Text("Gallery")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .sheet(isPresented: $paywallManager.isShowingPaywall) {
            UniversalPaywallView(paywallManager: paywallManager)
        }
    }
}

#Preview {
    MainTabView()
}