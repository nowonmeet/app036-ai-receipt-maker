# 汎用ペイウォール実装 (Universal Paywall System)

他のアプリでも簡単に流用できる、RevenueCat ベースの汎用ペイウォール実装です。
※AIに任せる前に、必ず手作業でSDKをインストールすること！
　→参考 https://www.revenuecat.com/docs/tools/paywalls/installation

## 🚀 特徴

- **完全に設定可能**: API キー、エンタイトルメント、UI テーマなどすべて外部設定
- **疎結合設計**: デリゲートパターンでアプリ固有の処理を注入
- **SwiftUI & UIKit 対応**: どちらのフレームワークでも使用可能
- **豊富なテーマ**: ライト、ダーク、カスタムグラデーションなど
- **デバッグ機能**: 開発時に便利なログ出力とデバッグモード
- **アナリティクス統合**: Firebase Analytics などとの簡単な統合
- **🆕 プレゼンテーション方式選択**: embedded（埋め込み）とsheet（シート）の2つのモードをサポート
- **🆕 2重シート問題解決**: 設定画面などからの表示時に複数のシートが重なる問題を解決

## 📦 ファイル構成とコピー対象

### 🔥 必須ファイル（すべてコピーが必要）

これらのファイルを新しいアプリプロジェクトにコピーしてください：

```
📁 YourNewApp/
├── PaywallConfiguration.swift          ✅ 必須 - 設定構造体とテーマ定義
├── PaywallFlowDelegate.swift          ✅ 必須 - デリゲートプロトコルとイベント定義  
├── UniversalPaywallManager.swift      ✅ 必須 - ペイウォール管理とRevenueCat統合
├── UniversalPaywallView.swift         ✅ 必須 - SwiftUI ビューとコンテナ
└── YourAppPaywallDelegate.swift       ✅ 必須 - アプリ固有のデリゲート実装
```

### 📚 参考ファイル（オプション）

実装の参考として利用できます：

```
📁 Reference/
├── PaywallUsageExamples.swift         📖 参考 - 様々な使用例とサンプルコード
├── SpeechJammerPaywallDelegate.swift  📖 参考 - 具体的な実装例
└── PremiumSubscriptionManager.swift   📖 参考 - 既存コードとの互換性ラッパー
```

## 🛠️ セットアップ手順（Tuistプロジェクト対応版）

### 🔧 Step 0: Tuistプロジェクト設定（Tuist使用時のみ）

**Tuistを使用している場合は、以下の設定をProject.swiftに追加：**

```swift
// Project.swift
import ProjectDescription

let project = Project(
    name: "YourApp",
    packages: [
        .remote(
            url: "https://github.com/RevenueCat/purchases-ios",
            requirement: .upToNextMajor(from: "5.26.0")
        )
    ],
    targets: [
        .target(
            name: "YourApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.yourcompany.yourapp",
            deploymentTargets: .iOS("15.0"),
            infoPlist: "Resources/Info.plist",
            sources: ["Sources/**"],
            resources: ["Resources/**/*.xcassets"], // 注意: Info.plist重複を避けるため
            dependencies: [
                .package(product: "RevenueCat"),
                .package(product: "RevenueCatUI")
            ]
        )
    ]
)
```

**設定後は必ずプロジェクトを再生成：**
```bash
tuist generate
```

### 🚀 Step 1: アプリ起動時のRevenueCat初期化（必須）

**最初にこれを実行しないとクラッシュします！**

```swift
// AppDelegate.swift または App.swift で必ず初期化
import UIKit
import RevenueCat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 🔥 必須: RevenueCatの初期化
        Purchases.logLevel = .debug  // 開発時のみ
        Purchases.configure(withAPIKey: "appl_ByEFSZjaxyhgEvkPYiCdlhxYpAE")
        print("RevenueCat設定完了")
        
        return true
    }
}
```

