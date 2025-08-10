import SwiftUI

/// Simple view for prompting app review after onboarding
struct AppReviewPromptView: View {
    
    let onRateApp: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                headerView
                contentView
                buttonView
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .shadow(color: Color(.systemGray).opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.95)),
            removal: .opacity.combined(with: .scale(scale: 1.05))
        ))
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Enjoying Read Progre?")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Your feedback helps us improve the app for everyone. Would you mind leaving a review?")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
    }
    
    private var buttonView: some View {
        VStack(spacing: 12) {
            Button(action: onRateApp) {
                Text("Rate App")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
            
            Button(action: onDismiss) {
                Text("Maybe Later")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AppReviewPromptView(
        onRateApp: {},
        onDismiss: {}
    )
}