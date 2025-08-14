import Foundation
import UIKit

struct FeedbackData {
    let problemType: ProblemType
    let description: String
    let email: String?
    let severity: Severity
    let receiptId: String?
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var deviceInfo: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion), \(UIDevice.current.model)"
    }
}

extension FeedbackData {
    enum ProblemType: String, CaseIterable {
        case inappropriateImage = "Inappropriate Image"
        case technicalIssue = "Technical Issue"
        case featureRequest = "Feature Request"
        case other = "Other"
        
        var localizedTitle: String {
            self.rawValue
        }
    }
    
    enum Severity: String, CaseIterable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        
        var localizedTitle: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
    }
}

extension FeedbackData {
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "problemType": problemType.rawValue,
            "description": description,
            "appVersion": appVersion,
            "deviceInfo": deviceInfo,
            "severity": severity.rawValue
        ]
        
        if let email = email, !email.isEmpty {
            dict["email"] = email
        }
        
        if let receiptId = receiptId, !receiptId.isEmpty {
            dict["receiptId"] = receiptId
        }
        
        return dict
    }
}