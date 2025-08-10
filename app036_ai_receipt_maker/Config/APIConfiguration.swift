//
//  APIConfiguration.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

enum APIConfiguration {
    static var openAIAPIKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
              !apiKey.isEmpty,
              !apiKey.contains("your-") else {
            #if DEBUG
            fatalError("⚠️ OpenAI API Key not configured. Please set OPENAI_API_KEY in Development.xcconfig")
            #else
            fatalError("⚠️ OpenAI API Key not configured")
            #endif
        }
        return apiKey
    }
    
    static var apiBaseURL: String {
        guard let baseURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              !baseURL.isEmpty else {
            return "https://api.openai.com/v1/"
        }
        return baseURL
    }
    
    static func validateConfiguration() {
        #if DEBUG
        print("✅ API Configuration validated")
        print("📍 Base URL: \(apiBaseURL)")
        print("🔑 API Key: \(String(openAIAPIKey.prefix(10)))...")
        #endif
    }
}