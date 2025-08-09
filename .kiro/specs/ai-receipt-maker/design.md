# 設計書

## 概要

AI Receipt Makerは、SwiftUIとSwift Dataを使用したiOSアプリで、DALL-E APIを通じてAI生成レシート画像を作成します。アプリはMVVMアーキテクチャパターンを採用し、RevenueCatによるサブスクリプション管理、安全な画像保存、地域化された通貨フォーマット機能を提供します。

## アーキテクチャ

### アーキテクチャパターン
- **MVVM (Model-View-ViewModel)**: SwiftUIとの親和性が高く、データバインディングとテスト可能性を提供
- **Repository Pattern**: データアクセス層の抽象化により、テストとメンテナンスを容易にする
- **Service Layer**: 外部API（DALL-E、RevenueCat）との通信を管理

### 主要レイヤー
```
┌─────────────────┐
│   SwiftUI Views │ ← ユーザーインターフェース
├─────────────────┤
│   ViewModels    │ ← ビジネスロジックとUI状態管理
├─────────────────┤
│   Services      │ ← 外部API通信とビジネスサービス
├─────────────────┤
│  Repositories   │ ← データアクセス抽象化
├─────────────────┤
│  Swift Data     │ ← ローカルデータ永続化
└─────────────────┘
```

## コンポーネントとインターフェース

### 1. データモデル

#### ReceiptData (Swift Data Model)
```swift
@Model
class ReceiptData {
    var id: UUID
    var storeName: String?
    var items: [ReceiptItem]
    var totalAmount: Decimal?
    var currency: String
    var imageFileName: String
    var createdAt: Date
    var isGenerated: Bool
}

@Model 
class ReceiptItem {
    var name: String
    var price: Decimal
    var quantity: Int
}
```

#### UsageTracker (Swift Data Model)
```swift
@Model
class UsageTracker {
    var date: Date
    var generationCount: Int
    var isPremiumUser: Bool
}
```

### 2. サービス層

#### DALLEService
```swift
protocol DALLEServiceProtocol {
    func generateReceiptImage(prompt: String) async throws -> Data
}

class DALLEService: DALLEServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/images/generations"
}
```

#### SubscriptionService (RevenueCat統合)
```swift
protocol SubscriptionServiceProtocol {
    var isPremiumUser: Bool { get }
    func checkSubscriptionStatus() async throws -> Bool
    func presentPaywall() async throws
}

class SubscriptionService: SubscriptionServiceProtocol {
    // RevenueCat SDK統合
}
```

#### ImageStorageService
```swift
protocol ImageStorageServiceProtocol {
    func saveImage(_ data: Data, fileName: String) throws -> URL
    func loadImage(fileName: String) throws -> Data
    func deleteImage(fileName: String) throws
}

class ImageStorageService: ImageStorageServiceProtocol {
    private let documentsDirectory: URL
}
```

#### WatermarkService
```swift
protocol WatermarkServiceProtocol {
    func addWatermark(to imageData: Data, text: String) throws -> Data
}

class WatermarkService: WatermarkServiceProtocol {
    func addWatermark(to imageData: Data, text: String) throws -> Data
}
```

### 3. リポジトリ層

#### ReceiptRepository
```swift
protocol ReceiptRepositoryProtocol {
    func save(_ receipt: ReceiptData) throws
    func fetchAll() throws -> [ReceiptData]
    func delete(_ receipt: ReceiptData) throws
}

class ReceiptRepository: ReceiptRepositoryProtocol {
    private let modelContext: ModelContext
}
```

#### UsageRepository
```swift
protocol UsageRepositoryProtocol {
    func getTodayUsage() throws -> UsageTracker?
    func incrementUsage(isPremium: Bool) throws
    func resetDailyUsage() throws
}

class UsageRepository: UsageRepositoryProtocol {
    private let modelContext: ModelContext
}
```

### 4. ViewModel層

#### MainViewModel
```swift
@MainActor
class MainViewModel: ObservableObject {
    @Published var receipts: [ReceiptData] = []
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var showPaywall = false
    
    private let dalleService: DALLEServiceProtocol
    private let subscriptionService: SubscriptionServiceProtocol
    private let receiptRepository: ReceiptRepositoryProtocol
    private let usageRepository: UsageRepositoryProtocol
}
```

#### ReceiptFormViewModel
```swift
@MainActor
class ReceiptFormViewModel: ObservableObject {
    @Published var storeName = ""
    @Published var items: [ReceiptItemInput] = []
    @Published var useRandomData = true
    
    private let currencyFormatter: CurrencyFormatterProtocol
}
```

### 5. View層

#### メインビュー構造
```
MainTabView
├── GenerateReceiptView (生成画面)
│   ├── ReceiptFormView (入力フォーム)
│   └── GenerateButtonView (生成ボタン)
├── ReceiptGalleryView (ギャラリー画面)
│   ├── ReceiptGridView (グリッド表示)
│   └── ReceiptDetailView (詳細表示)
└── SettingsView (設定画面)
    └── SubscriptionStatusView (サブスク状態)
```

## データモデル

### Swift Data スキーマ設計

#### ReceiptData エンティティ
- **id**: UUID - 一意識別子
- **storeName**: String? - 店舗名（オプショナル）
- **items**: [ReceiptItem] - 商品リスト
- **totalAmount**: Decimal? - 合計金額
- **currency**: String - 通貨コード（ISO 4217）
- **imageFileName**: String - 保存された画像ファイル名
- **createdAt**: Date - 作成日時
- **isGenerated**: Bool - 生成完了フラグ

