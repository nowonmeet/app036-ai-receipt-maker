import Foundation
import StoreKit
import UIKit

/// Service for managing in-app review requests based on user engagement
class AppReviewService: ObservableObject {
    
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletionCountKey = "onboardingCompletionCount"
    private let reviewRequestedVersionsKey = "reviewRequestedVersions"
    private let minimumCompletionThreshold = 1
    
    /// Number of times user has completed onboarding
    @Published var onboardingCompletedCount: Int {
        didSet {
            userDefaults.set(onboardingCompletedCount, forKey: onboardingCompletionCountKey)
        }
    }
    
    /// Whether review should be requested based on current state
    var shouldRequestReview: Bool {
        return onboardingCompletedCount >= minimumCompletionThreshold &&
               !wasReviewRequestedForVersion(currentAppVersion)
    }
    
    /// Current app version string
    var currentAppVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    init() {
        self.onboardingCompletedCount = userDefaults.integer(forKey: onboardingCompletionCountKey)
    }
    
    /// Increments the onboarding completion count
    func incrementOnboardingCompleted() {
        onboardingCompletedCount += 1
    }
    
    /// Marks review as requested for the current app version
    func markReviewRequestedForCurrentVersion() {
        var requestedVersions = getReviewRequestedVersions()
        requestedVersions.insert(currentAppVersion)
        userDefaults.set(Array(requestedVersions), forKey: reviewRequestedVersionsKey)
    }
    
    /// Resets review request status for new version (allows re-requesting)
    func resetReviewRequestForNewVersion() {
        let requestedVersions = getReviewRequestedVersions()
        let filteredVersions = requestedVersions.filter { $0 != currentAppVersion }
        userDefaults.set(Array(filteredVersions), forKey: reviewRequestedVersionsKey)
    }
    
    /// Checks if review was already requested for a specific version
    func wasReviewRequestedForVersion(_ version: String) -> Bool {
        let requestedVersions = getReviewRequestedVersions()
        return requestedVersions.contains(version)
    }
    
    /// Requests app store review if conditions are met
    @MainActor
    func requestReviewIfAppropriate() {
        guard shouldRequestReview else { return }
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
            markReviewRequestedForCurrentVersion()
        }
    }
    
    // MARK: - Private Methods
    
    private func getReviewRequestedVersions() -> Set<String> {
        let versions = userDefaults.stringArray(forKey: reviewRequestedVersionsKey) ?? []
        return Set(versions)
    }
}