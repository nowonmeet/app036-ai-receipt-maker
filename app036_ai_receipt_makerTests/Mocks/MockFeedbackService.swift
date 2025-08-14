import Foundation
@testable import app036_ai_receipt_maker

final class MockFeedbackService: FeedbackServiceProtocol {
    var submitFeedbackCalled = false
    var submittedFeedback: FeedbackData?
    var shouldThrowError = false
    var errorToThrow: Error = FeedbackError.submissionFailed
    var delay: TimeInterval = 0
    
    func submitFeedback(_ feedback: FeedbackData) async throws {
        submitFeedbackCalled = true
        submittedFeedback = feedback
        
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw errorToThrow
        }
    }
    
    func reset() {
        submitFeedbackCalled = false
        submittedFeedback = nil
        shouldThrowError = false
        errorToThrow = FeedbackError.submissionFailed
        delay = 0
    }
}