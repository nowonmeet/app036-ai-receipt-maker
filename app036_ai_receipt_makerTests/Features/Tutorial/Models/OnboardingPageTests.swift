//
//  OnboardingPageTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by AI Assistant on 2025/08/14.
//

import Testing
@testable import app036_ai_receipt_maker

struct OnboardingPageTests {
    
    @Test("OnboardingPage initialization with all properties")
    func testInitialization() {
        let page = OnboardingPage(
            id: 1,
            title: "Welcome",
            subtitle: "AI-powered receipt generation",
            imageName: "receipt.fill",
            primaryColor: "#007AFF",
            secondaryColor: "#5AC8FA"
        )
        
        #expect(page.id == 1)
        #expect(page.title == "Welcome")
        #expect(page.subtitle == "AI-powered receipt generation")
        #expect(page.imageName == "receipt.fill")
        #expect(page.primaryColor == "#007AFF")
        #expect(page.secondaryColor == "#5AC8FA")
    }
    
    @Test("OnboardingPage Equatable conformance")
    func testEquatable() {
        let page1 = OnboardingPage(
            id: 1,
            title: "Welcome",
            subtitle: "Subtitle",
            imageName: "icon",
            primaryColor: "#000000",
            secondaryColor: "#FFFFFF"
        )
        
        let page2 = OnboardingPage(
            id: 1,
            title: "Welcome",
            subtitle: "Subtitle",
            imageName: "icon",
            primaryColor: "#000000",
            secondaryColor: "#FFFFFF"
        )
        
        let page3 = OnboardingPage(
            id: 2,
            title: "Different",
            subtitle: "Different",
            imageName: "icon2",
            primaryColor: "#111111",
            secondaryColor: "#EEEEEE"
        )
        
        #expect(page1 == page2)
        #expect(page1 != page3)
    }
    
    @Test("OnboardingPage Identifiable conformance")
    func testIdentifiable() {
        let page = OnboardingPage(
            id: 42,
            title: "Test",
            subtitle: "Test subtitle",
            imageName: "test.icon",
            primaryColor: "#FF0000",
            secondaryColor: "#00FF00"
        )
        
        #expect(page.id == 42)
    }
}