**SwiftUIアプリの場合:**
```swift
// App.swift
import SwiftUI
import RevenueCat

@main
struct YourApp: App {
    init() {
        // 🔥 必須: RevenueCatの初期化
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "your_api_key_here")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

⚠️ **重要**: この初期化を忘れると「Purchases has not been configured」エラーでクラッシュします！

### Tuist + Swift Package Manager を使う場合（推奨）

project.yml に以下を追記します：

```yaml
packages:
  RevenueCat:
    url: https://github.com/RevenueCat/purchases-ios
    from: 5.26.0
  RevenueCatUI:
    url: https://github.com/RevenueCat/purchases-ios-ui
    from: 5.26.0

targets:
  DeepConversation:
    dependencies:
      - package: RevenueCat
      - package: RevenueCatUI
```

`tuist fetch && tuist generate` を実行後、Xcode を開きます。

#### CocoaPods 使用の場合
```ruby
pod 'RevenueCat', '~> 5.26.0'
pod 'RevenueCatUI', '~> 5.26.0'
```

## 🔑 アプリごとの必須設定項目

新しいアプリで使用する際に必ず変更が必要な設定項目：

### 1. RevenueCat ダッシュボード設定

| 項目 | 説明 | 取得場所 |
|------|------|----------|
| **API Key** | RevenueCatのプロジェクトAPIキー | RevenueCat Dashboard > アプリ設定 > API Keys |
| **Entitlement ID** | プレミアム機能のエンタイトルメント識別子 | RevenueCat Dashboard > Entitlements |
| **Product IDs** | App Store Connect で設定した商品ID | App Store Connect > アプリ内課金 |

####このアプリ
API Key: appl_RCYabEHbXfZEqMiHqZLVbNsTeDz
Entitlement Id: premium_plan
Product Ids: electric_massager_2980_1y_1w0 (サブスクリプション)
RevenueCat Product ID: prod7fd3cd119e

#### 📍 RevenueCat ダッシュボードでの設定手順：
1. **プロジェクト作成**: RevenueCat にログイン → 新規プロジェクト作成
2. **アプリ追加**: iOS アプリを追加 → Bundle ID を設定
3. **商品設定**: Products タブ → App Store Connect の Product ID を追加
4. **エンタイトルメント作成**: Entitlements タブ → 新規エンタイトルメント作成
5. **API キー取得**: API Keys タブ → Public API Key をコピー

### 2. コード内での設定変更

#### A. API キーとエンタイトルメントの設定
```swift
// YourAppPaywallDelegate.swift または App.swift で設定
let config = PaywallConfiguration(
    revenueCatAPIKey: "appl_YOUR_API_KEY_HERE",           // 🔥 必須変更
    premiumEntitlementKey: "your_premium_entitlement",    // 🔥 必須変更
    alternativeEntitlementKeys: ["pro", "premium_plus"],  // 🔧 オプション
    theme: .default,
    presentationMode: .sheet,     // 🆕 表示方式を選択 (.embedded / .sheet)
    debugMode: true  // 🔧 リリース時は false に変更
)
```

#### B. アプリ固有のデリゲート実装
```swift
// YourAppPaywallDelegate.swift
class YourAppPaywallDelegate: PaywallFlowDelegate {
    func didCompletePurchase(customerInfo: CustomerInfo) {
        // 🔥 必須実装 - アプリ固有の購入完了処理
        // - ユーザーに感謝メッセージ表示
        // - プレミアム機能の有効化
        // - アナリティクス送信 など
    }
    
    func didCompleteRestore(customerInfo: CustomerInfo) {
        // 🔥 必須実装 - アプリ固有のリストア完了処理
    }
    
    func didCancelPaywall() {
        // 🔥 必須実装 - アプリ固有のキャンセル処理
    }
    
