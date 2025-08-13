//
//  WatermarkedImageView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/13.
//

import SwiftUI

struct WatermarkedImageView: View {
    let imageURL: URL?
    let showWatermark: Bool
    
    init(imageURL: URL?, showWatermark: Bool = true) {
        self.imageURL = imageURL
        self.showWatermark = showWatermark
    }
    
    var body: some View {
        ZStack {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    )
            }
            
            if showWatermark {
                WatermarkOverlayView()
            }
        }
    }
}

struct WatermarkOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Text("AI RECEIPT MAKER")
                    .font(.system(size: calculateFontSize(for: geometry.size), weight: .bold, design: .default))
                    .foregroundColor(.white.opacity(0.6))
                    .shadow(color: .black.opacity(0.8), radius: 2, x: 1, y: 1)
                    .multilineTextAlignment(.center)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
    
    private func calculateFontSize(for size: CGSize) -> CGFloat {
        let minDimension = min(size.width, size.height)
        return max(16, minDimension * 0.08)
    }
}

#Preview("With Watermark") {
    WatermarkedImageView(
        imageURL: nil,
        showWatermark: true
    )
    .frame(width: 300, height: 400)
    .border(Color.gray)
}

#Preview("Without Watermark") {
    WatermarkedImageView(
        imageURL: nil,
        showWatermark: false
    )
    .frame(width: 300, height: 400)
    .border(Color.gray)
}