import SwiftUI
import RevenueCat

/// ペイウォール表示方式の定義
public enum PaywallPresentationMode {
    case embedded    // 直接表示（既にシート内や画面に埋め込む場合）
    case sheet      // 新しいシートで表示（独立したモーダル表示）
}

/// ペイウォール表示のための設定構造体
/// 他のアプリでも流用できるよう、カスタマイズ可能な項目を定義
public struct PaywallConfiguration {
    
    // MARK: - Core Configuration
    
    /// RevenueCatのAPIキー
    public let revenueCatAPIKey: String
    
    /// プレミアム機能のエンタイトルメントキー
    public let premiumEntitlementKey: String
    
    /// 代替エンタイトルメントキー（複数対応）
    public let alternativeEntitlementKeys: [String]
    
    // MARK: - UI Configuration
    
    /// ペイウォールのテーマ設定
    public let theme: PaywallTheme
    
    /// 閉じるボタンを表示するか
    public let showCloseButton: Bool
    
    /// スキップボタンを表示するか（デバッグ用）
    public let showSkipButton: Bool
    
    /// ローディング時の表示テキスト
    public let loadingText: String
    
    /// スキップボタンのテキスト
    public let skipButtonText: String
    
    /// ペイウォールの表示方式
    public let presentationMode: PaywallPresentationMode
    
    // MARK: - Behavior Configuration
    
    /// ペイウォール表示前の遅延時間（秒）
    public let displayDelay: TimeInterval
    
    /// デバッグモード（詳細ログ出力）
    public let debugMode: Bool
    
    
    // MARK: - Initializers
    
    /// デフォルト設定で初期化
    public init(
        revenueCatAPIKey: String,
        premiumEntitlementKey: String = "premium_features",
        alternativeEntitlementKeys: [String] = ["premium", "Premium", "pro", "Pro", "premium_features", "unlimited_books", "reading_premium"],
        theme: PaywallTheme = .default,
        showCloseButton: Bool = true,
        showSkipButton: Bool = false,
        loadingText: String = "Loading Premium Features...",
        skipButtonText: String = "Continue with Basic Features",
        presentationMode: PaywallPresentationMode = .sheet,
        displayDelay: TimeInterval = 1.0,
        debugMode: Bool = false
    ) {
        self.revenueCatAPIKey = revenueCatAPIKey
        self.premiumEntitlementKey = premiumEntitlementKey
        self.alternativeEntitlementKeys = alternativeEntitlementKeys
        self.theme = theme
        self.showCloseButton = showCloseButton
        self.showSkipButton = showSkipButton
        self.loadingText = loadingText
        self.skipButtonText = skipButtonText
        self.presentationMode = presentationMode
        self.displayDelay = displayDelay
        self.debugMode = debugMode
    }
    
    /// 全てのエンタイトルメントキーを取得（メイン + 代替）
    public var allEntitlementKeys: [String] {
        return [premiumEntitlementKey] + alternativeEntitlementKeys
    }
}

// MARK: - PaywallTheme

/// ペイウォールのテーマ設定
public struct PaywallTheme {
    
    /// 背景スタイル
    public let backgroundStyle: BackgroundStyle
    
    /// プライマリーカラー
    public let primaryColor: Color
    
    /// セカンダリーカラー
    public let secondaryColor: Color
    
    /// テキストカラー
    public let textColor: Color
    
    /// フォント設定
    public let fontConfiguration: FontConfiguration
    
    public init(
        backgroundStyle: BackgroundStyle = .gradient([Color.blue.opacity(0.2), Color.indigo.opacity(0.4), Color.purple.opacity(0.3)]),
        primaryColor: Color = .white,
        secondaryColor: Color = .blue,
        textColor: Color = .white,
        fontConfiguration: FontConfiguration = .default
    ) {
        self.backgroundStyle = backgroundStyle
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.textColor = textColor
        self.fontConfiguration = fontConfiguration
    }
    
    /// デフォルトテーマ
    public static let `default` = PaywallTheme()
    
    /// ライトテーマ
    public static let light = PaywallTheme(
        backgroundStyle: .solid(.white),
        primaryColor: .black,
        secondaryColor: .blue,
        textColor: .black
    )
    
    /// ダークテーマ
    public static let dark = PaywallTheme(
        backgroundStyle: .solid(.black),
        primaryColor: .white,
        secondaryColor: .blue,
        textColor: .white
    )
    
    /// 読書アプリ専用テーマ
    public static let reading = PaywallTheme(
        backgroundStyle: .gradient([Color.blue.opacity(0.1), Color.indigo.opacity(0.3), Color.purple.opacity(0.2)]),
        primaryColor: .white,
        secondaryColor: .blue,
        textColor: .white,
        fontConfiguration: FontConfiguration(
            titleFont: .title.weight(.semibold),
            bodyFont: .body,
            buttonFont: .headline.weight(.medium)
        )
    )
    
    /// レシートアプリ専用テーマ
    public static let receipt = PaywallTheme(
        backgroundStyle: .gradient([Color.green.opacity(0.2), Color.teal.opacity(0.3), Color.mint.opacity(0.2)]),
        primaryColor: .white,
        secondaryColor: .green,
        textColor: .white,
        fontConfiguration: FontConfiguration(
            titleFont: .title.weight(.bold),
            bodyFont: .body,
            buttonFont: .headline.weight(.semibold)
        )
    )
}

// MARK: - BackgroundStyle

/// 背景スタイルの定義
public enum BackgroundStyle {
    case solid(Color)
    case gradient([Color])
    case image(String) // アセット名
    
    /// SwiftUIのViewに変換
    @ViewBuilder
    public func makeView() -> some View {
        switch self {
        case .solid(let color):
            color.ignoresSafeArea()
        case .gradient(let colors):
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        case .image(let imageName):
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        }
    }
}

// MARK: - FontConfiguration

/// フォント設定
public struct FontConfiguration {
    public let titleFont: Font
    public let bodyFont: Font
    public let buttonFont: Font
    
    public init(
        titleFont: Font = .title,
        bodyFont: Font = .body,
        buttonFont: Font = .headline
    ) {
        self.titleFont = titleFont
        self.bodyFont = bodyFont
        self.buttonFont = buttonFont
    }
    
    /// デフォルトフォント設定
    public static let `default` = FontConfiguration()
}