    func shouldSendAnalytics(eventName: String, parameters: [String: Any]) {
        // 🔧 オプション - アナリティクス送信
        // Firebase, Mixpanel, Amplitude などに送信
    }
}
```

### 3. App Store Connect での設定

| 項目 | 説明 | 設定場所 |
|------|------|----------|
| **アプリ内課金商品** | 課金商品の作成と価格設定 | App Store Connect > アプリ内課金 |
| **商品ID** | RevenueCat と一致させる必要がある | 商品の詳細設定 |
| **税金カテゴリー** | 課金商品の税金分類 | 商品の価格設定 |

#### 📍 App Store Connect での設定手順：
1. **商品作成**: アプリ内課金 → 新規作成 → 自動更新サブスクリプション
2. **Product ID設定**: `com.yourapp.premium_monthly` 形式で設定
3. **価格設定**: 地域別の価格を設定
4. **商品情報**: 名前、説明文を各言語で設定
5. **審査提出**: テスト用アカウントで動作確認後、審査提出

### 4. アナリティクス設定（オプション）

#### Firebase Analytics の場合：
```swift
// 1. GoogleService-Info.plist をプロジェクトに追加
// 2. Firebase SDK を追加（Podfile または Package.swift）
// 3. App.swift で初期化
import FirebaseCore
import FirebaseAnalytics

@main
struct YourApp: App {
    init() {
        FirebaseApp.configure()  // 🔥 Firebase 使用時は必須
    }
}
```

### 5. テーマとUI設定

#### アプリに合わせたテーマ設定例：
```swift
// ゲームアプリの場合
let gameTheme = PaywallTheme(
    backgroundStyle: .gradient([.black, .red, .orange]),
    primaryColor: .white,
    secondaryColor: .orange,
    textColor: .white
)

// ビジネスアプリの場合  
let businessTheme = PaywallTheme(
    backgroundStyle: .solid(.white),
    primaryColor: .black,
    secondaryColor: .blue,
    textColor: .black
)

let config = PaywallConfiguration(
    revenueCatAPIKey: "your_api_key",
    premiumEntitlementKey: "premium",
    theme: gameTheme,  // 🔧 アプリに合わせて選択
    loadingText: "Loading Premium Features...",  // 🔧 アプリに合わせて変更
    debugMode: false  // 🔥 リリース時は必ず false
)
```

### 6. 🆕 プレゼンテーション方式の設定

#### プレゼンテーション方式とは

UniversalPaywallは2つの表示方式をサポートしています：

| 方式 | 説明 | 使用場面 | 特徴 |
|------|------|----------|------|
| **`.embedded`** | 直接表示 | 設定画面、既にシート内 | 2重シート回避、高速表示 |
| **`.sheet`** | シート表示 | メイン画面、独立表示 | 新しいモーダルとして表示 |

#### 使用例

```swift
// 🔧 設定画面からペイウォールを表示（推奨）
let embeddedConfig = PaywallConfiguration(
    revenueCatAPIKey: "your_api_key",
    premiumEntitlementKey: "premium",
    presentationMode: .embedded,    // 直接表示
    displayDelay: 0.0,             // 即座に表示
    showCloseButton: true,         // 閉じるボタン表示
    debugMode: true
)

// 🔧 メイン画面からペイウォールを表示
let sheetConfig = PaywallConfiguration(
    revenueCatAPIKey: "your_api_key",
    premiumEntitlementKey: "premium",
    presentationMode: .sheet,       // シート表示
    displayDelay: 1.0,             // 少し遅延
    showCloseButton: true,
    debugMode: false
)
```

#### 実装パターン

```swift
// SettingsCoordinatorの例（embeddedモード）
private func showPaywall() {
    let config = PaywallConfiguration(
        revenueCatAPIKey: "your_api_key",
        premiumEntitlementKey: "premium",
        presentationMode: .embedded,  // 既にシート内なので直接表示
        displayDelay: 0.0
    )
    
    let paywallContainer = UniversalPaywallContainer(
        configuration: config,
        delegate: delegate
    )
    
    // UIHostingControllerでシート表示
    let hostingController = UIHostingController(rootView: paywallContainer)
    navigationController.present(hostingController, animated: true)
}

// MainViewの例（sheetモード）
struct MainView: View {
    @State private var showPaywall = false
    
