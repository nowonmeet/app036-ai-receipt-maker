//
//  ReceiptDetailView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI
import SwiftData
import Photos

struct ReceiptDetailView: View {
    let receipt: ReceiptData
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var mainViewModel: MainViewModel
    @State private var showingSaveAlert = false
    @State private var saveMessage = ""
    @State private var isSaving = false
    @State private var isPremium = UniversalPaywallManager.shared.isPremiumActive
    
    private let photoSaveService: PhotoSaveServiceProtocol
    
    init(receipt: ReceiptData, photoSaveService: PhotoSaveServiceProtocol = PhotoSaveService()) {
        self.receipt = receipt
        self.photoSaveService = photoSaveService
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if receipt.isGenerated && !receipt.imageFileName.isEmpty {
                        WatermarkedImageView(
                            imageURL: imageURL,
                            showWatermark: !isPremium
                        )
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Receipt Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Group {
                            DetailRow(title: "Store", value: receipt.storeName ?? "Unknown")
                            
                            if let address = receipt.address, !address.isEmpty {
                                DetailRow(title: "Address", value: address)
                            }
                            
                            if let phoneNumber = receipt.phoneNumber, !phoneNumber.isEmpty {
                                DetailRow(title: "Phone", value: phoneNumber)
                            }
                            
                            if let receiptDate = receipt.receiptDate {
                                DetailRow(title: "Receipt Date", value: receiptDate.formatted(date: .abbreviated, time: .shortened))
                            }
                            
                            DetailRow(title: "Created", value: receipt.createdAt.formatted(date: .abbreviated, time: .shortened))
                            DetailRow(title: "Currency", value: receipt.currency)
                        }
                        
                        if !receipt.items.isEmpty {
                            Text("Items")
                                .font(.headline)
                                .padding(.top)
                            
                            ForEach(receipt.items) { item in
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text("×\(item.quantity)")
                                    Text(CurrencyFormatter(locale: .current).format(item.price))
                                        .fontWeight(.semibold)
                                }
                                .padding(.vertical, 4)
                            }
                            
                            Divider()
                            
                            if let total = receipt.totalAmount {
                                HStack {
                                    Text("Total")
                                        .font(.headline)
                                    Spacer()
                                    Text(CurrencyFormatter(locale: .current).format(total))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    if receipt.isGenerated {
                        Button(action: {
                            Task {
                                await saveToPhotos()
                            }
                        }) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("Saving...")
                                } else {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Save to Photos")
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                        .disabled(isSaving)
                    }
                }
                .padding()
            }
            .navigationTitle("Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Photo Library", isPresented: $showingSaveAlert) {
                Button("OK") { }
            } message: {
                Text(saveMessage)
            }
        }
    }
    
    private var imageURL: URL? {
        guard !receipt.imageFileName.isEmpty else { return nil }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent(receipt.imageFileName)
    }
    
    private func saveToPhotos() async {
        guard let imageURL = imageURL else {
            await MainActor.run {
                saveMessage = "Failed to load image"
                showingSaveAlert = true
            }
            return
        }
        
        await MainActor.run {
            isSaving = true
        }
        
        do {
            try await photoSaveService.saveImageToPhotos(imageURL: imageURL, isPremiumUser: isPremium)
            
            await MainActor.run {
                if isPremium {
                    saveMessage = "Image saved to Photos"
                } else {
                    saveMessage = "Image saved to Photos with watermark"
                }
                showingSaveAlert = true
                isSaving = false
            }
        } catch {
            await MainActor.run {
                saveMessage = "Failed to save image: \(error.localizedDescription)"
                showingSaveAlert = true
                isSaving = false
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    @Previewable @State var receipt: ReceiptData = {
        let r = ReceiptData(
            storeName: "Coffee Shop", 
            address: "123 Main St, City, State 12345",
            phoneNumber: "(555) 123-4567",
            receiptDate: Calendar.current.date(byAdding: .hour, value: -2, to: Date()),
            currency: "USD"
        )
        r.items = [
            ReceiptItem(name: "Coffee", price: 4.99, quantity: 1),
            ReceiptItem(name: "Muffin", price: 3.50, quantity: 2)
        ]
        r.calculateTotal()
        r.markAsGenerated(fileName: "test.png")
        return r
    }()
    
    ReceiptDetailView(receipt: receipt)
}