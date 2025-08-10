import SwiftUI

/// Page indicator for onboarding flow with animated transitions
struct OnboardingPageIndicator: View {
    let totalPages: Int
    let currentIndex: Int
    let primaryColor: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    /// Inactive indicator color based on color scheme
    private var inactiveColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.3) : Color.gray.opacity(0.3)
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color(hex: primaryColor) : inactiveColor)
                    .frame(width: index == currentIndex ? 12 : 8, height: index == currentIndex ? 12 : 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingPageIndicator(totalPages: 4, currentIndex: 0, primaryColor: "#6C5CE7")
        OnboardingPageIndicator(totalPages: 4, currentIndex: 1, primaryColor: "#0984E3")
        OnboardingPageIndicator(totalPages: 4, currentIndex: 2, primaryColor: "#00B894")
        OnboardingPageIndicator(totalPages: 4, currentIndex: 3, primaryColor: "#FDCB6E")
    }
    .padding()
}