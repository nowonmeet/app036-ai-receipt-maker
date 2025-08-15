//
//  PremiumUpgradePromptView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/16.
//

import SwiftUI

struct PremiumUpgradePromptView: View {
    let onUpgradeTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Want Higher Quality?")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Benefits
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("3x sharper image quality")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("Crystal clear text and details")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("Professional quality receipts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // CTA Button
            Button(action: onUpgradeTapped) {
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16))
                    Text("Upgrade to Premium Quality")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

#Preview {
    PremiumUpgradePromptView {
        print("Upgrade tapped")
    }
}