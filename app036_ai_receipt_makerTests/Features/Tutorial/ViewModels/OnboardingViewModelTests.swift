//
//  OnboardingViewModelTests.swift
//  app036_ai_receipt_makerTests
//
//  Created by AI Assistant on 2025/08/14.
//

import Testing
@testable import app036_ai_receipt_maker

struct OnboardingViewModelTests {
    
    @Test("OnboardingViewModel initializes with default pages")
    func testInitialization() {
        let viewModel = OnboardingViewModel()
        
        #expect(viewModel.pages.count == 5)
        #expect(viewModel.currentPageIndex == 0)
        #expect(viewModel.isLastPage == false)
        #expect(viewModel.isFirstPage == true)
    }
    
    @Test("OnboardingViewModel page navigation - next")
    func testNextPage() {
        let viewModel = OnboardingViewModel()
        
        viewModel.nextPage()
        #expect(viewModel.currentPageIndex == 1)
        
        viewModel.nextPage()
        #expect(viewModel.currentPageIndex == 2)
    }
    
    @Test("OnboardingViewModel page navigation - previous")
    func testPreviousPage() {
        let viewModel = OnboardingViewModel()
        
        viewModel.currentPageIndex = 2
        viewModel.previousPage()
        #expect(viewModel.currentPageIndex == 1)
        
        viewModel.previousPage()
        #expect(viewModel.currentPageIndex == 0)
    }
    
    @Test("OnboardingViewModel prevents navigation beyond bounds")
    func testNavigationBounds() {
        let viewModel = OnboardingViewModel()
        
        viewModel.previousPage()
        #expect(viewModel.currentPageIndex == 0)
        
        viewModel.currentPageIndex = 4
        viewModel.nextPage()
        #expect(viewModel.currentPageIndex == 4)
    }
    
    @Test("OnboardingViewModel isLastPage property")
    func testIsLastPage() {
        let viewModel = OnboardingViewModel()
        
        #expect(viewModel.isLastPage == false)
        
        viewModel.currentPageIndex = 4
        #expect(viewModel.isLastPage == true)
    }
    
    @Test("OnboardingViewModel isFirstPage property")
    func testIsFirstPage() {
        let viewModel = OnboardingViewModel()
        
        #expect(viewModel.isFirstPage == true)
        
        viewModel.currentPageIndex = 1
        #expect(viewModel.isFirstPage == false)
    }
    
    @Test("OnboardingViewModel progress calculation")
    func testProgress() {
        let viewModel = OnboardingViewModel()
        
        #expect(viewModel.progress == 0.2)
        
        viewModel.currentPageIndex = 2
        #expect(viewModel.progress == 0.6)
        
        viewModel.currentPageIndex = 4
        #expect(viewModel.progress == 1.0)
    }
}