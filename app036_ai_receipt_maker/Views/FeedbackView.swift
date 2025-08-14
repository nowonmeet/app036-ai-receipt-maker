import SwiftUI

struct FeedbackView: View {
    @StateObject private var viewModel: FeedbackFormViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(feedbackService: FeedbackServiceProtocol, receiptId: String? = nil) {
        self._viewModel = StateObject(wrappedValue: FeedbackFormViewModel(
            feedbackService: feedbackService,
            receiptId: receiptId
        ))
    }
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.submissionState {
                case .idle, .submitting, .error:
                    feedbackForm
                case .success:
                    successView
                }
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if viewModel.submissionState == .idle || viewModel.submissionState == .error {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Submit") {
                            Task {
                                await viewModel.submitFeedback()
                            }
                        }
                        .disabled(!viewModel.canSubmit)
                    }
                }
            }
        }
    }
    
    private var feedbackForm: some View {
        Form {
            Section("Issue Type") {
                Picker("Issue Type", selection: $viewModel.problemType) {
                    ForEach(FeedbackData.ProblemType.allCases, id: \.self) { type in
                        Text(type.localizedTitle).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section("Description") {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
                    .overlay(
                        Group {
                            if viewModel.description.isEmpty {
                                Text("Please describe the issue in detail...")
                                    .foregroundColor(.secondary)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
            }
            
            Section("Severity") {
                Picker("Severity", selection: $viewModel.severity) {
                    ForEach(FeedbackData.Severity.allCases, id: \.self) { severity in
                        Text(severity.localizedTitle).tag(severity)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                TextField("Contact email (optional)", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                
                if !viewModel.isEmailValid {
                    Text("Please enter a valid email address")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            } header: {
                Text("Contact Information")
            } footer: {
                Text("Only required if you need a response")
            }
            
            if viewModel.submissionState == .error {
                Section {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                } header: {
                    Text("Error")
                }
            }
            
            if viewModel.isSubmitting {
                Section {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Submitting...")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                Text("Feedback Submitted")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Thank you for your valuable feedback.\nWe will review it for improvements.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    FeedbackView(feedbackService: MockFeedbackService())
}

private class MockFeedbackService: FeedbackServiceProtocol {
    func submitFeedback(_ feedback: FeedbackData) async throws {
        try await Task.sleep(nanoseconds: 1_000_000_000)
    }
}