    var body: some View {
        Button("Show Premium") {
            showPaywall = true
        }
        .sheet(isPresented: $showPaywall) {
            UniversalPaywallContainer(
                configuration: PaywallConfiguration(
                    revenueCatAPIKey: "your_api_key",
                    premiumEntitlementKey: "premium",
                    presentationMode: .sheet  // 新しいシートで表示
                ),
                delegate: delegate
            )
        }
    }
}
```

#### トラブルシューティング

**問題**: 2重シートが表示される
- **原因**: `.sheet`モードを既にシート内で使用
- **解決**: `.embedded`モードに変更

**問題**: ローディング画面が長い
- **原因**: `displayDelay`が長すぎる
- **解決**: `.embedded`モードで`displayDelay: 0.0`に設定

### 7. デバッグとテスト設定

#### 開発時の設定：
```swift
let debugConfig = PaywallConfiguration(
    revenueCatAPIKey: "your_api_key",
    premiumEntitlementKey: "premium",
    showSkipButton: true,    // 🔧 テスト用 - リリース時は false
    debugMode: true,         // 🔧 テスト用 - リリース時は false
    displayDelay: 0.1        // 🔧 テスト用 - リリース時は 1.0 推奨
)
```

## ⚠️ 重要な注意事項

### セキュリティ
- **API キーの管理**: RevenueCat API キーは公開リポジトリにコミットしない
- **プロダクションキー**: 開発用とプダクション用でAPIキーを分ける

### テスト
- **Sandbox テスト**: App Store Connect のテストユーザーで必ずテスト
- **実機テスト**: シミュレーターでは課金テストができないため実機必須

### リリース前チェックリスト
- [ ] **AppDelegate でRevenueCat初期化が実装されている** 🔥 最重要
- [ ] API キーをプロダクション用に変更
- [ ] `debugMode: false` に設定
- [ ] `showSkipButton: false` に設定  
- [ ] App Store Connect で商品を審査済み状態にする
- [ ] RevenueCat ダッシュボードで商品が正しく設定されている

## 🚀 クイックスタートガイド

新しいアプリでペイウォールを導入する最短手順：

### Step 1: ファイルをコピー
```bash
# 必須ファイル5つをコピー
cp PaywallConfiguration.swift YourNewApp/
cp PaywallFlowDelegate.swift YourNewApp/
cp UniversalPaywallManager.swift YourNewApp/
cp UniversalPaywallView.swift YourNewApp/
cp SpeechJammerPaywallDelegate.swift YourNewApp/YourAppPaywallDelegate.swift
```

### Step 2: 依存関係を追加
```ruby
# Podfile
pod 'RevenueCat', '~> 5.26.0'
pod 'RevenueCatUI', '~> 5.26.0'
```

### Step 3: RevenueCat設定（5分）
1. [RevenueCat](https://app.revenuecat.com) でアカウント作成
2. プロジェクト作成 → iOS アプリ追加
3. エンタイトルメント作成（例：`premium_features`）
4. API Key をコピー

### Step 4: アプリ起動時の初期化（1分）
```swift
// AppDelegate.swift で RevenueCat を初期化
import RevenueCat

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Purchases.configure(withAPIKey: "appl_YOUR_COPIED_API_KEY")
    return true
}
```

### Step 5: コード設定（3分）
```swift
// App.swift または YourAppPaywallDelegate.swift
let config = PaywallConfiguration(
    revenueCatAPIKey: "appl_YOUR_COPIED_API_KEY",  // 上記で設定したものと同じ
    premiumEntitlementKey: "premium_features"
)

let delegate = YourAppPaywallDelegate()
let paywall = UniversalPaywallContainer(
    configuration: config,
    delegate: delegate
)
```

### Step 6: 動作確認
```swift
// テスト表示
if paywall.requiresPremiumAccess() {
    paywall.showPaywall()
}
```

**所要時間: 約11分で基本実装完了！**

⚠️ **絶対に忘れてはいけないこと**: 
- **Step 4のRevenueCat初期化**を忘れるとアプリがクラッシュします
- API Keyは必ず最初にAppDelegateで設定してください

## 🔧 セットアップ

### 1. 依存関係

```swift
// Package.swift または Podfile
dependencies: [
    .package(url: "https://github.com/RevenueCat/purchases-ios", from: "5.26.0"),
    .package(url: "https://github.com/RevenueCat/purchases-ui-ios", from: "5.26.0")
]
```

### 2. 基本的な実装

```swift
import SwiftUI

