//
//  OnboardingViewModel.swift
//  app036_ai_receipt_maker
//
//  Created by AI Assistant on 2025/08/14.
//

import Foundation
import SwiftUI

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPageIndex: Int = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            title: "Welcome to AI Receipt Maker",
            subtitle: "Create professional receipts instantly with AI",
            imageName: "doc.text.image.fill",
            primaryColor: "#007AFF",
            secondaryColor: "#5AC8FA"
        ),
        OnboardingPage(
            id: 1,
            title: "Random Generation",
            subtitle: "Generate receipts with one tap using random stores and items",
            imageName: "dice.fill",
            primaryColor: "#FF9500",
            secondaryColor: "#FFCC00"
        ),
        OnboardingPage(
            id: 2,
            title: "Custom Creation",
            subtitle: "Customize every detail - store name, items, and prices",
            imageName: "slider.horizontal.3",
            primaryColor: "#FF3B30",
            secondaryColor: "#FF6B6B"
        ),
        OnboardingPage(
            id: 3,
            title: "Manage Your Receipts",
            subtitle: "Save, search, and export your generated receipts",
            imageName: "photo.stack.fill",
            primaryColor: "#34C759",
            secondaryColor: "#52D869"
        ),
        OnboardingPage(
            id: 4,
            title: "Get Started",
            subtitle: "Create your first AI-powered receipt now",
            imageName: "sparkles",
            primaryColor: "#AF52DE",
            secondaryColor: "#DA70D6"
        )
    ]
    
    var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }
    
    var isFirstPage: Bool {
        currentPageIndex == 0
    }
    
    var progress: Double {
        Double(currentPageIndex + 1) / Double(pages.count)
    }
    
    func nextPage() {
        if currentPageIndex < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPageIndex += 1
            }
        }
    }
    
    func previousPage() {
        if currentPageIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPageIndex -= 1
            }
        }
    }
    
    func skipToEnd() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPageIndex = pages.count - 1
        }
    }
}