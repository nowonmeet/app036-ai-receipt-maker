//
//  APIConfiguration.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

enum APIConfiguration {
    static var openAIAPIKey: String {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
              !apiKey.isEmpty,
              !apiKey.contains("your-") else {
            #if DEBUG
            fatalError("⚠️ OpenAI API Key not configured. Please set OPENAI_API_KEY in Xcode Scheme Environment Variables")
            #else
            fatalError("⚠️ OpenAI API Key not configured")
            #endif
        }
        return apiKey
    }
    
    static var apiBaseURL: String {
        if let baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"],
           !baseURL.isEmpty {
            return baseURL
        }
        return "https://api.openai.com/v1/"
    }
    
    static var feedbackGASEndpointURL: String {
        if let gasURL = ProcessInfo.processInfo.environment["FEEDBACK_GAS_ENDPOINT_URL"],
           !gasURL.isEmpty {
            return gasURL
        }
        return "https://script.google.com/macros/s/AKfycby7Eivl6JdFHzw8tzs68zBUXNnfQ7hEGbVqF_-c6RkzganfBKKxbmcfXQiqV94JWWet/exec"
    }
    
    static func validateConfiguration() {
        #if DEBUG
        print("✅ API Configuration validated")
        print("📍 Base URL: \(apiBaseURL)")
        print("🔑 API Key: \(String(openAIAPIKey.prefix(10)))...")
        #endif
    }
}