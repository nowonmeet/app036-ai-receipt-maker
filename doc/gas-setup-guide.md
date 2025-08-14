# GAS フィードバックフォーム セットアップガイド

## 1. Google Apps Script プロジェクト作成

1. [Google Apps Script](https://script.google.com/) にアクセス
2. 「新しいプロジェクト」をクリック
3. プロジェクト名を「AIReceiptMaker-Feedback」に変更

## 2. スプレッドシート準備

1. [Google Sheets](https://sheets.google.com/) で新しいスプレッドシートを作成
2. スプレッドシート名を「AI Receipt Maker フィードバック」に変更
3. スプレッドシートのURLからIDを取得（例：`1ABC...XYZ`の部分）

## 3. GASコード設定

1. `feedback-form.gs` の内容を Apps Script エディタに貼り付け
2. `SPREADSHEET_ID` の値を実際のスプレッドシートIDに変更：
   ```javascript
   const SPREADSHEET_ID = '1ABC...XYZ'; // ここを変更
   ```

## 4. 権限設定とデプロイ

1. コードエディタで「保存」をクリック
2. 「デプロイ」→「新しいデプロイ」をクリック
3. 設定：
   - 種類：ウェブアプリ
   - 説明：AI Receipt Maker フィードバック API
   - 実行ユーザー：自分
   - アクセス：全員（匿名ユーザーを含む）
4. 「デプロイ」をクリック
5. ウェブアプリのURLをコピー（これがAPI エンドポイント）

## 5. テスト実行

1. Apps Script エディタで `testFeedback` 関数を実行
2. 権限の承認を行う
3. スプレッドシートにテストデータが追加されることを確認

## 6. iOSアプリでの使用

取得したウェブアプリURLを使って、iOSアプリからPOSTリクエストを送信：

```swift
let url = URL(string: "YOUR_WEB_APP_URL")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let feedbackData = [
    "problemType": "不適切な画像",
    "description": "具体的な問題の説明",
    "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
    "deviceInfo": UIDevice.current.systemName + " " + UIDevice.current.systemVersion
]

request.httpBody = try? JSONSerialization.data(withJSONObject: feedbackData)
```

## フィードバック項目

- **problemType**: 問題の種類（不適切な画像、技術的問題、その他）
- **description**: 詳細説明
- **email**: 連絡先（任意）
- **appVersion**: アプリバージョン
- **deviceInfo**: デバイス情報
- **receiptId**: 関連するレシートID（任意）
- **severity**: 重要度（low, medium, high）

## 注意事項

- スプレッドシートIDは機密情報として管理
- API URLも適切に管理する
- 定期的にフィードバックデータを確認・対応する