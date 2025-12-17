# PocketFence iOS - Monetization Guide

Complete guide for implementing in-app purchases and advertisements in PocketFence.

## 💰 Monetization Strategy

PocketFence uses a **freemium model** with two revenue streams:

1. **Advertisements** (Free users)
2. **Premium Upgrade** (One-time purchase)

## 📱 In-App Purchases (StoreKit 2)

### Overview

PocketFence uses StoreKit 2 for in-app purchases, providing:
- Simple integration
- Async/await support
- Automatic receipt validation
- Family Sharing support
- Restore purchases functionality

### Setting Up App Store Connect

#### 1. Create App ID

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **My Apps** → **+** → **New App**
3. Fill in app information:
   - Platform: iOS
   - Name: PocketFence
   - Primary Language: English
   - Bundle ID: com.yourcompany.pocketfence
   - SKU: POCKETFENCE_IOS_001

#### 2. Enable In-App Purchases

1. In your app page, go to **Features** → **In-App Purchases**
2. Click **+** to create new in-app purchase

#### 3. Configure Premium Product

**Product Information:**
- Reference Name: `Premium Upgrade`
- Product ID: `com.pocketfence.premium`
- Type: **Non-Consumable**

**Pricing:**
- Price: $4.99 USD (Tier 5)
- Or set custom pricing for different regions

**Localization (English):**
- Display Name: `Premium`
- Description: `Unlock all premium features: ad-free experience, advanced statistics, priority support, and more!`

**Review Information:**
- Screenshot: Upload app screenshot showing premium features
- Review Notes: Explain what premium unlocks

#### 4. Submit for Review

- Submit the in-app purchase for review
- It can be reviewed separately or with your app
- Apple typically reviews within 24-48 hours

### Code Implementation

#### 1. Configure Product ID

In `Constants.swift`:
```swift
enum IAP {
    static let premiumProductID = "com.pocketfence.premium"
}
```

#### 2. Create Store Manager

Create `StoreManager.swift`:
```swift
import StoreKit
import Combine

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs = Set<String>()
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    @MainActor
    func requestProducts() async {
        do {
            let productIDs = [Constants.IAP.premiumProductID]
            products = try await Product.products(for: productIDs)
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
            
        case .userCancelled, .pending:
            return nil
            
        @unknown default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    @MainActor
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.revocationDate == nil {
                    purchasedProductIDs.insert(transaction.productID)
                } else {
                    purchasedProductIDs.remove(transaction.productID)
                }
            } catch {
                print("Failed to verify transaction")
            }
        }
    }
    
    func restore() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
    }
    
    var isPremium: Bool {
        purchasedProductIDs.contains(Constants.IAP.premiumProductID)
    }
}

enum StoreError: Error {
    case failedVerification
}
```

#### 3. Update SettingsViewModel

```swift
class SettingsViewModel: ObservableObject {
    @Published var isPremium = false
    
    private let storeManager = StoreManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        storeManager.$purchasedProductIDs
            .map { $0.contains(Constants.IAP.premiumProductID) }
            .assign(to: &$isPremium)
    }
    
    func purchasePremium() async {
        guard let product = storeManager.products.first else { return }
        
        do {
            if let _ = try await storeManager.purchase(product) {
                settingsRepo.setPremiumStatus(true)
                successMessage = "Premium unlocked!"
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }
    
    func restorePurchases() async {
        do {
            try await storeManager.restore()
            if storeManager.isPremium {
                settingsRepo.setPremiumStatus(true)
                successMessage = "Premium restored!"
            } else {
                errorMessage = "No previous purchases found"
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }
}
```

### Testing In-App Purchases

#### Sandbox Testing

1. **Create Sandbox Tester Account:**
   - App Store Connect → Users and Access → Sandbox Testers
   - Create test account with unique email
   - Use this account for testing purchases

2. **Test on Device:**
   - Install app from Xcode
   - Attempt purchase
   - Sign in with sandbox account when prompted
   - Test successful purchase
   - Test restore purchases
   - Test cancelled purchase

3. **Reset Sandbox:**
   - Settings → App Store → Sandbox Account
   - Sign out to reset purchases
   - Test again with fresh state

#### Production Testing

1. Use TestFlight for beta testing
2. Create promotional codes for testing
3. Test with real credit card (refundable)

### Common Issues

**Purchase Not Completing:**
- Check internet connection
- Verify product ID matches App Store Connect
- Ensure app is signed correctly
- Check StoreKit configuration

**Receipt Validation Failing:**
- StoreKit 2 handles this automatically
- No need for server-side validation
- Trust Apple's verification

**Restore Not Working:**
- Ensure same Apple ID is used
- Call `AppStore.sync()` before checking
- Check Transaction.currentEntitlements

## 📢 Advertisement Integration (AdMob)

### Setting Up AdMob

#### 1. Create AdMob Account

