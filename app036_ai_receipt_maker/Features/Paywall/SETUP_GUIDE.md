# Reading Progress App - RevenueCat Setup Guide

## 🚨 Required Setup Steps

### 1. Add RevenueCat SDK Dependencies

Add RevenueCat packages to your project:
- `RevenueCat` (~> 5.26.0)
- `RevenueCatUI` (~> 5.26.0)

### 2. Get Your RevenueCat API Key

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Navigate to your project
3. Go to **API Keys** section
4. Copy your **Public API Key** (starts with `appl_`)

### 3. Update API Key in Code

Replace the placeholder API key in two files:

#### File 1: `app034_read_progreApp.swift`
```swift
Purchases.configure(withAPIKey: "YOUR_ACTUAL_API_KEY_HERE")
```

#### File 2: `UniversalPaywallManager.swift`
```swift
revenueCatAPIKey: "YOUR_ACTUAL_API_KEY_HERE",
```

### 4. Configure Entitlements and Products

Based on your RevenueCat dashboard:
- **Offering ID**: `premium_plan_and_free`
- **Product ID**: `prod5979951f23`
- **App ID**: `app1c56eab3ec`

Update the entitlement key if needed in `UniversalPaywallManager.swift`:
```swift
premiumEntitlementKey: "premium_features", // Update this if your entitlement name is different
```

### 5. Configure Products in App Store Connect

Make sure you have created the in-app purchase products in App Store Connect that match your RevenueCat configuration.

## 🎯 Testing

1. Use a real device (not simulator) for testing purchases
2. Create sandbox test accounts in App Store Connect
3. Set `debugMode: true` in `UniversalPaywallManager` for debugging

## ⚠️ Common Issues

### "No such module 'RevenueCat'"
- Make sure you've added RevenueCat SDK to your project dependencies

### "Purchases has not been configured"
- Ensure RevenueCat is initialized in `app034_read_progreApp.swift` init method

### "Invalid API Key"
- Double-check your API key from RevenueCat Dashboard
- Make sure it starts with `appl_`

## 📝 Production Checklist

- [ ] Replace placeholder API keys with real ones
- [ ] Set `debugMode: false` in `UniversalPaywallManager`
- [ ] Remove `Purchases.logLevel = .debug` from App init
- [ ] Test with real products and sandbox accounts
- [ ] Verify entitlement names match RevenueCat configuration