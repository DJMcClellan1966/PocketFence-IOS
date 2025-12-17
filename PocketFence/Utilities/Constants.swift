//
//  Constants.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import SwiftUI

/// App-wide constants
enum Constants {
    
    // MARK: - App Information
    
    enum App {
        static let name = "PocketFence"
        static let bundleIdentifier = "com.pocketfence.ios"
        static let appGroupIdentifier = "group.com.pocketfence.ios"
        static let networkExtensionIdentifier = "com.pocketfence.ios.NetworkExtension"
    }
    
    // MARK: - Network Extension
    
    enum NetworkExtension {
        static let providerBundleIdentifier = "com.pocketfence.ios.NetworkExtension"
        static let serverAddress = "PocketFence"
        static let localizedDescription = "PocketFence Content Filter"
    }
    
    // MARK: - UserDefaults Keys
    
    enum UserDefaultsKeys {
        static let devices = "pocketfence.devices"
        static let blockedSites = "pocketfence.blockedSites"
        static let timeLimits = "pocketfence.timeLimits"
        static let quietHours = "pocketfence.quietHours"
        static let settings = "pocketfence.settings"
        static let statistics = "pocketfence.statistics"
        static let isPremium = "pocketfence.isPremium"
        static let lastSyncDate = "pocketfence.lastSyncDate"
    }
    
    // MARK: - Shared App Group Keys
    
    enum SharedKeys {
        static let blockedDomains = "blockedDomains"
        static let blockedIPs = "blockedIPs"
        static let totalBlockedAttempts = "totalBlockedAttempts"
        static let isProtectionEnabled = "isProtectionEnabled"
    }
    
    // MARK: - In-App Purchase
    
    enum IAP {
        static let premiumProductID = "com.pocketfence.premium"
    }
    
    // MARK: - AdMob
    
    enum AdMob {
        // Test IDs - Replace with real IDs in production
        static let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
        static let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"
        
        // Production IDs (to be configured)
        static let productionBannerID = "YOUR_BANNER_AD_UNIT_ID"
        static let productionInterstitialID = "YOUR_INTERSTITIAL_AD_UNIT_ID"
    }
    
    // MARK: - URLs
    
    enum URLs {
        static let privacyPolicy = URL(string: "https://pocketfence.app/privacy")!
        static let termsOfService = URL(string: "https://pocketfence.app/terms")!
        static let support = URL(string: "https://pocketfence.app/support")!
        static let website = URL(string: "https://pocketfence.app")!
    }
    
    // MARK: - Contact
    
    enum Contact {
        static let supportEmail = "support@pocketfence.app"
    }
    
    // MARK: - Defaults
    
    enum Defaults {
        static let defaultTimeLimit = 120 // minutes
        static let minimumTimeLimit = 30 // minutes
        static let maximumTimeLimit = 480 // minutes (8 hours)
        static let defaultQuietHoursStart = 22 // 10 PM
        static let defaultQuietHoursEnd = 7 // 7 AM
        static let scanInterval: TimeInterval = 30 // seconds
        static let statisticsRetentionDays = 30
    }
    
    // MARK: - Notifications
    
    enum Notifications {
        static let deviceBlocked = "deviceBlocked"
        static let siteBlocked = "siteBlocked"
        static let timeLimitExceeded = "timeLimitExceeded"
        static let quietHoursStarted = "quietHoursStarted"
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let defaultDuration: TimeInterval = 0.3
        static let springResponse: Double = 0.5
        static let springDamping: Double = 0.7
    }
}

// MARK: - Theme Colors

extension Color {
    static let pocketFenceBlue = Color(red: 0.0, green: 0.48, blue: 0.92)
    static let pocketFenceGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let pocketFenceRed = Color(red: 0.92, green: 0.26, blue: 0.21)
    static let pocketFenceOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
}

// MARK: - SF Symbols

enum SFSymbol {
    static let shield = "shield.fill"
    static let device = "iphone.and.ipad"
    static let blockedSite = "hand.raised.fill"
    static let timeLimit = "clock.fill"
    static let settings = "gear"
    static let premium = "star.circle.fill"
    static let statistics = "chart.bar.fill"
    static let notification = "bell.fill"
    static let protection = "checkmark.shield.fill"
}
