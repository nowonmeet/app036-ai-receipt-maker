//
//  UsageStatusView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/13.
//

import SwiftUI
import SwiftData

struct UsageStatusView: View {
    @Query private var usageTrackers: [UsageTracker]
    private let isPremium: Bool
    
    init(isPremium: Bool) {
        self.isPremium = isPremium
    }
    
    private var currentUsage: UsageTracker? {
        if isPremium {
            let today = Calendar.current.startOfDay(for: Date())
            return usageTrackers.first { tracker in
                tracker.date == today && tracker.isPremiumUser == true
            }
        } else {
            return usageTrackers.first { tracker in
                tracker.isPremiumUser == false
            }
        }
    }
    
    private var remainingGenerations: Int {
        guard let usage = currentUsage else {
            return isPremium ? 10 : 2
        }
        return usage.remainingGenerations
    }
    
    private var usedGenerations: Int {
        guard let usage = currentUsage else {
            return 0
        }
        return isPremium ? usage.generationCount : usage.lifetimeUsageCount
    }
    
    private var totalLimit: Int {
        return isPremium ? 10 : 2
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: isPremium ? "crown.fill" : "sparkles")
                    .foregroundColor(isPremium ? .yellow : .blue)
                
                Text(isPremium ? "Premium User" : "Free Trial")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack {
                Text("Generations:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if isPremium {
                    Text("\(remainingGenerations) remaining today")
                        .font(.caption)
                        .fontWeight(.medium)
                } else {
                    Text("\(remainingGenerations) remaining (lifetime)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(remainingGenerations == 0 ? .red : .primary)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(width: progressWidth(in: geometry.size.width), height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(usedGenerations)/\(totalLimit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !isPremium && remainingGenerations == 0 {
                    Text("Trial ended")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var progressColor: Color {
        if remainingGenerations == 0 {
            return .red
        } else if Double(usedGenerations) / Double(totalLimit) > 0.7 {
            return .orange
        } else {
            return isPremium ? .yellow : .blue
        }
    }
    
    private func progressWidth(in totalWidth: CGFloat) -> CGFloat {
        let progress = CGFloat(usedGenerations) / CGFloat(totalLimit)
        return totalWidth * min(progress, 1.0)
    }
}

#Preview {
    VStack(spacing: 20) {
        UsageStatusView(isPremium: false)
            .padding()
        
        UsageStatusView(isPremium: true)
            .padding()
    }
    .modelContainer(for: UsageTracker.self)
}