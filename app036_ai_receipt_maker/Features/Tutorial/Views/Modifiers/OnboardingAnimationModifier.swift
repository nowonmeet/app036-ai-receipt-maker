//
//  OnboardingAnimationModifier.swift
//  app036_ai_receipt_maker
//
//  Created by AI Assistant on 2025/08/14.
//

import SwiftUI

struct OnboardingSlideTransition: ViewModifier {
    let isActive: Bool
    let direction: SlideDirection
    
    enum SlideDirection {
        case leading, trailing
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .offset(x: isActive ? 0 : (direction == .leading ? -100 : 100))
            .animation(.easeInOut(duration: 0.5), value: isActive)
    }
}

struct OnboardingScaleEffect: ViewModifier {
    let isActive: Bool
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isActive ? 1 : scale)
            .opacity(isActive ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isActive)
    }
}

struct OnboardingFadeIn: ViewModifier {
    let isActive: Bool
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isActive ? 1 : 0)
            .animation(
                .easeInOut(duration: 0.6)
                    .delay(delay),
                value: isActive
            )
    }
}

struct OnboardingPulse: ViewModifier {
    @State private var isPulsing = false
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                if isActive {
                    isPulsing = true
                }
            }
            .onChange(of: isActive) { _, newValue in
                isPulsing = newValue
            }
    }
}

extension View {
    func onboardingSlideTransition(
        isActive: Bool,
        direction: OnboardingSlideTransition.SlideDirection = .trailing
    ) -> some View {
        modifier(OnboardingSlideTransition(isActive: isActive, direction: direction))
    }
    
    func onboardingScaleEffect(
        isActive: Bool,
        scale: CGFloat = 0.8
    ) -> some View {
        modifier(OnboardingScaleEffect(isActive: isActive, scale: scale))
    }
    
    func onboardingFadeIn(
        isActive: Bool,
        delay: Double = 0
    ) -> some View {
        modifier(OnboardingFadeIn(isActive: isActive, delay: delay))
    }
    
    func onboardingPulse(isActive: Bool) -> some View {
        modifier(OnboardingPulse(isActive: isActive))
    }
}