import Foundation

/// Onboarding page type
enum OnboardingPageType: CaseIterable {
    case welcome
    case bookManagement
    case progressTracking
    case premiumFeatures
}

/// Individual onboarding page model
struct OnboardingPage: Identifiable, Equatable {
    let id = UUID()
    let type: OnboardingPageType
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: String // Hex color
    let primaryColor: String // Hex color for accents
    
    /// Creates an onboarding page
    /// - Parameters:
    ///   - type: Page type
    ///   - title: Page title text
    ///   - description: Page description text
    ///   - imageName: SF Symbol or asset name
    ///   - backgroundColor: Background color hex string
    ///   - primaryColor: Primary accent color hex string
    init(
        type: OnboardingPageType,
        title: String,
        description: String,
        imageName: String,
        backgroundColor: String = "#FFFFFF",
        primaryColor: String = "#007AFF"
    ) {
        self.type = type
        self.title = title
        self.description = description
        self.imageName = imageName
        self.backgroundColor = backgroundColor
        self.primaryColor = primaryColor
    }
}

extension OnboardingPage {
    /// Default onboarding pages for the reading progress app
    static func createDefaultPages() -> [OnboardingPage] {
        return [
            OnboardingPage(
                type: .welcome,
                title: "Transform Your Reading Life",
                description: "Join thousands of readers who've turned their reading dreams into reality. Never lose track of a book again.",
                imageName: "book.fill",
                backgroundColor: "#F8F9FA",
                primaryColor: "#6C5CE7"
            ),
            OnboardingPage(
                type: .bookManagement,
                title: "Say Goodbye to Book Chaos",
                description: "No more forgotten books or lost reading lists. Scan, search, or add manually - your personal library awaits.",
                imageName: "books.vertical.fill",
                backgroundColor: "#E8F4FD",
                primaryColor: "#0984E3"
            ),
            OnboardingPage(
                type: .progressTracking,
                title: "Watch Your Growth Unfold",
                description: "See your reading streak grow from days to months. Every page counts, every session matters.",
                imageName: "chart.line.uptrend.xyaxis",
                backgroundColor: "#E8F5E8",
                primaryColor: "#00B894"
            ),
            OnboardingPage(
                type: .premiumFeatures,
                title: "Become a Reading Champion",
                description: "Unlock unlimited books, deep insights, and note-taking. From casual reader to bookworm extraordinaire.",
                imageName: "crown.fill",
                backgroundColor: "#FFF3CD",
                primaryColor: "#FDCB6E"
            )
        ]
    }
    
    /// Get dark mode compatible background color
    var darkModeBackgroundColor: String {
        switch type {
        case .welcome:
            return "#1C1C1E"
        case .bookManagement:
            return "#0A1929"
        case .progressTracking:
            return "#0F1419"
        case .premiumFeatures:
            return "#2D1810"
        }
    }
    
    /// Get dark mode compatible primary color
    var darkModePrimaryColor: String {
        switch type {
        case .welcome:
            return "#9F7AEA"
        case .bookManagement:
            return "#3DA6E0"
        case .progressTracking:
            return "#48C78E"
        case .premiumFeatures:
            return "#FFD93D"
        }
    }
}