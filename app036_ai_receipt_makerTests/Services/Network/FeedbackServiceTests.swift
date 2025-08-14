import Testing
import Foundation
@testable import app036_ai_receipt_maker

struct FeedbackServiceTests {
    
    @Test func initWithDefaultValues() {
        let service = FeedbackService()
        
        #expect(service != nil)
    }
    
    @Test func submitFeedbackThrowsErrorWhenEndpointNotConfigured() async {
        let service = FeedbackService(gasEndpointURL: "")
        let feedback = createTestFeedback()
        
        await #expect(throws: FeedbackError.endpointNotConfigured) {
            try await service.submitFeedback(feedback)
        }
    }
    
    @Test func submitFeedbackThrowsErrorWhenInvalidEndpoint() async {
        let service = FeedbackService(gasEndpointURL: "invalid-url")
        let feedback = createTestFeedback()
        
        await #expect(throws: FeedbackError.invalidEndpoint) {
            try await service.submitFeedback(feedback)
        }
    }
    
    @Test func submitFeedbackSuccessWithValidResponse() async throws {
        let mockURLSession = MockURLSession()
        mockURLSession.mockData = """
        {"status": "success", "message": "フィードバックを受信しました"}
        """.data(using: .utf8)!
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let service = FeedbackService(
            gasEndpointURL: "https://example.com/feedback",
            urlSession: mockURLSession
        )
        let feedback = createTestFeedback()
        
        try await service.submitFeedback(feedback)
        
        #expect(mockURLSession.requestCalled)
    }
    
    @Test func submitFeedbackThrowsServerErrorWhen500() async {
        let mockURLSession = MockURLSession()
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let service = FeedbackService(
            gasEndpointURL: "https://example.com/feedback",
            urlSession: mockURLSession
        )
        let feedback = createTestFeedback()
        
        await #expect(throws: FeedbackError.serverError(500)) {
            try await service.submitFeedback(feedback)
        }
    }
    
    @Test func submitFeedbackThrowsSubmissionFailedWhenErrorResponse() async {
        let mockURLSession = MockURLSession()
        mockURLSession.mockData = """
        {"status": "error", "message": "処理に失敗しました"}
        """.data(using: .utf8)!
        mockURLSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let service = FeedbackService(
            gasEndpointURL: "https://example.com/feedback",
            urlSession: mockURLSession
        )
        let feedback = createTestFeedback()
        
        await #expect(throws: FeedbackError.submissionFailed) {
            try await service.submitFeedback(feedback)
        }
    }
    
    private func createTestFeedback() -> FeedbackData {
        FeedbackData(
            problemType: .inappropriateImage,
            description: "テスト説明",
            email: "test@example.com",
            severity: .medium,
            receiptId: "test_receipt"
        )
    }
}

private class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    var requestCalled = false
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        requestCalled = true
        
        if let error = mockError {
            throw error
        }
        
        let data = mockData ?? Data()
        let response = mockResponse ?? HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data, response)
    }
}

