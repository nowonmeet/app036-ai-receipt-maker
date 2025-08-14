/**
 * フィードバックフォーム用 Google Apps Script
 * AI生成画像に対するユーザーフィードバックを収集
 */

// 設定: スプレッドシートIDを設定してください
const SPREADSHEET_ID = 'YOUR_SPREADSHEET_ID_HERE';
const SHEET_NAME = 'フィードバック';

/**
 * フィードバックを受信してスプレッドシートに記録
 */
function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    
    // フィードバックデータを取得
    const feedback = {
      timestamp: new Date(),
      problemType: data.problemType || '',
      description: data.description || '',
      email: data.email || '',
      appVersion: data.appVersion || '',
      deviceInfo: data.deviceInfo || '',
      receiptId: data.receiptId || '',
      severity: data.severity || 'medium'
    };
    
    // スプレッドシートに記録
    recordFeedback(feedback);
    
    // 成功レスポンス
    return ContentService
      .createTextOutput(JSON.stringify({
        status: 'success',
        message: 'フィードバックを受信しました'
      }))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch (error) {
    console.error('フィードバック処理エラー:', error);
    
    // エラーレスポンス
    return ContentService
      .createTextOutput(JSON.stringify({
        status: 'error',
        message: 'フィードバックの処理に失敗しました'
      }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * GET リクエスト対応（テスト用）
 */
function doGet(e) {
  return ContentService
    .createTextOutput(JSON.stringify({
      status: 'ok',
      message: 'AI Receipt Maker フィードバックAPI'
    }))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * スプレッドシートにフィードバックデータを記録
 */
function recordFeedback(feedback) {
  const spreadsheet = SpreadsheetApp.openById(SPREADSHEET_ID);
  let sheet = spreadsheet.getSheetByName(SHEET_NAME);
  
  // シートが存在しない場合は作成
  if (!sheet) {
    sheet = spreadsheet.insertSheet(SHEET_NAME);
    
    // ヘッダー行を追加
    const headers = [
      '受信日時',
      '問題の種類',
      '詳細説明',
      'メールアドレス',
      'アプリバージョン',
      'デバイス情報',
      'レシートID',
      '重要度',
      '対応状況'
    ];
    sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    
    // ヘッダー行のスタイル設定
    const headerRange = sheet.getRange(1, 1, 1, headers.length);
    headerRange.setBackground('#4285F4');
    headerRange.setFontColor('white');
    headerRange.setFontWeight('bold');
    sheet.setFrozenRows(1);
  }
  
  // データを追加
  const row = [
    feedback.timestamp,
    feedback.problemType,
    feedback.description,
    feedback.email,
    feedback.appVersion,
    feedback.deviceInfo,
    feedback.receiptId,
    feedback.severity,
    '未対応'
  ];
  
  sheet.appendRow(row);
  
  // 自動リサイズ
  sheet.autoResizeColumns(1, sheet.getLastColumn());
}

/**
 * フィードバック統計情報を取得
 */
function getFeedbackStats() {
  try {
    const spreadsheet = SpreadsheetApp.openById(SPREADSHEET_ID);
    const sheet = spreadsheet.getSheetByName(SHEET_NAME);
    
    if (!sheet || sheet.getLastRow() <= 1) {
      return {
        total: 0,
        byType: {},
        bySeverity: {},
        recent: 0
      };
    }
    
    const data = sheet.getDataRange().getValues();
    const feedbacks = data.slice(1); // ヘッダーを除く
    
    // 統計情報を計算
    const stats = {
      total: feedbacks.length,
      byType: {},
      bySeverity: {},
      recent: 0 // 過去7日間
    };
    
    const oneWeekAgo = new Date();
    oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
    
    feedbacks.forEach(row => {
      const timestamp = new Date(row[0]);
      const problemType = row[1];
      const severity = row[7];
      
      // タイプ別カウント
      stats.byType[problemType] = (stats.byType[problemType] || 0) + 1;
      
      // 重要度別カウント
      stats.bySeverity[severity] = (stats.bySeverity[severity] || 0) + 1;
      
      // 最近のフィードバック
      if (timestamp >= oneWeekAgo) {
        stats.recent++;
      }
    });
    
    return stats;
    
  } catch (error) {
    console.error('統計情報取得エラー:', error);
    throw error;
  }
}

/**
 * テスト用関数
 */
function testFeedback() {
  const testData = {
    problemType: '不適切な画像',
    description: 'テスト用のフィードバックです',
    email: 'test@example.com',
    appVersion: '1.0.0',
    deviceInfo: 'iPhone 15, iOS 17.0',
    receiptId: 'test_receipt_001',
    severity: 'high'
  };
  
  const feedback = {
    timestamp: new Date(),
    ...testData
  };
  
  recordFeedback(feedback);
  console.log('テストフィードバックを記録しました');
}