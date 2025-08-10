//
//  ReceiptCardView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData

struct ReceiptCardView: View {
    let receipt: ReceiptData
    @EnvironmentObject private var mainViewModel: MainViewModel
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if receipt.isGenerated && !receipt.imageFileName.isEmpty {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                        )
                }
                .frame(height: 120)
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .overlay(
                        Text("No Image")
                            .foregroundColor(.secondary)
                    )
                    .cornerRadius(8)
            }
            
            Text(receipt.storeName ?? "Unknown Store")
                .font(.headline)
                .lineLimit(1)
            
            if let total = receipt.totalAmount {
                Text(CurrencyFormatter(locale: .current).format(total))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(receipt.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            ReceiptDetailView(receipt: receipt)
        }
    }
    
    private var imageURL: URL? {
        guard !receipt.imageFileName.isEmpty else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent(receipt.imageFileName)
    }
}

#Preview {
    @Previewable @State var receipt: ReceiptData = {
        let r = ReceiptData(storeName: "Coffee Shop", currency: "USD")
        r.items = [
            ReceiptItem(name: "Coffee", price: 4.99, quantity: 1),
            ReceiptItem(name: "Muffin", price: 3.50, quantity: 2)
        ]
        r.calculateTotal()
        return r
    }()
    
    ReceiptCardView(receipt: receipt)
        .padding()
}