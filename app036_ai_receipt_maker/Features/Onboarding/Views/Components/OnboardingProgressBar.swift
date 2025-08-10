import SwiftUI

/// Animated progress bar for onboarding flow
struct OnboardingProgressBar: View {
    let progress: Double // 0.0 to 1.0
    let primaryColor: String
    
    @Environment(\.colorScheme) private var colorScheme
    
    /// Background track color based on color scheme
    private var trackColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color.gray.opacity(0.2)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 2)
                    .fill(trackColor)
                    .frame(height: 4)
                
                // Progress fill
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: primaryColor),
                                Color(hex: primaryColor).opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressBar(progress: 0.25, primaryColor: "#6C5CE7")
        OnboardingProgressBar(progress: 0.5, primaryColor: "#0984E3")
        OnboardingProgressBar(progress: 0.75, primaryColor: "#00B894")
        OnboardingProgressBar(progress: 1.0, primaryColor: "#FDCB6E")
    }
    .padding()
}