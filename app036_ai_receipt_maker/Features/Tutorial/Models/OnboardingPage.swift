//
//  OnboardingPage.swift
//  app036_ai_receipt_maker
//
//  Created by AI Assistant on 2025/08/14.
//

import Foundation

struct OnboardingPage: Identifiable, Equatable {
    let id: Int
    let title: String
    let subtitle: String
    let imageName: String
    let primaryColor: String
    let secondaryColor: String
    
    init(
        id: Int,
        title: String,
        subtitle: String,
        imageName: String,
        primaryColor: String,
        secondaryColor: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
}