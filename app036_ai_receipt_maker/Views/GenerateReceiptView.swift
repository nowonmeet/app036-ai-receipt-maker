//
//  GenerateReceiptView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData

struct GenerateReceiptView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var mainViewModel: MainViewModel
    @StateObject private var formViewModel = ReceiptFormViewModel()
    @State private var showingError = false
    
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
                            Task {
                                await mainViewModel.generateRandomReceipt()
                            }
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
                
                if mainViewModel.isGenerating {
                    ProgressView("Generating...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Generate")
            .navigationBarTitleDisplayMode(.inline)
            .disabled(mainViewModel.isGenerating)
            .alert("Error", isPresented: $showingError) {
                Button("OK") {
                    mainViewModel.clearError()
                }
            } message: {
                Text(mainViewModel.errorMessage ?? "An error occurred")
            }
            .onReceive(mainViewModel.$errorMessage) { errorMessage in
                showingError = errorMessage != nil
            }
        }
    }
}

#Preview {
    GenerateReceiptView()
        .modelContainer(for: [ReceiptData.self, UsageTracker.self])
}