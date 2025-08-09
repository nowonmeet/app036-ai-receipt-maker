//
//  ReceiptFormView.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import SwiftUI

struct ReceiptFormView: View {
    @ObservedObject var viewModel: ReceiptFormViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Custom Receipt")
                .font(.headline)
            
            TextField("Store Name", text: $viewModel.storeName)
                .textFieldStyle(.roundedBorder)
            
            Text("Items")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ForEach(viewModel.items.indices, id: \.self) { index in
                HStack {
                    TextField("Item name", text: $viewModel.items[index].name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Price", value: $viewModel.items[index].price, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    
                    Stepper("Qty: \(viewModel.items[index].quantity)", 
                           value: $viewModel.items[index].quantity, 
                           in: 1...99)
                        .labelsHidden()
                    
                    Button("Remove") {
                        viewModel.removeItem(at: index)
                    }
                    .foregroundColor(.red)
                }
            }
            
            Button("Add Item") {
                viewModel.addItem()
            }
            .buttonStyle(.bordered)
            
            HStack {
                Text("Total: ")
                    .fontWeight(.semibold)
                Text(viewModel.formatPrice(viewModel.calculateTotal()))
                    .fontWeight(.bold)
                Spacer()
            }
            
            Button("Generate Receipt") {
                // TODO: Implement generate custom receipt
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!viewModel.isValid)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ReceiptFormView(viewModel: ReceiptFormViewModel())
}