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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if receipt.isGenerated && !receipt.imageFileName.isEmpty {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(ProgressView())
                        }
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Receipt Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Group {
                            DetailRow(title: "Store", value: receipt.storeName ?? "Unknown")
                            DetailRow(title: "Date", value: receipt.createdAt.formatted(date: .abbreviated, time: .shortened))
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
                        Button("Save to Photos") {
                            saveToPhotos()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
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
    
    private func saveToPhotos() {
        guard let imageURL = imageURL,
              let imageData = try? Data(contentsOf: imageURL),
              let uiImage = UIImage(data: imageData) else {
            saveMessage = "Failed to load image"
            showingSaveAlert = true
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                    saveMessage = "Image saved to Photos"
                    showingSaveAlert = true
                case .denied, .restricted:
                    saveMessage = "Photo Library access denied"
                    showingSaveAlert = true
                case .notDetermined:
                    saveMessage = "Photo Library access not determined"
                    showingSaveAlert = true
                @unknown default:
                    saveMessage = "Unknown Photo Library status"
                    showingSaveAlert = true
                }
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
        let r = ReceiptData(storeName: "Coffee Shop", currency: "USD")
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