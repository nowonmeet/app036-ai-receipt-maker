import Foundation

/// Service for managing onboarding flow and state
final class OnboardingService: ObservableObject {
    
    // MARK: - Constants
    private enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    // MARK: - Properties
    private let userDefaults: UserDefaults
    
    // MARK: - Initialization
    
    /// Initialize with custom UserDefaults (useful for testing)
    /// - Parameter userDefaults: UserDefaults instance
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Public Methods
    
    /// Determines if onboarding should be shown
    /// In release builds: only show for first-time users
    /// In debug builds: always show (for development)
    var shouldShowOnboarding: Bool {
        #if DEBUG
        return shouldShowOnboardingForced
        #else
        return !hasCompletedOnboarding
        #endif
    }
    
    /// Force show onboarding (useful for debug/testing)
    var shouldShowOnboardingForced: Bool {
        return true // Always show in debug mode
    }
    
    /// Check if user has completed onboarding
    var hasCompletedOnboarding: Bool {
        return userDefaults.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
    }
    
    /// Mark onboarding as completed
    func completeOnboarding() {
        userDefaults.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        userDefaults.synchronize()
    }
    
    /// Reset onboarding status (useful for testing/debugging)
    func resetOnboardingStatus() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        userDefaults.synchronize()
    }
    
    /// Get all onboarding pages in order
    /// - Returns: Array of onboarding pages
    func getOnboardingPages() -> [OnboardingPage] {
        return OnboardingPage.createDefaultPages()
    }
    
    /// Get specific page by type
    /// - Parameter type: Page type to retrieve
    /// - Returns: Onboarding page if found
    func getPage(for type: OnboardingPageType) -> OnboardingPage? {
        return getOnboardingPages().first { $0.type == type }
    }
    
    /// Get total number of onboarding pages
    var totalPages: Int {
        return getOnboardingPages().count
    }
}