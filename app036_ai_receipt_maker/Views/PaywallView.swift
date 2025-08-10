//
//  PaywallView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Upgrade to Premium")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 16) {
                    Label("10 generations per day", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("No watermarks on saved images", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Label("Priority support", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .font(.title3)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                Text("$4.99 / month")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Button("Subscribe Now") {
                    // TODO: RevenueCat integration
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Restore Purchases") {
                    // TODO: RevenueCat restore
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Premium Features")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    PaywallView()
}