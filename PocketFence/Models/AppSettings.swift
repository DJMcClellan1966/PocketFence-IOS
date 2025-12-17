//
//  AppSettings.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation

/// App-wide settings and preferences
struct AppSettings: Codable, Equatable {
    var isPremium: Bool
    var isProtectionEnabled: Bool
    var showAds: Bool
    var notificationsEnabled: Bool
    var soundEnabled: Bool
    var blockingMode: BlockingMode
    var theme: AppTheme
    var lastBackupDate: Date?
    
    init(
        isPremium: Bool = false,
        isProtectionEnabled: Bool = true,
        showAds: Bool = true,
        notificationsEnabled: Bool = true,
        soundEnabled: Bool = true,
        blockingMode: BlockingMode = .strict,
        theme: AppTheme = .system,
        lastBackupDate: Date? = nil
    ) {
        self.isPremium = isPremium
        self.isProtectionEnabled = isProtectionEnabled
        self.showAds = !isPremium && showAds
        self.notificationsEnabled = notificationsEnabled
        self.soundEnabled = soundEnabled
        self.blockingMode = blockingMode
        self.theme = theme
        self.lastBackupDate = lastBackupDate
    }
}

/// Blocking mode configuration
enum BlockingMode: String, Codable, CaseIterable {
    case strict = "Strict"
    case moderate = "Moderate"
    case permissive = "Permissive"
    
    var description: String {
        switch self {
        case .strict:
            return "Block all configured sites and categories"
        case .moderate:
            return "Block explicit content, allow educational sites"
        case .permissive:
            return "Only block explicit adult content"
        }
    }
}

/// App theme options
enum AppTheme: String, Codable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var description: String {
        switch self {
        case .system:
            return "Follow system appearance"
        case .light:
            return "Always use light mode"
        case .dark:
            return "Always use dark mode"
        }
    }
}

// MARK: - Sample Data
extension AppSettings {
    static let sample = AppSettings(
        isPremium: false,
        isProtectionEnabled: true,
        notificationsEnabled: true,
        blockingMode: .strict,
        theme: .system
    )
    
    static let premiumSample = AppSettings(
        isPremium: true,
        isProtectionEnabled: true,
        showAds: false,
        notificationsEnabled: true,
        blockingMode: .strict,
        theme: .dark
    )
}
