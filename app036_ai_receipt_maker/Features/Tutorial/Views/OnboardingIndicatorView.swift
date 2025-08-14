//
//  OnboardingIndicatorView.swift
//  app036_ai_receipt_maker
//
//  Created by AI Assistant on 2025/08/14.
//

import SwiftUI

struct OnboardingIndicatorView: View {
    let totalPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingIndicatorView(totalPages: 5, currentPage: 0)
        OnboardingIndicatorView(totalPages: 5, currentPage: 2)
        OnboardingIndicatorView(totalPages: 5, currentPage: 4)
    }
    .padding()
}