// 1. 設定を作成
let config = PaywallConfiguration(
    revenueCatAPIKey: "YOUR_REVENUECAT_API_KEY",
    premiumEntitlementKey: "premium_features",
    theme: .default
)

// 2. デリゲートを実装
class MyPaywallDelegate: PaywallFlowDelegate {
    func didCompletePurchase(customerInfo: CustomerInfo) {
        // 購入完了時の処理
        print("Purchase completed!")
    }
    
    func didCompleteRestore(customerInfo: CustomerInfo) {
        // リストア完了時の処理
        print("Restore completed!")
    }
    
    func didCancelPaywall() {
        // キャンセル時の処理
        print("Paywall cancelled")
    }
}

// 3. ペイウォールを使用
struct MyView: View {
    @StateObject private var paywallContainer: UniversalPaywallContainer
    
    init() {
        let delegate = MyPaywallDelegate()
        self._paywallContainer = StateObject(wrappedValue: UniversalPaywallContainer(
            configuration: config,
            delegate: delegate
        ))
    }
    
    var body: some View {
        VStack {
            Button("Show Premium Features") {
                if paywallContainer.requiresPremiumAccess() {
                    paywallContainer.showPaywall()
                }
            }
        }
        .sheet(isPresented: $paywallContainer.isShowingPaywall) {
            paywallContainer
        }
    }
}
```

## 🎨 テーマカスタマイズ

### プリセットテーマ

```swift
// ダークテーマ
let config = PaywallConfiguration(
    revenueCatAPIKey: "YOUR_API_KEY",
    theme: .dark
)

// ライトテーマ
let config = PaywallConfiguration(
    revenueCatAPIKey: "YOUR_API_KEY",
    theme: .light
)
```

### カスタムテーマ

```swift
let customTheme = PaywallTheme(
    backgroundStyle: .gradient([.blue, .purple, .black]),
    primaryColor: .white,
    secondaryColor: .yellow,
    textColor: .white,
    fontConfiguration: FontConfiguration(
        titleFont: .largeTitle,
        bodyFont: .body,
        buttonFont: .headline
    )
)

let config = PaywallConfiguration(
    revenueCatAPIKey: "YOUR_API_KEY",
    theme: customTheme
)
```

### 背景スタイル

```swift
// 単色背景
.backgroundStyle(.solid(.black))

// グラデーション背景
.backgroundStyle(.gradient([.red, .orange, .yellow]))

// 画像背景
.backgroundStyle(.image("background_image"))
```

## ⚙️ 高度な設定

### フル設定例

```swift
let config = PaywallConfiguration(
    revenueCatAPIKey: "your_api_key",
    premiumEntitlementKey: "premium_plan",
    alternativeEntitlementKeys: ["pro", "full_access"],
    theme: .dark,
    showCloseButton: true,
    showSkipButton: false,  // 本番では false 推奨
    loadingText: "Premium機能を準備中...",
    skipButtonText: "スキップして続行",
    presentationMode: .sheet,  // 🆕 表示方式を選択
    displayDelay: 1.0,
    debugMode: false,  // 本番では false
    enableAnalytics: true,
    analyticsTriggerSource: "feature_limit"
)
```

### アナリティクス統合

```swift
class AnalyticsPaywallDelegate: PaywallFlowDelegate {
    func shouldSendAnalytics(eventName: String, parameters: [String: Any]) {
        // Firebase Analytics
        Analytics.logEvent(eventName, parameters: parameters)
        
        // Mixpanel
        Mixpanel.mainInstance().track(event: eventName, properties: parameters)
        
        // 他のアナリティクスサービス...
    }
    
