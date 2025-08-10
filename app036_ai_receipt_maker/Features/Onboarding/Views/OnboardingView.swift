import SwiftUI

/// Main onboarding view with page navigation and animations
struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    /// Callback when onboarding is completed
    let onCompletion: (() -> Void)?
    
    /// Dynamic background color based on current page and color scheme
    private var dynamicBackgroundColor: Color {
        colorScheme == .dark 
            ? Color(hex: viewModel.currentPage.darkModeBackgroundColor) 
            : Color(hex: viewModel.currentPage.backgroundColor)
    }
    
    /// Enhanced secondary text color for better visibility
    private var enhancedSecondaryColor: Color {
        colorScheme == .dark ? Color.primary.opacity(0.8) : Color.secondary
    }
    
    var body: some View {
        ZStack {
            // Full screen background
            dynamicBackgroundColor
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Top section with progress and skip
                topSection
                
                // Main content area
                TabView(selection: $viewModel.currentPageIndex) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(
                            page: page,
                            animationTrigger: viewModel.animationTrigger
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: viewModel.currentPageIndex)
                
                // Bottom navigation section
                bottomSection
            }
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    private var topSection: some View {
        VStack(spacing: 16) {
            HStack {
                // Progress bar
                OnboardingProgressBar(
                    progress: viewModel.progressPercentage,
                    primaryColor: viewModel.currentPage.primaryColor
                )
                
                Spacer()
                
                // Skip button
                Button("Skip") {
                    viewModel.completeOnboarding(onCompletion: onCompletion)
                }
                .font(.subheadline)
                .foregroundStyle(enhancedSecondaryColor)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Page indicator
            OnboardingPageIndicator(
                totalPages: viewModel.pages.count,
                currentIndex: viewModel.currentPageIndex,
                primaryColor: viewModel.currentPage.primaryColor
            )
        }
    }
    
    private var bottomSection: some View {
        VStack(spacing: 16) {
            // Primary action button
            primaryActionButton
            
            // Navigation buttons
            HStack {
                // Back button (always present but invisible on first page)
                if viewModel.canGoBack {
                    OnboardingNavigationButton(
                        title: "Back",
                        style: .secondary
                    ) {
                        viewModel.goToPreviousPage()
                    }
                    .frame(maxWidth: 120)
                } else {
                    // Invisible spacer to maintain layout consistency
                    Spacer()
                        .frame(maxWidth: 120)
                }
                
                Spacer()
                
                // Skip/Continue hint
                if !viewModel.isLastPage {
                    Button("Skip") {
                        viewModel.completeOnboarding(onCompletion: onCompletion)
                    }
                    .font(.subheadline)
                    .foregroundStyle(enhancedSecondaryColor)
                    .frame(maxWidth: 120)
                } else {
                    Spacer()
                        .frame(maxWidth: 120)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 50)
    }
    
    private var primaryActionButton: some View {
        OnboardingNavigationButton(
            title: primaryActionButtonTitle,
            style: .primary(color: viewModel.currentPage.primaryColor)
        ) {
            if viewModel.isLastPage {
                viewModel.completeOnboarding(onCompletion: onCompletion)
            } else {
                viewModel.goToNextPage()
            }
        }
    }
    
    private var primaryActionButtonTitle: String {
        switch viewModel.currentPage.type {
        case .welcome:
            return "Start My Journey"
        case .bookManagement:
            return "Organize My Books"
        case .progressTracking:
            return "Track My Progress"
        case .premiumFeatures:
            return "Unlock Premium"
        }
    }
    
    
    private func setupInitialState() {
        // Add any initial setup if needed
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(), onCompletion: nil)
}