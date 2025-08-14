//
//  OnboardingIntegrationTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by AI Assistant on 2025/08/14.
//

import Testing
import SwiftUI
import Foundation
@testable import app036_ai_receipt_maker

struct OnboardingIntegrationTests {
    
    @Test("OnboardingManager and ViewModel integration")
    func testOnboardingFlow() {
        let userDefaults = UserDefaults(suiteName: "integration_test")!
        let manager = OnboardingManager(userDefaults: userDefaults)
        let viewModel = OnboardingViewModel()
        
        #expect(manager.hasCompletedOnboarding == false)
        #expect(viewModel.currentPageIndex == 0)
        #expect(viewModel.isFirstPage == true)
        #expect(viewModel.isLastPage == false)
        
        viewModel.nextPage()
        #expect(viewModel.currentPageIndex == 1)
        
        viewModel.skipToEnd()
        #expect(viewModel.isLastPage == true)
        
        manager.completeOnboarding()
        #expect(manager.hasCompletedOnboarding == true)
    }
    
    @Test("Complete onboarding workflow")
    func testCompleteWorkflow() {
        let userDefaults = UserDefaults(suiteName: "workflow_test")!
        let manager = OnboardingManager(userDefaults: userDefaults)
        let viewModel = OnboardingViewModel()
        
        #expect(manager.hasCompletedOnboarding == false)
        
        while !viewModel.isLastPage {
            viewModel.nextPage()
        }
        
        #expect(viewModel.isLastPage == true)
        #expect(viewModel.currentPageIndex == 4)
        
        manager.completeOnboarding()
        #expect(manager.hasCompletedOnboarding == true)
        
        let newManager = OnboardingManager(userDefaults: userDefaults)
        #expect(newManager.hasCompletedOnboarding == true)
    }
    
    @Test("OnboardingPage data integrity")
    func testPageDataIntegrity() {
        let viewModel = OnboardingViewModel()
        
        #expect(viewModel.pages.count == 5)
        
        for (index, page) in viewModel.pages.enumerated() {
            #expect(page.id == index)
            #expect(!page.title.isEmpty)
            #expect(!page.subtitle.isEmpty)
            #expect(!page.imageName.isEmpty)
            #expect(!page.primaryColor.isEmpty)
            #expect(!page.secondaryColor.isEmpty)
        }
        
        let expectedTitles = [
            "Welcome to AI Receipt Maker",
            "Random Generation",
            "Custom Creation",
            "Manage Your Receipts",
            "Get Started"
        ]
        
        for (index, expectedTitle) in expectedTitles.enumerated() {
            #expect(viewModel.pages[index].title == expectedTitle)
        }
    }
    
    @Test("Progress calculation accuracy")
    func testProgressCalculation() {
        let viewModel = OnboardingViewModel()
        
        #expect(viewModel.progress == 0.2)
        
        viewModel.currentPageIndex = 1
        #expect(viewModel.progress == 0.4)
        
        viewModel.currentPageIndex = 2
        #expect(viewModel.progress == 0.6)
        
        viewModel.currentPageIndex = 3
        #expect(viewModel.progress == 0.8)
        
        viewModel.currentPageIndex = 4
        #expect(viewModel.progress == 1.0)
    }
}