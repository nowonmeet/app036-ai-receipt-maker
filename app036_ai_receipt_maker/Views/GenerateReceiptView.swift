//
//  GenerateReceiptView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI

struct GenerateReceiptView: View {
    @StateObject private var formViewModel = ReceiptFormViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("AI Receipt Maker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                if formViewModel.useRandomData {
                    VStack(spacing: 16) {
                        Text("Generate Random Receipt")
                            .font(.headline)
                        
                        Text("Create a receipt with random store and items")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Generate Random Receipt") {
                            // TODO: Implement generate random receipt
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    ReceiptFormView(viewModel: formViewModel)
                }
                
                Toggle("Use Random Data", isOn: $formViewModel.useRandomData)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Generate")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    GenerateReceiptView()
}