1. Go to [AdMob](https://admob.google.com)
2. Sign in with Google account
3. Create new app:
   - Platform: iOS
   - App name: PocketFence
   - Add to AdMob

#### 2. Create Ad Units

**Banner Ad:**
- Format: Banner
- Name: Dashboard Banner
- Copy Ad Unit ID (e.g., ca-app-pub-xxxxx/yyyyy)

**Interstitial Ad:**
- Format: Interstitial
- Name: Settings Interstitial
- Copy Ad Unit ID

#### 3. Update Info.plist

Add GADApplicationIdentifier:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxx~yyyyyyyy</string>
```

### Installing Google Mobile Ads SDK

#### Using CocoaPods

Add to `Podfile`:
```ruby
platform :ios, '15.0'

target 'PocketFence' do
  use_frameworks!
  pod 'Google-Mobile-Ads-SDK', '~> 10.0'
end
```

Install:
```bash
pod install
```

#### Using Swift Package Manager

1. File → Add Packages
2. URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`
3. Version: Up to Next Major (10.0.0)

### Code Implementation

#### 1. Initialize AdMob

In `AppDelegate.swift`:
```swift
import GoogleMobileAds

func application(_ application: UIApplication, 
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Initialize Google Mobile Ads SDK
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    
    // Configure request configuration
    let requestConfiguration = GADMobileAds.sharedInstance().requestConfiguration
    requestConfiguration.testDeviceIdentifiers = [GADSimulatorID]
    
    return true
}
```

#### 2. Update AdService

```swift
import GoogleMobileAds

class AdService: NSObject, ObservableObject {
    static let shared = AdService()
    
    @Published var canShowAds = true
    @Published var isBannerLoaded = false
    
    private var interstitialAd: GADInterstitialAd?
    
    // Use test IDs during development
    #if DEBUG
    private let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
    #else
    private let bannerAdUnitID = Constants.AdMob.productionBannerID
    private let interstitialAdUnitID = Constants.AdMob.productionInterstitialID
    #endif
    
    override init() {
        super.init()
        setupAds()
    }
    
    func setupAds() {
        updateAdStatus()
        loadInterstitialAd()
    }
    
    func loadInterstitialAd() {
        guard canShowAds else { return }
        
        let request = GADRequest()
        GADInterstitialAd.load(
            withAdUnitID: interstitialAdUnitID,
            request: request
        ) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial: \(error.localizedDescription)")
                return
            }
            self?.interstitialAd = ad
            self?.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    func showInterstitialAd(from viewController: UIViewController) {
        guard canShowAds, let interstitialAd = interstitialAd else {
            return
        }
        
        interstitialAd.present(fromRootViewController: viewController)
    }
    
    func createBannerView() -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = bannerAdUnitID
        bannerView.rootViewController = UIApplication.shared.keyWindow?.rootViewController
        bannerView.load(GADRequest())
        bannerView.delegate = self
        return bannerView
    }
}

// MARK: - GADFullScreenContentDelegate
extension AdService: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadInterstitialAd()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        loadInterstitialAd()
    }
}

// MARK: - GADBannerViewDelegate
extension AdService: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        isBannerLoaded = true
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner failed to load: \(error.localizedDescription)")
    }
}
```

#### 3. SwiftUI Banner View

```swift
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    func makeUIView(context: Context) -> GADBannerView {
        return AdService.shared.createBannerView()
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // No updates needed
    }
}
```

#### 4. Use in Views

```swift
struct DashboardView: View {
    @StateObject private var adService = AdService.shared
    
    var body: some View {
        ScrollView {
            // Content
            
            if adService.canShowAds {
                BannerAdView()
                    .frame(height: 50)
            }
        }
    }
}
```

### Ad Frequency Management

Implement frequency capping to improve user experience:

```swift
class AdService {
    private let interstitialFrequency: TimeInterval = 300 // 5 minutes
    private var lastInterstitialTime: Date?
    
    func shouldShowInterstitial() -> Bool {
        guard canShowAds else { return false }
        
        if let lastTime = lastInterstitialTime {
            let timeSince = Date().timeIntervalSince(lastTime)
            return timeSince >= interstitialFrequency
        }
        
        return true
    }
    
    func showInterstitialIfReady(from viewController: UIViewController) {
        guard shouldShowInterstitial() else { return }
        
        showInterstitialAd(from: viewController)
        lastInterstitialTime = Date()
    }
}
```

## 📊 Analytics

Track monetization metrics:

```swift
enum AnalyticsEvent {
    case premiumPurchaseAttempted
    case premiumPurchaseCompleted
    case premiumPurchaseCancelled
    case premiumPurchaseFailed
    case premiumRestored
    case adShown(type: String)
    case adClicked(type: String)
}
```

## 💡 Best Practices

### In-App Purchases

1. **Clear Value Proposition**: Explain what premium includes
2. **Easy Restore**: Make restore button visible
3. **No Surprises**: No subscriptions unless clearly stated
4. **Family Sharing**: Enable for better value
5. **Test Thoroughly**: Test all purchase flows

### Advertisements

1. **Non-Intrusive**: Don't interrupt user flow
2. **Frequency Capping**: Limit ad display frequency
3. **Strategic Placement**: Bottom of screens, between actions
4. **Easy Upgrade**: Make premium upgrade visible but not annoying
5. **Respect Premium**: Never show ads to premium users

### Legal Requirements

1. **Privacy Policy**: Disclose ad tracking
2. **Terms of Service**: Clear refund policy
3. **Age Restrictions**: Consider COPPA compliance
4. **GDPR/CCPA**: Handle EU/California users appropriately
5. **App Store Guidelines**: Follow Apple's rules

## 🧪 Testing Checklist

- [ ] Sandbox purchase works
- [ ] Real purchase works (TestFlight)
- [ ] Restore works correctly
- [ ] Premium status persists
- [ ] Ads removed for premium users
- [ ] Banner ads display correctly
- [ ] Interstitial ads show at right time
- [ ] Frequency capping works
- [ ] Test with poor network
- [ ] Test purchase cancellation
- [ ] Test multiple devices
- [ ] Test Family Sharing

## 🚀 Launch Preparation

1. **Replace Test Ad IDs** with production IDs
2. **Test real purchases** via TestFlight
3. **Set up analytics** for tracking
4. **Create promo codes** for influencers/reviewers
5. **Prepare marketing** materials
6. **Monitor metrics** after launch

---

For implementation questions, refer to:
- [Apple StoreKit Documentation](https://developer.apple.com/documentation/storekit)
- [Google AdMob iOS Documentation](https://developers.google.com/admob/ios)
