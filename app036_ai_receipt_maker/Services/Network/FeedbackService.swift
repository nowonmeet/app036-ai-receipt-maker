import Foundation

final class FeedbackService: FeedbackServiceProtocol {
    private let gasEndpointURL: String
    private let urlSession: URLSessionProtocol
    
    init(gasEndpointURL: String = "", urlSession: URLSessionProtocol = URLSession.shared) {
        self.gasEndpointURL = gasEndpointURL
        self.urlSession = urlSession
    }
    
    func submitFeedback(_ feedback: FeedbackData) async throws {
        print("🔍 [FeedbackService] submitFeedback called")
        print("📍 [FeedbackService] gasEndpointURL: \(gasEndpointURL)")
        
        guard !gasEndpointURL.isEmpty else {
            print("❌ [FeedbackService] エンドポイントが設定されていません")
            throw FeedbackError.endpointNotConfigured
        }
        
        guard let url = URL(string: gasEndpointURL) else {
            print("❌ [FeedbackService] 無効なエンドポイントURL: \(gasEndpointURL)")
            throw FeedbackError.invalidEndpoint
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            let feedbackDict = feedback.toDictionary()
            print("📝 [FeedbackService] フィードバックデータ: \(feedbackDict)")
            
            let jsonData = try JSONSerialization.data(withJSONObject: feedbackDict)
            request.httpBody = jsonData
            
            print("🚀 [FeedbackService] リクエスト送信開始")
            let (data, response) = try await urlSession.data(for: request)
            print("✅ [FeedbackService] レスポンス受信完了")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [FeedbackService] 無効なレスポンスタイプ")
                throw FeedbackError.invalidResponse
            }
            
            print("📊 [FeedbackService] ステータスコード: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ [FeedbackService] サーバーエラー: \(httpResponse.statusCode)")
                throw FeedbackError.serverError(httpResponse.statusCode)
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 [FeedbackService] レスポンス内容: \(responseString)")
            }
            
            if let responseData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = responseData["status"] as? String,
               status == "success" {
                print("🎉 [FeedbackService] フィードバック送信成功")
                return
            } else {
                print("❌ [FeedbackService] フィードバック送信失敗")
                throw FeedbackError.submissionFailed
            }
            
        } catch let error as FeedbackError {
            print("❌ [FeedbackService] FeedbackError: \(error)")
            throw error
        } catch {
            print("❌ [FeedbackService] NetworkError: \(error)")
            throw FeedbackError.networkError(error)
        }
    }
}

enum FeedbackError: LocalizedError, Equatable {
    case endpointNotConfigured
    case invalidEndpoint
    case invalidResponse
    case serverError(Int)
    case submissionFailed
    case networkError(Error)
    
    static func == (lhs: FeedbackError, rhs: FeedbackError) -> Bool {
        switch (lhs, rhs) {
        case (.endpointNotConfigured, .endpointNotConfigured),
             (.invalidEndpoint, .invalidEndpoint),
             (.invalidResponse, .invalidResponse),
             (.submissionFailed, .submissionFailed):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .endpointNotConfigured:
            return "フィードバック送信先が設定されていません"
        case .invalidEndpoint:
            return "無効なエンドポイントURLです"
        case .invalidResponse:
            return "サーバーからの応答が無効です"
        case .serverError(let statusCode):
            return "サーバーエラーが発生しました（コード: \(statusCode)）"
        case .submissionFailed:
            return "フィードバックの送信に失敗しました"
        case .networkError(let underlyingError):
            return "ネットワークエラー: \(underlyingError.localizedDescription)"
        }
    }
}