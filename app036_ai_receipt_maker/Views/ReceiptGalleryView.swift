//
//  ReceiptGalleryView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData

struct ReceiptGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var mainViewModel: MainViewModel
    @Query private var receipts: [ReceiptData]
    
    var body: some View {
        NavigationView {
            if receipts.isEmpty {
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
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(receipts) { receipt in
                            ReceiptCardView(receipt: receipt)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Gallery")
                .onAppear {
                    Task {
                        await mainViewModel.loadReceipts()
                    }
                }
            }
        }
    }
}

#Preview {
    ReceiptGalleryView()
        .modelContainer(for: [ReceiptData.self, UsageTracker.self])
}