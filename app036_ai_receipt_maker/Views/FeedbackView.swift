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
            .navigationTitle("フィードバック")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                if viewModel.submissionState == .idle || viewModel.submissionState == .error {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("送信") {
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
            Section("問題の種類") {
                Picker("問題の種類", selection: $viewModel.problemType) {
                    ForEach(FeedbackData.ProblemType.allCases, id: \.self) { type in
                        Text(type.localizedTitle).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section("詳細説明") {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
                    .overlay(
                        Group {
                            if viewModel.description.isEmpty {
                                Text("問題の詳細を入力してください...")
                                    .foregroundColor(.secondary)
                                    .allowsHitTesting(false)
                            }
                        },
                        alignment: .topLeading
                    )
            }
            
            Section("重要度") {
                Picker("重要度", selection: $viewModel.severity) {
                    ForEach(FeedbackData.Severity.allCases, id: \.self) { severity in
                        Text(severity.localizedTitle).tag(severity)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                TextField("連絡先メールアドレス（任意）", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                
                if !viewModel.isEmailValid {
                    Text("有効なメールアドレスを入力してください")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            } header: {
                Text("連絡先（任意）")
            } footer: {
                Text("返信が必要な場合のみ入力してください")
            }
            
            if viewModel.submissionState == .error {
                Section {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                } header: {
                    Text("エラー")
                }
            }
            
            if viewModel.isSubmitting {
                Section {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("送信中...")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                Text("フィードバックを送信しました")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("貴重なご意見をありがとうございます。\n改善に向けて検討させていただきます。")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("閉じる") {
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