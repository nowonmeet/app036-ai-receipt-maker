import Foundation

protocol FeedbackServiceProtocol {
    func submitFeedback(_ feedback: FeedbackData) async throws
}