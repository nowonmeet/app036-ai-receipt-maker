import Testing
@testable import app036_ai_receipt_maker

@MainActor
struct FeedbackFormViewModelTests {
    
    @Test func initialState() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        #expect(viewModel.problemType == .inappropriateImage)
        #expect(viewModel.description.isEmpty)
        #expect(viewModel.email.isEmpty)
        #expect(viewModel.severity == .medium)
        #expect(!viewModel.isSubmitting)
        #expect(viewModel.submissionState == .idle)
        #expect(viewModel.errorMessage.isEmpty)
    }
    
    @Test func canSubmitWhenDescriptionIsNotEmpty() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.description = "テスト説明"
        
        #expect(viewModel.canSubmit)
    }
    
    @Test func cannotSubmitWhenDescriptionIsEmpty() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.description = ""
        
        #expect(!viewModel.canSubmit)
    }
    
    @Test func cannotSubmitWhenDescriptionIsOnlyWhitespace() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.description = "   \n  "
        
        #expect(!viewModel.canSubmit)
    }
    
    @Test func cannotSubmitWhenSubmitting() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.description = "テスト説明"
        viewModel.isSubmitting = true
        
        #expect(!viewModel.canSubmit)
    }
    
    @Test func emailValidationWhenEmpty() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.email = ""
        
        #expect(viewModel.isEmailValid)
    }
    
    @Test func emailValidationWhenValid() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.email = "test@example.com"
        
        #expect(viewModel.isEmailValid)
    }
    
    @Test func emailValidationWhenInvalid() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.email = "invalid-email"
        
        #expect(!viewModel.isEmailValid)
    }
    
    @Test func submitFeedbackSuccess() async {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.description = "テスト説明"
        viewModel.email = "test@example.com"
        
        await viewModel.submitFeedback()
        
        #expect(mockService.submitFeedbackCalled)
        #expect(mockService.submittedFeedback?.description == "テスト説明")
        #expect(mockService.submittedFeedback?.email == "test@example.com")
        #expect(viewModel.submissionState == .success)
        #expect(!viewModel.isSubmitting)
        #expect(viewModel.description.isEmpty)
    }
    
    @Test func submitFeedbackError() async {
        let mockService = MockFeedbackService()
        mockService.shouldThrowError = true
        mockService.errorToThrow = FeedbackError.networkError(URLError(.notConnectedToInternet))
        
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        viewModel.description = "テスト説明"
        
        await viewModel.submitFeedback()
        
        #expect(mockService.submitFeedbackCalled)
        #expect(viewModel.submissionState == .error)
        #expect(!viewModel.errorMessage.isEmpty)
        #expect(!viewModel.isSubmitting)
    }
    
    @Test func submitFeedbackWithReceiptId() async {
        let mockService = MockFeedbackService()
        let receiptId = "test_receipt_123"
        let viewModel = FeedbackFormViewModel(feedbackService: mockService, receiptId: receiptId)
        
        viewModel.description = "テスト説明"
        
        await viewModel.submitFeedback()
        
        #expect(mockService.submittedFeedback?.receiptId == receiptId)
    }
    
    @Test func clearForm() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.problemType = .technicalIssue
        viewModel.description = "テスト説明"
        viewModel.email = "test@example.com"
        viewModel.severity = .high
        viewModel.errorMessage = "エラー"
        
        viewModel.clearForm()
        
        #expect(viewModel.problemType == .inappropriateImage)
        #expect(viewModel.description.isEmpty)
        #expect(viewModel.email.isEmpty)
        #expect(viewModel.severity == .medium)
        #expect(viewModel.errorMessage.isEmpty)
    }
    
    @Test func resetSubmissionState() {
        let mockService = MockFeedbackService()
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        
        viewModel.submissionState = .error
        viewModel.errorMessage = "エラー"
        
        viewModel.resetSubmissionState()
        
        #expect(viewModel.submissionState == .idle)
        #expect(viewModel.errorMessage.isEmpty)
    }
    
    @Test func submittingStateTransition() async {
        let mockService = MockFeedbackService()
        mockService.delay = 0.1
        
        let viewModel = FeedbackFormViewModel(feedbackService: mockService)
        viewModel.description = "テスト説明"
        
        let task = Task {
            await viewModel.submitFeedback()
        }
        
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(viewModel.isSubmitting)
        #expect(viewModel.submissionState == .submitting)
        
        await task.value
        
        #expect(!viewModel.isSubmitting)
        #expect(viewModel.submissionState == .success)
    }
}