#### UsageTracker エンティティ
- **date**: Date - 使用日（日付のみ）
- **generationCount**: Int - その日の生成回数
- **isPremiumUser**: Bool - 記録時点でのプレミアムステータス

### データ関係
- ReceiptData ↔ ReceiptItem: 一対多の関係
- UsageTracker: 日付ごとの独立したレコード

## エラーハンドリング

### エラータイプ定義
```swift
enum AppError: LocalizedError {
    case networkError(String)
    case apiError(String)
    case storageError(String)
    case subscriptionError(String)
    case validationError(String)
    case usageLimitExceeded(Int, Bool) // count, isPremium
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .apiError(let message):
            return "API Error: \(message)"
        case .storageError(let message):
            return "Storage Error: \(message)"
        case .subscriptionError(let message):
            return "Subscription Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .usageLimitExceeded(let count, let isPremium):
            let limit = isPremium ? 10 : 2
            return "Daily limit reached (\(count)/\(limit))"
        }
    }
}
```

### エラーハンドリング戦略
1. **ネットワークエラー**: リトライ機能付きのユーザーフレンドリーなメッセージ
2. **APIエラー**: DALL-E APIの具体的なエラーコードに基づく適切な対応
3. **ストレージエラー**: ローカルストレージの問題に対する代替手段の提示
4. **サブスクリプションエラー**: RevenueCatエラーの適切な処理とフォールバック
5. **使用制限エラー**: ペイウォール表示とプレミアムアップグレードの促進

## テスト戦略

### 単体テスト
- **ViewModels**: ビジネスロジックとUI状態管理のテスト
- **Services**: 外部API通信とデータ変換のテスト
- **Repositories**: データアクセス層のテスト
- **Utilities**: 通貨フォーマッターや透かし処理のテスト

### 統合テスト
- **DALL-E API統合**: モックサーバーを使用したAPI通信テスト
- **RevenueCat統合**: サブスクリプション状態変更のテスト
- **Swift Data統合**: データ永続化とクエリのテスト

### UIテスト
- **画面遷移**: 主要なユーザーフローのテスト
- **フォーム入力**: バリデーションとエラー表示のテスト
- **ペイウォール**: サブスクリプション購入フローのテスト

### テストダブル戦略
```swift
// プロトコルベースの依存性注入によるモック化
protocol DALLEServiceProtocol {
    func generateReceiptImage(prompt: String) async throws -> Data
}

class MockDALLEService: DALLEServiceProtocol {
    var shouldFail = false
    var mockImageData = Data()
    
    func generateReceiptImage(prompt: String) async throws -> Data {
        if shouldFail {
            throw AppError.apiError("Mock API Error")
        }
        return mockImageData
    }
}
```

## セキュリティ考慮事項

### API キー管理
- DALL-E APIキーは環境変数またはKeychain Servicesで安全に保存
- ソースコードにハードコーディングしない
- プロダクションとデバッグ環境で異なるキーを使用

### 画像ストレージセキュリティ
- アプリのDocumentsディレクトリ内に保存（サンドボックス保護）
- ファイル名にUUIDを使用して推測困難にする
- アプリ削除時に自動的にすべてのデータが削除される

### ユーザーデータ保護
- 個人情報は最小限に抑制
- 生成されたレシートデータのみを保存
- ユーザーの実際の購入履歴は保存しない

## パフォーマンス最適化

### 画像処理最適化
- 非同期画像生成とプログレス表示
- 画像キャッシュ機能による再表示の高速化
- メモリ効率的な画像処理（Core Graphicsの活用）

### データベース最適化
- Swift Dataのインデックス活用
- 必要なデータのみをフェッチするクエリ最適化
- バックグラウンドでのデータ同期

### UI応答性
- メインスレッドでの重い処理を避ける
- 適切なローディング状態の表示
- スムーズなアニメーションとトランジション

## 国際化とローカライゼーション

### 通貨フォーマット
```swift
class CurrencyFormatter {
    private let numberFormatter: NumberFormatter
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
    }
    
    func format(_ amount: Decimal) -> String {
        return numberFormatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}
```

### 地域別通貨対応
- iOS標準のLocaleを使用した自動通貨検出
- 主要通貨（USD, EUR, JPY, GBP, CAD等）のサポート
- フォールバック通貨としてUSDを設定

### UI言語固定
- アプリ内のすべてのテキストを英語で固定
- NSLocalizedStringを使用せず、直接英語文字列を使用
- 将来的な多言語対応への拡張性を考慮した設計

## 依存関係管理

### 外部ライブラリ
```swift
// Package.swift dependencies
dependencies: [
    .package(url: "https://github.com/RevenueCat/purchases-ios", from: "4.0.0"),
    .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0")
]
```

### 主要依存関係
1. **RevenueCat**: サブスクリプション管理
2. **Alamofire**: HTTP通信（DALL-E API）
3. **Swift Data**: ローカルデータ永続化（iOS標準）
4. **SwiftUI**: ユーザーインターフェース（iOS標準）

## デプロイメント考慮事項

### App Store審査対応
- 生成されるコンテンツの適切性確保
- プライバシーポリシーの明確化
- サブスクリプション機能の適切な実装

### 設定管理
- デバッグ/リリースビルド設定の分離
- API エンドポイントの環境別管理
- ログレベルの適切な設定