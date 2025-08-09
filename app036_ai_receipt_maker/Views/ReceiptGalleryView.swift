//
//  ReceiptGalleryView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI

struct ReceiptGalleryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Receipts")
                    .font(.title)
                    .padding()
                
                Text("Generated receipts will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Gallery")
        }
    }
}

#Preview {
    ReceiptGalleryView()
}