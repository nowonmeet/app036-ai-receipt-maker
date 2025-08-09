//
//  MainTabView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI

struct MainTabView: View {
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
    }
}

#Preview {
    MainTabView()
}