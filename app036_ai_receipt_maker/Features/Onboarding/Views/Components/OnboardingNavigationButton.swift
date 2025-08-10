import SwiftUI
import UIKit

/// Navigation button for onboarding flow with different styles
struct OnboardingNavigationButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    let isEnabled: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed: Bool = false
    
    enum ButtonStyle {
        case primary(color: String)
        case secondary
        case skip
    }
    
    init(
        title: String,
        style: ButtonStyle,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Call the action
            action()
        }) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                // Add subtle icon for primary buttons
                if case .primary = style {
                    Image(systemName: "arrow.right")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .opacity(0.8)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56) // Slightly taller for better touch target
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .shadow(
                        color: shadowColor,
                        radius: isPressed ? 4 : 8,
                        x: 0,
                        y: isPressed ? 2 : 4
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            )
            .scaleEffect(isPressed ? 0.95 : (isEnabled ? 1.0 : 0.95))
            .opacity(isEnabled ? 1.0 : 0.6)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        }
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .primary
        case .skip:
            return colorScheme == .dark ? Color.primary.opacity(0.8) : Color.secondary
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary(let colorHex):
            return Color(hex: colorHex)
        case .secondary:
            return Color.clear
        case .skip:
            return Color.clear
        }
    }
    
    private var strokeColor: Color {
        switch style {
        case .primary:
            return Color.clear
        case .secondary:
            return colorScheme == .dark ? Color.primary.opacity(0.4) : Color.primary.opacity(0.3)
        case .skip:
            return Color.clear
        }
    }
    
    private var strokeWidth: CGFloat {
        switch style {
        case .primary, .skip:
            return 0
        case .secondary:
            return 1
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary(let colorHex):
            return Color(hex: colorHex).opacity(colorScheme == .dark ? 0.4 : 0.3)
        case .secondary:
            return Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.1)
        case .skip:
            return Color.clear
        }
    }
}

// MARK: - Press Animation Modifier

extension View {
    func pressAnimation() -> some View {
        self.scaleEffect(1.0)
            .animation(.easeInOut(duration: 0.1), value: false)
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingNavigationButton(
            title: "Get Started",
            style: .primary(color: "#6C5CE7")
        ) {
            print("Primary button tapped")
        }
        
        OnboardingNavigationButton(
            title: "Back",
            style: .secondary
        ) {
            print("Secondary button tapped")
        }
        
        OnboardingNavigationButton(
            title: "Skip",
            style: .skip
        ) {
            print("Skip button tapped")
        }
        
        OnboardingNavigationButton(
            title: "Disabled",
            style: .primary(color: "#6C5CE7"),
            isEnabled: false
        ) {
            print("Disabled button tapped")
        }
    }
    .padding()
}