//
//  Constants.swift
//  ScreenBalance
//
//  Created on 2025
//  Copyright © 2025 ScreenBalance. All rights reserved.
//

import Foundation
import SwiftUI

/// App-wide constants
enum Constants {
    
    // MARK: - App Information
    
    enum App {
        static let name = "ScreenBalance"
        static let tagline = "Your Digital Wellness Coach"
        static let bundleIdentifier = "com.screenbalance.ios"
        static let appGroupIdentifier = "group.com.screenbalance.ios"
        static let networkExtensionIdentifier = "com.screenbalance.ios.NetworkExtension"
    }
    
    // MARK: - Network Extension
    
    enum NetworkExtension {
        static let providerBundleIdentifier = "com.screenbalance.ios.NetworkExtension"
        static let serverAddress = "ScreenBalance"
        static let localizedDescription = "ScreenBalance Wellness Monitor"
    }
    
    // MARK: - UserDefaults Keys
    
    enum UserDefaultsKeys {
        static let devices = "screenbalance.devices"
        static let blockedSites = "screenbalance.blockedSites"
        static let timeLimits = "screenbalance.timeLimits"
        static let quietHours = "screenbalance.quietHours"
        static let settings = "screenbalance.settings"
        static let statistics = "screenbalance.statistics"
        static let isPremium = "screenbalance.isPremium"
        static let lastSyncDate = "screenbalance.lastSyncDate"
        static let wellnessScore = "screenbalance.wellnessScore"
        static let focusSessions = "screenbalance.focusSessions"
        static let insights = "screenbalance.insights"
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
        static let premiumProductID = "com.screenbalance.premium"
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
        static let privacyPolicy = URL(string: "https://screenbalance.app/privacy")!
        static let termsOfService = URL(string: "https://screenbalance.app/terms")!
        static let support = URL(string: "https://screenbalance.app/support")!
        static let website = URL(string: "https://screenbalance.app")!
    }
    
    // MARK: - Contact
    
    enum Contact {
        static let supportEmail = "support@screenbalance.app"
    }
    
    // MARK: - Wellness
    
    enum Wellness {
        static let optimalScore = 80
        static let goodScore = 60
        static let moderateScore = 40
        static let lowScore = 20
        static let breakReminderInterval: TimeInterval = 2700 // 45 minutes
        static let defaultFocusDuration: TimeInterval = 1500 // 25 minutes
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
    // Primary wellness colors
    static let wellnessPrimary = Color(red: 0.4, green: 0.6, blue: 1.0)  // Calm blue
    static let wellnessGreen = Color(red: 0.2, green: 0.78, blue: 0.35)  // Healthy green
    static let wellnessOrange = Color(red: 1.0, green: 0.58, blue: 0.0)  // Warning orange
    static let wellnessRed = Color(red: 0.92, green: 0.26, blue: 0.21)   // Alert red
    static let wellnessPurple = Color(red: 0.6, green: 0.4, blue: 0.9)   // Focus purple
    
    // Legacy colors (for compatibility)
    static let pocketFenceBlue = Color(red: 0.0, green: 0.48, blue: 0.92)
    static let pocketFenceGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let pocketFenceRed = Color(red: 0.92, green: 0.26, blue: 0.21)
    static let pocketFenceOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    
    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
}

// MARK: - SF Symbols

enum SFSymbol {
    // Wellness-focused symbols
    static let wellness = "heart.circle.fill"
    static let energy = "bolt.circle.fill"
    static let focus = "target"
    static let break_symbol = "pause.circle.fill"
    static let insight = "lightbulb.fill"
    static let balance = "scale.3d"
    
    // Legacy symbols (for compatibility)
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
