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
    
    init() {
        self.apiKey = APIConfiguration.openAIAPIKey
    }
    
    func generateReceiptImage(prompt: String) async throws -> Data {
        guard !prompt.isEmpty else {
            throw AppError.validationError("Prompt cannot be empty")
        }
        
        guard !apiKey.isEmpty else {
            throw AppError.apiError("API key is required")
        }
        
        let requestBody = GPTImageRequest(
            model: "gpt-image-1",
            prompt: prompt,
            n: 1,
            quality: "medium",
            size: "1024x1024"
        )
        
        guard let url = URL(string: baseURL) else {
            throw AppError.networkError("Invalid API URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = requestHeaders
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            // リクエスト内容をログ出力
            print("🚀 API Request URL: \(baseURL)")
            print("🚀 API Request Model: \(requestBody.model)")
            print("🚀 API Request Body: \(String(data: request.httpBody!, encoding: .utf8) ?? "Unable to encode")")
        } catch {
            throw AppError.networkError("Failed to encode request: \(error.localizedDescription)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.networkError("Invalid response type")
            }
            
            guard httpResponse.statusCode == 200 else {
                // エラーレスポンスの内容をログ出力
                let errorResponse = String(data: data, encoding: .utf8) ?? "Unable to decode error response"
                print("❌ API Error Response: \(errorResponse)")
                print("❌ Status Code: \(httpResponse.statusCode)")
                print("❌ Request URL: \(request.url?.absoluteString ?? "Unknown")")
                print("❌ Request Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "Unknown")")
                throw AppError.apiError("API request failed with status code: \(httpResponse.statusCode)")
            }
            
            let gptImageResponse = try JSONDecoder().decode(GPTImageResponse.self, from: data)
            
            guard let firstImage = gptImageResponse.data.first,
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
        
        var prompt = "Generate a realistic paper receipt from \(storeName)"
        
        // 住所の追加
        if let address = receiptData.address, !address.isEmpty {
            prompt += " located at \(address)"
        }
        
        // 電話番号の追加  
        if let phoneNumber = receiptData.phoneNumber, !phoneNumber.isEmpty {
            prompt += " (Phone: \(phoneNumber))"
        }
        
        prompt += ". "
        
        // アイテムの詳細
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
        } else {
            // アイテムが指定されていない場合はAIに委ねる
            prompt += "Include appropriate items and prices for this type of store. "
        }
        
        // 住所や電話番号が未指定の場合の指示
        if receiptData.address?.isEmpty != false {
            prompt += "Include a realistic address for the store. "
        }
        if receiptData.phoneNumber?.isEmpty != false {
            prompt += "Include a realistic phone number for the store. "
        }
        
        prompt += "Make it look like a real thermal receipt with complete store header including name"
        
        if receiptData.address?.isEmpty != false || receiptData.phoneNumber?.isEmpty != false {
            prompt += ", address, and phone number"
        }
        
        prompt += ", itemized list with realistic items if not specified, tax information, and total. Include realistic details like date, time, cashier name, and receipt number. Make sure the texture of the paper is visible, and add a crease from folding it in half lengthwise and some wrinkles like you would get from putting it in a pocket."
        
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

private struct GPTImageRequest: Codable {
    let model: String
    let prompt: String
    let n: Int
    let quality: String
    let size: String
}

private struct GPTImageResponse: Codable {
    let data: [GPTImageData]
}

private struct GPTImageData: Codable {
    let b64_json: String
}