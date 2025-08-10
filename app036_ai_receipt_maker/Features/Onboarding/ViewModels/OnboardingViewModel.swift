import Foundation
import SwiftUI

/// ViewModel for managing onboarding flow and navigation
@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Current page index (0-based)
    @Published var currentPageIndex: Int = 0
    
    /// Whether onboarding is currently being shown
    @Published var isShowingOnboarding: Bool = false
    
    /// Animation trigger for page transitions
    @Published var animationTrigger: Bool = false
    
    // MARK: - Private Properties
    
    private let onboardingService: OnboardingService
    
    // MARK: - Computed Properties
    
    /// All onboarding pages
    var pages: [OnboardingPage] {
        return onboardingService.getOnboardingPages()
    }
    
    /// Current page being displayed
    var currentPage: OnboardingPage {
        return pages[currentPageIndex]
    }
    
    /// Whether user can go to previous page
    var canGoBack: Bool {
        return currentPageIndex > 0
    }
    
    /// Whether user can go to next page
    var canGoForward: Bool {
        return currentPageIndex < pages.count - 1
    }
    
    /// Whether currently on the last page
    var isLastPage: Bool {
        return currentPageIndex == pages.count - 1
    }
    
    /// Progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard pages.count > 0 else { return 0.0 }
        return Double(currentPageIndex + 1) / Double(pages.count)
    }
    
    // MARK: - Initialization
    
    /// Initialize with onboarding service
    /// - Parameter onboardingService: Service for managing onboarding state
    init(onboardingService: OnboardingService = OnboardingService()) {
        self.onboardingService = onboardingService
    }
    
    // MARK: - Public Methods
    
    /// Check if onboarding should be shown and update state accordingly
    func checkShouldShowOnboarding() {
        isShowingOnboarding = onboardingService.shouldShowOnboarding
        
        // Analytics: 初回オンボーディング表示を記録
        if isShowingOnboarding {
            AnalyticsService.shared.logOnboardingStepViewed(0, stepName: pages.first?.title ?? "welcome")
        }
    }
    
    /// Navigate to the next page with animation
    func goToNextPage() {
        guard canGoForward else { return }
        
        // Analytics: オンボーディングステップを記録
        let nextStepName = currentPageIndex + 1 < pages.count ? pages[currentPageIndex + 1].title : "final"
        AnalyticsService.shared.logOnboardingStepViewed(currentPageIndex + 1, stepName: nextStepName)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPageIndex += 1
            animationTrigger.toggle()
        }
    }
    
    /// Navigate to the previous page with animation
    func goToPreviousPage() {
        guard canGoBack else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPageIndex -= 1
            animationTrigger.toggle()
        }
    }
    
    /// Navigate to a specific page
    /// - Parameter index: Target page index
    func goToPage(_ index: Int) {
        guard index >= 0 && index < pages.count else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPageIndex = index
            animationTrigger.toggle()
        }
    }
    
    /// Complete the onboarding flow
    func completeOnboarding(onCompletion: (() -> Void)? = nil) {
        onboardingService.completeOnboarding()
        
        // Analytics: オンボーディング完了を記録
        AnalyticsService.shared.logOnboardingCompleted()
        
        withAnimation(.easeOut(duration: 0.3)) {
            isShowingOnboarding = false
        }
        
        // Notify completion for post-onboarding flow
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            onCompletion?()
        }
    }
    
    /// Skip onboarding (marks as completed)
    func skipOnboarding() {
        // Analytics: オンボーディングスキップを記録
        AnalyticsService.shared.logOnboardingSkipped(atStep: currentPageIndex, reason: "user_skip")
        
        completeOnboarding()
    }
    
    /// Restart onboarding from the beginning
    func restartOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPageIndex = 0
            isShowingOnboarding = true
            animationTrigger.toggle()
        }
    }
    
    /// Reset onboarding status (useful for testing/debugging)
    func resetOnboardingStatus() {
        onboardingService.resetOnboardingStatus()
        currentPageIndex = 0
        isShowingOnboarding = false
    }
    
    /// Force show onboarding (useful for settings/preview)
    func forceShowOnboarding() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPageIndex = 0
            isShowingOnboarding = true
        }
    }
}