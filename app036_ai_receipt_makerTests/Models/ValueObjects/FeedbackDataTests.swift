import Testing
@testable import app036_ai_receipt_maker

struct FeedbackDataTests {
    
    @Test func toDictionaryWithAllFields() {
        let feedback = FeedbackData(
            problemType: .inappropriateImage,
            description: "テスト説明",
            email: "test@example.com",
            severity: .high,
            receiptId: "receipt_123"
        )
        
        let dict = feedback.toDictionary()
        
        #expect(dict["problemType"] as? String == "不適切な画像")
        #expect(dict["description"] as? String == "テスト説明")
        #expect(dict["email"] as? String == "test@example.com")
        #expect(dict["severity"] as? String == "high")
        #expect(dict["receiptId"] as? String == "receipt_123")
        #expect(dict["appVersion"] != nil)
        #expect(dict["deviceInfo"] != nil)
    }
    
    @Test func toDictionaryWithoutOptionalFields() {
        let feedback = FeedbackData(
            problemType: .technicalIssue,
            description: "テスト説明",
            email: nil,
            severity: .medium,
            receiptId: nil
        )
        
        let dict = feedback.toDictionary()
        
        #expect(dict["problemType"] as? String == "技術的問題")
        #expect(dict["description"] as? String == "テスト説明")
        #expect(dict["email"] == nil)
        #expect(dict["receiptId"] == nil)
        #expect(dict["severity"] as? String == "medium")
    }
    
    @Test func toDictionaryWithEmptyOptionalFields() {
        let feedback = FeedbackData(
            problemType: .other,
            description: "テスト説明",
            email: "",
            severity: .low,
            receiptId: ""
        )
        
        let dict = feedback.toDictionary()
        
        #expect(dict["email"] == nil)
        #expect(dict["receiptId"] == nil)
    }
    
    @Test func problemTypeLocalizedTitles() {
        #expect(FeedbackData.ProblemType.inappropriateImage.localizedTitle == "不適切な画像")
        #expect(FeedbackData.ProblemType.technicalIssue.localizedTitle == "技術的問題")
        #expect(FeedbackData.ProblemType.featureRequest.localizedTitle == "機能要望")
        #expect(FeedbackData.ProblemType.other.localizedTitle == "その他")
    }
    
    @Test func severityLocalizedTitles() {
        #expect(FeedbackData.Severity.low.localizedTitle == "低")
        #expect(FeedbackData.Severity.medium.localizedTitle == "中")
        #expect(FeedbackData.Severity.high.localizedTitle == "高")
    }
    
    @Test func appVersionIsNotEmpty() {
        let feedback = FeedbackData(
            problemType: .other,
            description: "テスト",
            email: nil,
            severity: .medium,
            receiptId: nil
        )
        
        #expect(!feedback.appVersion.isEmpty)
    }
    
    @Test func deviceInfoContainsSystemInfo() {
        let feedback = FeedbackData(
            problemType: .other,
            description: "テスト",
            email: nil,
            severity: .medium,
            receiptId: nil
        )
        
        #expect(feedback.deviceInfo.contains("iOS") || feedback.deviceInfo.contains("macOS"))
    }
}