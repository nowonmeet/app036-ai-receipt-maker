//
//  DALLEService.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

final class DALLEService: DALLEServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/images/generations"
    
    var apiEndpoint: String {
        return baseURL
    }
    
    var requestHeaders: [String: String] {
        return [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
    }
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func generateReceiptImage(prompt: String) async throws -> Data {
        guard !prompt.isEmpty else {
            throw AppError.validationError("Prompt cannot be empty")
        }
        
        guard !apiKey.isEmpty else {
            throw AppError.apiError("API key is required")
        }
        
        let requestBody = DALLERequest(
            prompt: prompt,
            n: 1,
            size: "1024x1024",
            response_format: "b64_json"
        )
        
        guard let url = URL(string: baseURL) else {
            throw AppError.networkError("Invalid API URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw AppError.networkError("Failed to encode request: \(error.localizedDescription)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.networkError("Invalid response type")
            }
            
            guard httpResponse.statusCode == 200 else {
                throw AppError.apiError("API request failed with status code: \(httpResponse.statusCode)")
            }
            
            let dalleResponse = try JSONDecoder().decode(DALLEResponse.self, from: data)
            
            guard let firstImage = dalleResponse.data.first,
                  let imageData = Data(base64Encoded: firstImage.b64_json) else {
                throw AppError.apiError("Failed to decode image data from response")
            }
            
            return imageData
            
        } catch {
            if error is AppError {
                throw error
            } else {
                throw AppError.networkError("Network request failed: \(error.localizedDescription)")
            }
        }
    }
    
    func generatePrompt(from receiptData: ReceiptData) -> String {
        let formatter = CurrencyFormatter(locale: Locale.current)
        let storeName = receiptData.storeName ?? "Generic Store"
        
        var prompt = "Generate a realistic paper receipt from \(storeName). "
        
        if !receiptData.items.isEmpty {
            prompt += "Items purchased: "
            for item in receiptData.items {
                let formattedPrice = formatter.format(item.price)
                if item.quantity > 1 {
                    prompt += "\(item.name) x\(item.quantity) at \(formattedPrice) each, "
                } else {
                    prompt += "\(item.name) \(formattedPrice), "
                }
            }
            
            if let total = receiptData.totalAmount {
                let formattedTotal = formatter.format(total)
                prompt += "Total: \(formattedTotal). "
            }
        }
        
        prompt += "Make it look like a real thermal receipt with store header, itemized list, tax information, and total. Include realistic details like date, time, cashier name, and receipt number. Make the paper texture visible and slightly worn."
        
        return prompt
    }
    
    func generateRandomReceiptPrompt() -> String {
        let storeNames = ["Coffee Corner", "Quick Mart", "Fresh Grocers", "Tech Store", "Fashion Outlet"]
        let items = [
            ("Coffee", 4.99), ("Sandwich", 8.50), ("Water", 2.00), ("Chips", 3.25),
            ("Magazine", 5.99), ("Gum", 1.50), ("Banana", 1.25), ("Milk", 3.89)
        ]
        
        let randomStore = storeNames.randomElement()!
        let numberOfItems = Int.random(in: 1...4)
        let selectedItems = items.shuffled().prefix(numberOfItems)
        
        let receiptData = ReceiptData(storeName: randomStore, currency: "USD")
        receiptData.items = selectedItems.map { item in
            ReceiptItem(name: item.0, price: Decimal(item.1), quantity: 1)
        }
        receiptData.calculateTotal()
        
        return generatePrompt(from: receiptData)
    }
}

// MARK: - Data Transfer Objects

private struct DALLERequest: Codable {
    let prompt: String
    let n: Int
    let size: String
    let response_format: String
}

private struct DALLEResponse: Codable {
    let data: [DALLEImageData]
}

private struct DALLEImageData: Codable {
    let b64_json: String
}