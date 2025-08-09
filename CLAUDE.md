# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

これは **app036_ai_receipt_maker** という名前のiOS/macOSアプリケーションプロジェクトで、SwiftUIを使用して開発されています。AIを活用したレシート作成アプリケーションとして設計されているようです。

## 開発環境

- **言語**: Swift
- **フレームワーク**: SwiftUI
- **プラットフォーム**: iOS/macOS
- **IDE**: Xcode
- **テストフレームワーク**: Swift Testing Framework

## よく使用するコマンド

### ビルドとテスト

```bash
# Xcodeでプロジェクトをビルド
xcodebuild -project app036_ai_receipt_maker.xcodeproj -scheme app036_ai_receipt_maker build

# テストの実行
xcodebuild -project app036_ai_receipt_maker.xcodeproj -scheme app036_ai_receipt_maker test

# 特定のテストのみ実行
xcodebuild -project app036_ai_receipt_maker.xcodeproj -scheme app036_ai_receipt_maker test-without-building -only-testing:app036_ai_receipt_makerTests

# クリーンビルド
xcodebuild -project app036_ai_receipt_maker.xcodeproj -scheme app036_ai_receipt_maker clean build
```

### シミュレーターでの実行

```bash
# iOSシミュレーターで実行
xcodebuild -project app036_ai_receipt_maker.xcodeproj -scheme app036_ai_receipt_maker -destination 'platform=iOS Simulator,name=iPhone 15' run

# macOSで実行
xcodebuild -project app036_ai_receipt_maker.xcodeproj -scheme app036_ai_receipt_maker -destination 'platform=macOS' run
```

### 出力のルール
 - 英語で考えるが、返答は日本語で返答して
 - 受け答えをフランクにして。敬語ではなくタメ口で話す。一人称はわたし
 - ユーザーの要求が完全に解決されるまで、ターンを終了せず処理を続けてください。
 - ターンを終了する前に、必ずバグがないか確認し、もしバグがあればバグを取り除く工程をスタートして。
 - テストコードを書いたほうがいいタイミングで、テストコードの実装を提案する。
 - ルールを確認したら、「ルールを確認しました」とおしえて。
 - 返信が完了したら、必ずterminalから以下を実行してください
   'say "完了"'
 - ターンが終わったら、必ず下記を出力して
 　「毎回CLAUDE.mdを読み込むこと」
 　「本アプリはTDD (テスト駆動開発 )の原則に従って進める」
 　「単一責任と関心の分離を意識して、クラスごとにできるかぎり細かくファイルを分割して。」

### 実装のルール（最上位ルール）
 - 本アプリはTDD (テスト駆動開発 )の原則に従って進める

### コーディング原則
YAGNI: 将来使うかもしれない機能は実装しない

DRY: 重複コードは必ず関数化・モジュール化する

KISS: 複雑な解決策より単純な解決策を優先

### 新しくクラスを作成するとき
 - 値オブジェクトを使用
 - 完全コンストラクタで作成
 - 関心の分離と単一責任（単一目的）の原則を意識する
 - 疎結合、カプセル化を前提に作成して

 ### パッケージの使用
 - 外部パッケージを使用する場合は、更新頻度を確認する
 - 現在更新が滞っている場合、パッケージを使用せず、自前の実装を検討する

 ### バグ修正のとき
 - logを仕込んでステップ・バイ・ステップで原因究明に努めてください

 ### クラスの作成
 - できる限りクラスは機能ごと分割し、ファイルも分割して。
 クラス名やファイル名は可能な限り具体的で、意味範囲が狭い、特化した名前を選ぶ。存在ベースではなく、目的ベースで名前を考えること。（NG例:金額、住所 ok例:支払金額、商品金額、配送先住所、発送元住所）

### アーキテクチャ
 - 機能の再利用性を念頭にアーキテクチャを作成する

## TDD開発ガイド（Swift/iOS特化）

### TDD基本方針（t-wada流ベース + Swift Testing）

- 🔴 **Red**: 失敗するテストを書く（`@Test`アノテーションで）
- 🟢 **Green**: テストを通す最小限の実装  
- 🔵 **Refactor**: リファクタリング
- 小さなステップで進める
- 仮実装（ベタ書き）から始める
- 三角測量で一般化する
- 明白な実装が分かる場合は直接実装してもOK
- テストリストを常に更新する
- 不安なところからテストを書く

## プロジェクト構造とアーキテクチャ

### ディレクトリ構造

```
app036_ai_receipt_maker/
├── app036_ai_receipt_maker.xcodeproj/  # Xcodeプロジェクトファイル
├── app036_ai_receipt_maker/            # メインアプリケーションコード
│   ├── app036_ai_receipt_makerApp.swift  # アプリのエントリーポイント（@main）
│   ├── ContentView.swift                 # メインビュー
│   └── Assets.xcassets/                  # アセット（画像、色、アイコン）
├── app036_ai_receipt_makerTests/       # ユニットテスト
└── app036_ai_receipt_makerUITests/     # UIテスト
```

### アーキテクチャの特徴

1. **SwiftUIアプリケーション構造**
   - `app036_ai_receipt_makerApp.swift`: アプリのエントリーポイント。`@main`属性でマークされ、`WindowGroup`でメインビューをラップ
   - `ContentView.swift`: メインのUI実装。現在は基本的なHello Worldテンプレート

2. **テスト構造**
   - Swift Testing Framework（`import Testing`）を使用
   - `@Test`属性でテストメソッドをマーク
   - `#expect(...)`マクロで期待値の検証

## 開発時の注意点

1. **新しいビューやモデルを追加する場合**
   - SwiftUIのベストプラクティスに従い、`View`プロトコルに準拠した構造体として実装
   - プレビューは`#Preview`マクロを使用

2. **テストを追加する場合**
   - `app036_ai_receipt_makerTests`ディレクトリに配置
   - Swift Testing Frameworkの`@Test`属性を使用
   - 非同期テストには`async throws`を使用

3. **アセットの管理**
   - 画像やアイコンは`Assets.xcassets`に追加
   - カラーセットも同様に`Assets.xcassets`で管理

## 今後の開発指針

このプロジェクトはAIレシート作成アプリとして以下の機能が想定されます：
- レシート画像の認識とデータ抽出
- レシートデータの管理と保存
- カテゴリ分類と集計機能
- エクスポート機能

新機能を追加する際は、SwiftUIの宣言的UIパラダイムに従い、適切なビューモデル（`@StateObject`、`@ObservedObject`）を使用してデータフローを管理してください。