//
//  ReceiptRepositoryProtocol.swift
//  app036_ai_receipt_maker
//
//  Created by RYO MISHIMA on 2025/08/10.
//

import Foundation

protocol ReceiptRepositoryProtocol {
    func save(_ receipt: ReceiptData) throws
    func fetchAll() throws -> [ReceiptData]
    func delete(_ receipt: ReceiptData) throws
}