    // その他のデリゲートメソッド...
}
```

## 📱 アプリ種別ごとの推奨設定

### ゲームアプリ

```swift
PaywallConfiguration(
    revenueCatAPIKey: "GAME_API_KEY",
    premiumEntitlementKey: "premium_game",
    theme: PaywallTheme(
        backgroundStyle: .gradient([.black, .red, .orange]),
        primaryColor: .white,
        secondaryColor: .orange
    ),
    showSkipButton: false,
    presentationMode: .sheet,  // ゲーム中断でのシート表示
    analyticsTriggerSource: "game_feature"
)
```

### 生産性アプリ

```swift
PaywallConfiguration(
    revenueCatAPIKey: "PRODUCTIVITY_API_KEY",
    premiumEntitlementKey: "pro_features",
    theme: .light,
    showSkipButton: true,
    skipButtonText: "Continue with basic features",
    presentationMode: .embedded,  // 設定画面からの表示が多い
    displayDelay: 0.0,           // 即座に表示
    analyticsTriggerSource: "feature_limit"
)
```

### エンターテイメントアプリ

```swift
PaywallConfiguration(
    revenueCatAPIKey: "ENTERTAINMENT_API_KEY",
    premiumEntitlementKey: "unlimited_access",
    theme: PaywallTheme(
        backgroundStyle: .gradient([.purple, .blue, .black])
    ),
    loadingText: "Unlocking Premium Content...",
    presentationMode: .sheet,     // コンテンツ閲覧中のシート表示
    analyticsTriggerSource: "content_limit"
)
```

## 🧪 デバッグとテスト

### デバッグモード有効化

```swift
let config = PaywallConfiguration(
    revenueCatAPIKey: "YOUR_API_KEY",
    debugMode: true,  // 詳細ログを出力
    showSkipButton: true  // テスト用スキップボタン
)
```

### 課金状態の手動操作（デバッグビルドのみ）

```swift
// 課金状態をトグル（テスト用）
paywallContainer.togglePremiumForDebug()

// 課金状態を手動でチェック
paywallContainer.checkSubscriptionStatus()
```

## 🔄 既存アプリへの移行

既存の RevenueCat 実装がある場合は、段階的に移行できます：

### 1. 既存コードとの併用

```swift
// 既存のマネージャーはそのまま使用可能
let existingManager = PremiumSubscriptionManager.shared

// 新しい汎用実装を追加
let newPaywall = UniversalPaywallContainer(
    configuration: config,
    delegate: delegate
)
```

### 2. 完全移行

1. 既存のペイウォール表示コードを削除
2. `UniversalPaywallContainer` に置き換え
3. アプリ固有のロジックを `PaywallFlowDelegate` に移動
4. テストとQA

## 📝 トラブルシューティング

### よくある問題

1. **「Purchases has not been configured」エラーでクラッシュ** 🔥 最頻出
   - **原因**: AppDelegate での RevenueCat 初期化が未実装
   - **解決**: `Purchases.configure(withAPIKey:)` をアプリ起動時に必ず実行
   - **場所**: AppDelegate.swift の `didFinishLaunchingWithOptions`

2. **🆕 2重シートが表示される**
   - **原因**: 既にシート内で `.sheet` モードを使用
   - **解決**: `.embedded` モードに変更
   - **例**: 設定画面からのペイウォール表示時

3. **🆕 ローディング画面が長すぎる**
   - **原因**: `displayDelay` の設定値が大きい
   - **解決**: `.embedded` モードで `displayDelay: 0.0` に設定
   - **補足**: 即座に表示したい場合に有効

4. **ペイウォールが表示されない**
   - RevenueCat API キーが正しいか確認
   - エンタイトルメントキーがダッシュボードと一致するか確認
   - ネットワーク接続を確認
   - `presentationMode` が適切に設定されているか確認

5. **購入が反映されない**
   - `debugMode: true` でログを確認
   - RevenueCat ダッシュボードでトランザクションを確認
   - Sandbox環境でテストしているか確認

6. **テーマが反映されない**
   - プレビューでテーマを確認
   - カスタムテーマの設定値を再確認

### ログの見方

デバッグモードを有効にすると、以下のようなログが出力されます：

```
🚀 UniversalPaywallManager初期化完了
📱 UniversalPaywallView表示開始
📱 プレゼンテーションモード: embedded
🔄 Offerings事前ロード開始
✅ Offerings事前ロード完了
✅ アクティブなエンタイトルメント発見: premium_plan
🎉 購入完了処理開始
```

**🆕 新しいログ項目**:
- `📱 プレゼンテーションモード`: 選択された表示方式を確認
- `🔄 Offerings事前ロード開始/完了`: RevenueCatローディング回避の状況

## 🤝 コントリビューション

この汎用実装を改善するためのフィードバックや改善案を歓迎します。

### 改善のアイデア
- より多くのテーマプリセット
- 他のアナリティクスサービスとの統合例
- A/Bテスト機能
- より詳細なエラーハンドリング
- 🆕 アニメーション設定のカスタマイズ
- 🆕 プレゼンテーション方式の自動判定機能

## 📄 ライセンス

このプロジェクトで使用している外部ライブラリ：
- RevenueCat (~> 5.26.0)
- RevenueCatUI (~> 5.26.0)

---

## ⚠️ 実装時の注意点（実体験から）

### Tuistプロジェクトでの特有の問題と解決策

#### 1. Info.plist重複エラー
**問題:** `resources: ["Resources/**"]` と指定すると Info.plist が重複してビルドエラーになる
```swift
// ❌ NG: Info.plistが重複する
resources: ["Resources/**"],

