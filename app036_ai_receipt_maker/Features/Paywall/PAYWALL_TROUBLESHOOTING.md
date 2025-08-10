# RevenueCat パッケージが Frameworks, Libraries, and Embedded Content に現れない時の対処メモ

> たまに Xcode が Swift Package をターゲットへ正しくリンクしてくれず、`import RevenueCatUI` でビルドエラーになることがある。そのときに試す手順をまとめたよ。

---

## TL;DR
1. **Package をいったん削除** → もう一度追加
2. **Build Phases ➜ Link Binary With Libraries** から手動リンク
3. それでもダメなら **DerivedData を削除** してキャッシュクリア

---

## 1. パッケージを削除 → 再追加

1. Project ナビゲータの `Package Dependencies` で `RevenueCat` を選択し、右クリック → **Remove Package**.
2. File ▸ **Add Packages…** を開き、URL に `https://github.com/RevenueCat/purchases-ios` を入力 → **Next**.
3. 「Choose Package Products」で以下 2 つにチェックを入れて **Add**.
   - `RevenueCat`
   - `RevenueCatUI`
4. ここで **Add to Target** が `DeepConversation` になっているか要確認。

> ✔️ 正しく追加できると、`General` タブの最下部に Frameworks テーブルが現れる。

---

## 2. Build Phases から手動リンク

Frameworks テーブル自体が表示されない場合は、まだフレームワークが 1 つもリンクされていないせい。

1. TARGETS ▸ **DeepConversation** を選択 → **Build Phases** タブ.
2. **Link Binary With Libraries** を展開 → `＋` ボタン.
3. リスト上部の **RevenueCat Package** の中にある
   - `RevenueCat.framework`
   - `RevenueCatUI.framework`
   をそれぞれ選んで **Add**.
4. リンク後に `General` タブへ戻ると Frameworks テーブルが生成されている。

---

## 3. キャッシュ & ビルドフォルダをクリーン

それでも `No such module 'RevenueCatUI'` が消えない場合は Xcode キャッシュが壊れている可能性。

```bash
# ビルドフォルダをクリーン（Xcode メニューでも可）
⌥ + ⇧ + ⌘ + K

# DerivedData を削除（ターミナル）
rm -rf ~/Library/Developer/Xcode/DerivedData
```

Xcode を再起動したあと、再度パッケージの追加を試す。

---

## 4. ネットワーク or GitHub アクセス制限を疑う

会社ネットワークや VPN で GitHub にアクセスできないと、パッケージのダウンロードに失敗することがある。

- ブラウザで `https://github.com/RevenueCat/purchases-ios` が開けるか確認
- プロキシ設定が必要なら Xcode ▸ Settings ▸ Accounts ▸ **GitHub** にトークンを追加

---

## 5. それでも解決しない場合

- Xcode バージョンを最新 (または安定版) にアップデート
- 新規のダミー iOS プロジェクトで同じパッケージを追加し、再現するかテスト
- 再現する場合は RevenueCat 側の issue をチェック / 公式 Slack で質問

---

## 6. Tuist プロジェクトでの実装時のトラブルシューティング

### 問題1: Info.plist重複エラー
**エラー内容:**
```
error: Multiple commands produce '/path/to/MosquitoApp.app/Info.plist'
```

**原因:** `Project.swift`の`resources`設定で`Resources/**`を指定すると、Info.plistファイルが重複してコピーされる。

**解決方法:**
```swift
// 修正前
resources: ["Resources/**"],

// 修正後  
resources: ["Resources/**/*.xcassets"],
```

### 問題2: 削除したファイルのビルドエラー
**エラー内容:**
```
error: Build input files cannot be found: '/path/to/ReferenceFile.swift'
```

**原因:** ファイルシステムから削除してもTuistが生成したXcodeプロジェクトがまだ参照している。

**解決方法:**
```bash
# プロジェクトを再生成
tuist generate
```

### 問題3: PaywallConfiguration引数順序エラー
**エラー内容:**
```
error: argument 'showCloseButton' must precede argument 'presentationMode'
```

**原因:** PaywallConfigurationの初期化時に引数の順序が間違っている。

**解決方法:**
```swift
// 修正前
PaywallConfiguration(
    revenueCatAPIKey: "...",
    theme: .default,
    presentationMode: .sheet,
    showCloseButton: true  // この位置が間違い
)

// 修正後
PaywallConfiguration(
    revenueCatAPIKey: "...",
    theme: .default,
    showCloseButton: true,  // 正しい位置
    presentationMode: .sheet
)
```

### 問題4: Tuist vs 通常のXcodeプロジェクトの依存関係設定
**問題:** 通常のXcodeプロジェクトとTuistでは依存関係の設定方法が異なる。

**Tuistでの正しい設定:**
```swift
// Project.swift
let project = Project(
    name: "MosquitoApp",
    packages: [
        .remote(
            url: "https://github.com/RevenueCat/purchases-ios",
            requirement: .upToNextMajor(from: "5.26.0")
        )
    ],
    targets: [
        .target(
            name: "MosquitoApp",
            dependencies: [
                .package(product: "RevenueCat"),
                .package(product: "RevenueCatUI")
            ]
        )
    ]
)
```

### 問題5: シミュレーターデバイスが見つからない
**エラー内容:**
```
error: Unable to find a device matching the provided destination specifier
```

**解決方法:**
```bash
# 利用可能なシミュレーターデバイスを確認
xcrun simctl list devices

# 具体的なデバイスIDを指定してビルド
xcodebuild -workspace MosquitoApp.xcworkspace -scheme MosquitoApp \
  -destination 'platform=iOS Simulator,id=DEVICE_ID' build
```

---

### メモ
- `RevenueCat_CustomEntitlementComputation.framework` はエンタープライズ用途の追加モジュール。誤ってリンクしても動くが、サイズ増になるので基本は不要。
- フレームワークの **Embed** オプションはデフォルトの **Embed & Sign** のままで OK。
- Tuistを使用する場合は、依存関係の変更後は必ず `tuist generate` でプロジェクトを再生成する。
- RevenueCatのデバッグログを有効にするには、AppDelegate/SceneDelegateで `Purchases.logLevel = .debug` を設定する。 