import Foundation

@MainActor
final class FeedbackFormViewModel: ObservableObject {
    @Published var problemType: FeedbackData.ProblemType = .inappropriateImage
    @Published var description: String = ""
    @Published var email: String = ""
    @Published var severity: FeedbackData.Severity = .medium
    @Published var isSubmitting: Bool = false
    @Published var submissionState: SubmissionState = .idle
    @Published var errorMessage: String = ""
    
    private let feedbackService: FeedbackServiceProtocol
    private let receiptId: String?
    
    init(feedbackService: FeedbackServiceProtocol, receiptId: String? = nil) {
        self.feedbackService = feedbackService
        self.receiptId = receiptId
    }
    
    var canSubmit: Bool {
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }
    
    var isEmailValid: Bool {
        email.isEmpty || email.contains("@")
    }
    
    func submitFeedback() async {
        print("🚀 [FeedbackFormViewModel] submitFeedback called")
        print("📊 [FeedbackFormViewModel] canSubmit: \(canSubmit)")
        
        guard canSubmit else { 
            print("❌ [FeedbackFormViewModel] canSubmit is false")
            return 
        }
        
        isSubmitting = true
        submissionState = .submitting
        errorMessage = ""
        
        let feedbackData = FeedbackData(
            problemType: problemType,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.isEmpty ? nil : email,
            severity: severity,
            receiptId: receiptId
        )
        
        do {
            print("📤 [FeedbackFormViewModel] フィードバックサービス呼び出し開始")
            try await feedbackService.submitFeedback(feedbackData)
            print("✅ [FeedbackFormViewModel] フィードバック送信成功")
            submissionState = .success
            clearForm()
        } catch {
            print("❌ [FeedbackFormViewModel] フィードバック送信エラー: \(error)")
            submissionState = .error
            errorMessage = error.localizedDescription
        }
        
        isSubmitting = false
        print("🏁 [FeedbackFormViewModel] submitFeedback completed")
    }
    
    func clearForm() {
        problemType = .inappropriateImage
        description = ""
        email = ""
        severity = .medium
        errorMessage = ""
    }
    
    func resetSubmissionState() {
        submissionState = .idle
        errorMessage = ""
    }
}

extension FeedbackFormViewModel {
    enum SubmissionState {
        case idle
        case submitting
        case success
        case error
    }
}