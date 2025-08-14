//
//  OnboardingContainerView.swift
//  app036_ai_receipt_maker
//
//  Created by AI Assistant on 2025/08/14.
//

import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @ObservedObject var onboardingManager: OnboardingManager
    @State private var dragOffset: CGSize = .zero
    
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack {
                skipButton
                
                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageIndex)
                
                VStack(spacing: 30) {
                    OnboardingIndicatorView(
                        totalPages: viewModel.pages.count,
                        currentPage: viewModel.currentPageIndex
                    )
                    
                    navigationButtons
                }
                .padding(.bottom, 50)
            }
        }
        .gesture(swipeGesture)
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: viewModel.pages[viewModel.currentPageIndex].primaryColor).opacity(0.1),
                Color(hex: viewModel.pages[viewModel.currentPageIndex].secondaryColor).opacity(0.05),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.5), value: viewModel.currentPageIndex)
    }
    
    private var skipButton: some View {
        HStack {
            Spacer()
            
            if !viewModel.isLastPage {
                Button("Skip") {
                    viewModel.skipToEnd()
                }
                .foregroundColor(.secondary)
                .padding()
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            if !viewModel.isFirstPage {
                Button(action: viewModel.previousPage) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(25)
                }
            }
            
            Spacer()
            
            if viewModel.isLastPage {
                Button(action: completeOnboarding) {
                    HStack {
                        Text("Get Started")
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: viewModel.pages[viewModel.currentPageIndex].primaryColor),
                                Color(hex: viewModel.pages[viewModel.currentPageIndex].secondaryColor)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                    .shadow(color: Color(hex: viewModel.pages[viewModel.currentPageIndex].primaryColor).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .scaleEffect(1.05)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: viewModel.currentPageIndex
                )
            } else {
                Button(action: viewModel.nextPage) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: viewModel.pages[viewModel.currentPageIndex].primaryColor),
                                Color(hex: viewModel.pages[viewModel.currentPageIndex].secondaryColor)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(25)
                }
            }
        }
        .padding(.horizontal, 30)
    }
    
    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 50
                
                withAnimation(.spring()) {
                    if value.translation.width > threshold && !viewModel.isFirstPage {
                        viewModel.previousPage()
                    } else if value.translation.width < -threshold && !viewModel.isLastPage {
                        viewModel.nextPage()
                    }
                    dragOffset = .zero
                }
            }
    }
    
    private func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            onboardingManager.completeOnboarding()
            onComplete()
        }
    }
}

#Preview {
    OnboardingContainerView(
        onboardingManager: OnboardingManager(),
        onComplete: {
            print("Onboarding completed")
        }
    )
}