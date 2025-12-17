//
//  SettingsRepository.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Combine
import Observation

/// Repository for managing app settings
@Observable
class SettingsRepository {
    static let shared = SettingsRepository()
    
    private(set) var settings: AppSettings
    private(set) var statistics: Statistics
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "pocketfence.settings"
    private let statisticsKey = "pocketfence.statistics"
    
    private init() {
        self.settings = Self.loadSettings()
        self.statistics = Self.loadStatistics()
    }
    
    // MARK: - Settings
    
    /// Load settings from storage
    private static func loadSettings() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: "pocketfence.settings"),
              let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return decoded
    }
    
    /// Save settings to storage
    func saveSettings() {
        guard let encoded = try? JSONEncoder().encode(settings) else { return }
        userDefaults.set(encoded, forKey: settingsKey)
    }
    
    /// Update settings
    func updateSettings(_ newSettings: AppSettings) {
        settings = newSettings
        saveSettings()
    }
    
    /// Toggle protection enabled
    func toggleProtection() {
        settings.isProtectionEnabled.toggle()
        saveSettings()
    }
    
    /// Set premium status
    func setPremiumStatus(_ isPremium: Bool) {
        settings.isPremium = isPremium
        settings.showAds = !isPremium
        saveSettings()
    }
    
    /// Toggle notifications
    func toggleNotifications() {
        settings.notificationsEnabled.toggle()
        saveSettings()
    }
    
    /// Toggle sound
    func toggleSound() {
        settings.soundEnabled.toggle()
        saveSettings()
    }
    
    /// Set blocking mode
    func setBlockingMode(_ mode: BlockingMode) {
        settings.blockingMode = mode
        saveSettings()
    }
    
    /// Set theme
    func setTheme(_ theme: AppTheme) {
        settings.theme = theme
        saveSettings()
    }
    
    // MARK: - Statistics
    
    /// Load statistics from storage
    private static func loadStatistics() -> Statistics {
        guard let data = UserDefaults.standard.data(forKey: "pocketfence.statistics"),
              let decoded = try? JSONDecoder().decode(Statistics.self, from: data) else {
            return Statistics()
        }
        return decoded
    }
    
    /// Save statistics to storage
    func saveStatistics() {
        guard let encoded = try? JSONEncoder().encode(statistics) else { return }
        userDefaults.set(encoded, forKey: statisticsKey)
    }
    
    /// Increment total blocked attempts
    func incrementBlockedAttempts() {
        statistics.totalBlockedAttempts += 1
        statistics.lastUpdated = Date()
        
        // Update today's stats
        let calendar = Calendar.current
        if let todayIndex = statistics.dailyStats.firstIndex(where: { calendar.isDateInToday($0.date) }) {
            statistics.dailyStats[todayIndex].blockedAttempts += 1
        } else {
            // Create today's stats if not exists
            let todayStats = DailyStatistic(date: Date(), blockedAttempts: 1)
            statistics.dailyStats.insert(todayStats, at: 0)
        }
        
        saveStatistics()
    }
    
    /// Increment blocked attempts for specific domain
    func incrementBlockedAttempts(for domain: String) {
        statistics.totalBlockedAttempts += 1
        statistics.lastUpdated = Date()
        
        // Update today's stats
        let calendar = Calendar.current
        if let todayIndex = statistics.dailyStats.firstIndex(where: { calendar.isDateInToday($0.date) }) {
            statistics.dailyStats[todayIndex].blockedAttempts += 1
            
            // Update domain count
            let normalizedDomain = domain.lowercased().replacingOccurrences(of: "www.", with: "")
            let currentCount = statistics.dailyStats[todayIndex].topBlockedDomains[normalizedDomain] ?? 0
            statistics.dailyStats[todayIndex].topBlockedDomains[normalizedDomain] = currentCount + 1
        } else {
            // Create today's stats
            let normalizedDomain = domain.lowercased().replacingOccurrences(of: "www.", with: "")
            let todayStats = DailyStatistic(
                date: Date(),
                blockedAttempts: 1,
                topBlockedDomains: [normalizedDomain: 1]
            )
            statistics.dailyStats.insert(todayStats, at: 0)
        }
        
        saveStatistics()
    }
    
    /// Update connected devices count
    func updateConnectedDevices(_ count: Int) {
        statistics.totalConnectedDevices = count
        statistics.lastUpdated = Date()
        saveStatistics()
    }
    
    /// Update blocked sites count
    func updateBlockedSitesCount(_ count: Int) {
        statistics.totalBlockedSites = count
        statistics.lastUpdated = Date()
        saveStatistics()
    }
    
    /// Update active devices for today
    func updateActiveDevices(_ count: Int) {
        let calendar = Calendar.current
        if let todayIndex = statistics.dailyStats.firstIndex(where: { calendar.isDateInToday($0.date) }) {
            statistics.dailyStats[todayIndex].activeDevices = count
        } else {
            let todayStats = DailyStatistic(date: Date(), activeDevices: count)
            statistics.dailyStats.insert(todayStats, at: 0)
        }
        saveStatistics()
    }
    
    /// Clean up old daily statistics (keep last 30 days)
    func cleanupOldStatistics() {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
        statistics.dailyStats.removeAll { $0.date < thirtyDaysAgo }
        saveStatistics()
    }
    
    /// Reset all statistics
    func resetStatistics() {
        statistics = Statistics()
        saveStatistics()
    }
    
    // MARK: - Utilities
    
    /// Clear all settings and statistics
    func clearAll() {
        settings = AppSettings()
        statistics = Statistics()
        userDefaults.removeObject(forKey: settingsKey)
        userDefaults.removeObject(forKey: statisticsKey)
    }
}
