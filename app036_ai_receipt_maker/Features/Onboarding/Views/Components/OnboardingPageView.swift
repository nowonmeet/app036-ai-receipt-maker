import SwiftUI

/// Individual onboarding page view with animation support
struct OnboardingPageView: View {
    let page: OnboardingPage
    let animationTrigger: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var titleOpacity: Double = 0
    @State private var descriptionOpacity: Double = 0
    @State private var imageScale: Double = 0.5
    @State private var imageRotation: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var contentOffset: CGFloat = 50
    @State private var showDecorationElements: Bool = false
    @State private var pulseAnimation: Bool = false
    
    /// Dynamic background color based on color scheme
    private var dynamicBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: page.darkModeBackgroundColor) : Color(hex: page.backgroundColor)
    }
    
    /// Dynamic primary color based on color scheme
    private var dynamicPrimaryColor: Color {
        colorScheme == .dark ? Color(hex: page.darkModePrimaryColor) : Color(hex: page.primaryColor)
    }
    
    /// Enhanced secondary text color for better visibility
    private var enhancedSecondaryColor: Color {
        colorScheme == .dark ? Color.primary.opacity(0.8) : Color.secondary
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: 40)
                
                // Image section
                imageSection
                    .frame(minHeight: 200, maxHeight: geometry.size.height * 0.35)
                
                Spacer()
                    .frame(minHeight: 20, maxHeight: 40)
                
                // Content section
                contentSection
                    .frame(minHeight: 160)
                
                Spacer()
                    .frame(minHeight: 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        dynamicBackgroundColor,
                        dynamicBackgroundColor.opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .onAppear {
            animateIn()
        }
        .onChange(of: animationTrigger) {
            resetAndAnimateIn()
        }
    }
    
    private var imageSection: some View {
        ZStack {
            // Background decoration circles
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(dynamicPrimaryColor.opacity(0.1))
                    .frame(width: CGFloat(80 + index * 40), height: CGFloat(80 + index * 40))
                    .scaleEffect(showDecorationElements ? 1.2 : 0.8)
                    .opacity(showDecorationElements ? 0.3 : 0)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: showDecorationElements
                    )
            }
            
            // Main icon with enhanced effects
            VStack {
                Image(systemName: page.imageName)
                    .font(.system(size: 120, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                dynamicPrimaryColor,
                                dynamicPrimaryColor.opacity(0.6),
                                dynamicPrimaryColor.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(imageScale)
                    .rotationEffect(.degrees(imageRotation))
                    .shadow(
                        color: dynamicPrimaryColor.opacity(0.3),
                        radius: pulseAnimation ? 20 : 10,
                        x: 0,
                        y: 0
                    )
                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: imageScale)
                    .animation(.easeOut(duration: 1.2), value: imageRotation)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
                
                // Page-specific micro animations
                pageSpecificVisuals
            }
        }
    }
    
    @ViewBuilder
    private var pageSpecificVisuals: some View {
        switch page.type {
        case .welcome:
            // Floating book pages animation
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: "doc.text.fill")
                        .font(.caption)
                        .foregroundStyle(dynamicPrimaryColor.opacity(0.6))
                        .offset(y: showDecorationElements ? -20 : 0)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: showDecorationElements
                        )
                }
            }
            .padding(.top, 20)
            
        case .bookManagement:
            // Stack of books animation
            HStack(spacing: -5) {
                ForEach(0..<4, id: \.self) { index in
                    Rectangle()
                        .fill(dynamicPrimaryColor.opacity(0.7 - Double(index) * 0.1))
                        .frame(width: 15, height: 25)
                        .cornerRadius(2)
                        .rotationEffect(.degrees(Double(index) * 2))
                        .offset(x: showDecorationElements ? 0 : CGFloat(index) * 10)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1),
                            value: showDecorationElements
                        )
                }
            }
            .padding(.top, 20)
            
        case .progressTracking:
            // Growing bars animation
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(dynamicPrimaryColor.opacity(0.8))
                        .frame(width: 8, height: showDecorationElements ? CGFloat(10 + index * 8) : 5)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .delay(Double(index) * 0.2),
                            value: showDecorationElements
                        )
                }
            }
            .padding(.top, 20)
            
        case .premiumFeatures:
            // Sparkling stars animation
            ZStack {
                ForEach(0..<6, id: \.self) { index in
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(dynamicPrimaryColor.opacity(0.8))
                        .offset(
                            x: cos(Double(index) * .pi / 3) * 30,
                            y: sin(Double(index) * .pi / 3) * 30
                        )
                        .scaleEffect(showDecorationElements ? 1.0 : 0.3)
                        .opacity(showDecorationElements ? 1.0 : 0.3)
                        .animation(
                            .easeInOut(duration: 1.2)
                            .delay(Double(index) * 0.1),
                            value: showDecorationElements
                        )
                }
            }
            .padding(.top, 20)
        }
    }
    
    private var contentSection: some View {
        VStack(spacing: 20) {
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.primary,
                            dynamicPrimaryColor.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .opacity(titleOpacity)
                .offset(y: contentOffset)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: titleOpacity)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: contentOffset)
            
            Text(page.description)
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(enhancedSecondaryColor)
                .lineLimit(6)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(descriptionOpacity)
                .offset(y: contentOffset)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: descriptionOpacity)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: contentOffset)
            
            // Page-specific call-to-action hints
            pageSpecificCTA
                .opacity(descriptionOpacity)
                .animation(.easeOut(duration: 0.6).delay(1.0), value: descriptionOpacity)
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private var pageSpecificCTA: some View {
        switch page.type {
        case .welcome:
            HStack(spacing: 6) {
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundStyle(dynamicPrimaryColor)
                Text("Swipe to start your journey")
                    .font(.caption)
                    .foregroundStyle(enhancedSecondaryColor)
            }
            
        case .bookManagement:
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "barcode.viewfinder")
                            .font(.caption)
                        Text("Scan")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                        Text("Search")
                            .font(.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.caption)
                        Text("Add")
                            .font(.caption)
                    }
                }
                .foregroundStyle(dynamicPrimaryColor)
            }
            
        case .progressTracking:
            VStack(spacing: 4) {
                Text("🎯 Set reading goals")
                    .font(.caption)
                Text("📊 Track daily progress")
                    .font(.caption)
                Text("🏆 Celebrate milestones")
                    .font(.caption)
            }
            .foregroundStyle(enhancedSecondaryColor)
            
        case .premiumFeatures:
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    VStack(spacing: 2) {
                        Text("∞")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Books")
                            .font(.caption2)
                    }
                    
                    VStack(spacing: 2) {
                        Text("📝")
                            .font(.title2)
                        Text("Notes")
                            .font(.caption2)
                    }
                    
                    VStack(spacing: 2) {
                        Text("📈")
                            .font(.title2)
                        Text("Analytics")
                            .font(.caption2)
                    }
                }
                .foregroundStyle(dynamicPrimaryColor)
            }
        }
    }
    
    private func animateIn() {
        withAnimation(.none) {
            titleOpacity = 0
            descriptionOpacity = 0
            imageScale = 0.5
            imageRotation = -10
            backgroundOpacity = 0
            contentOffset = 50
            showDecorationElements = false
            pulseAnimation = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            backgroundOpacity = 1.0
            imageScale = 1.0
            imageRotation = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            titleOpacity = 1.0
            contentOffset = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            descriptionOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showDecorationElements = true
            pulseAnimation = true
        }
    }
    
    private func resetAndAnimateIn() {
        withAnimation(.none) {
            titleOpacity = 0
            descriptionOpacity = 0
            imageScale = 0.5
            imageRotation = 10
            backgroundOpacity = 0
            contentOffset = 50
            showDecorationElements = false
            pulseAnimation = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateIn()
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingPage.createDefaultPages()[0],
        animationTrigger: false
    )
}