// ✅ OK: .xcassetsのみを含める
resources: ["Resources/**/*.xcassets"],
```

#### 2. PaywallConfiguration引数順序エラー
**問題:** 引数の順序を間違えるとコンパイルエラーになる
```swift
// ❌ NG: 引数順序が間違い
PaywallConfiguration(
    revenueCatAPIKey: "...",
    theme: .default,
    presentationMode: .sheet,        // この位置が間違い
    showCloseButton: true           
)

// ✅ OK: 正しい引数順序
PaywallConfiguration(
    revenueCatAPIKey: "...",
    theme: .default,
    showCloseButton: true,          // showCloseButtonが先
    presentationMode: .sheet        
)
```

#### 3. 削除ファイルのビルドエラー
**問題:** 不要なReferenceファイルを削除してもXcodeプロジェクトが参照し続ける
```bash
# ファイル削除後は必ずプロジェクト再生成
rm -rf Sources/Features/Paywall/Reference/
tuist generate
```

#### 4. RevenueCat依存関係の設定
**重要:** 通常のXcodeプロジェクトとTuistでは依存関係設定が異なる
```swift
// Project.swift での正しい設定
packages: [
    .remote(
        url: "https://github.com/RevenueCat/purchases-ios",
        requirement: .upToNextMajor(from: "5.26.0")
    )
],
dependencies: [
    .package(product: "RevenueCat"),
    .package(product: "RevenueCatUI")  // 両方とも必要
]
```

### トラブルシューティング

#### シミュレーターが見つからない場合
```bash
# 利用可能なデバイスを確認
xcrun simctl list devices

# 具体的なDevice IDを指定してビルド
xcodebuild -workspace YourApp.xcworkspace -scheme YourApp \
  -destination 'platform=iOS Simulator,id=DEVICE_ID' build
```

#### ビルドが通らない場合の手順
1. `tuist generate` でプロジェクト再生成
2. Xcodeを再起動
3. DerivedDataクリア: `rm -rf ~/Library/Developer/Xcode/DerivedData`
4. 再度ビルド

### 実装完了後の確認項目
- [ ] シミュレーターでペイウォール表示ができること
- [ ] RevenueCatダッシュボードでアプリが認識されていること  
- [ ] デバッグログでRevenueCat初期化が成功していること
- [ ] 設定画面からペイウォールが正常に起動すること

詳細なトラブルシューティングは `PAYWALL_TROUBLESHOOTING.md` を参照してください。

---

## 🔗 関連リンク

- [RevenueCat Documentation](https://docs.revenuecat.com/)
- [RevenueCat iOS SDK](https://github.com/RevenueCat/purchases-ios)
- [Apple In-App Purchase Programming Guide](https://developer.apple.com/in-app-purchase/)
- [Tuist Documentation](https://docs.tuist.io/)