//
//  SettingsViewModel.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import StoreKit
import Observation

/// ViewModel for the Settings tab
@MainActor
@Observable
class SettingsViewModel {
    // MARK: - Properties
    
    var settings: AppSettings
    var statistics: Statistics
    var isPremium = false
    var isProtectionEnabled = true
    var notificationsEnabled = true
    var soundEnabled = true
    var selectedBlockingMode: BlockingMode = .strict
    var selectedTheme: AppTheme = .system
    var showingPurchaseSheet = false
    var showingResetConfirmation = false
    var errorMessage: String?
    var successMessage: String?
    
    // MARK: - Dependencies
    
    private let settingsRepo = SettingsRepository.shared
    private let deviceRepo = DeviceRepository.shared
    private let blockedSiteRepo = BlockedSiteRepository.shared
    private let timeLimitRepo = TimeLimitRepository.shared
    private let statisticsService = StatisticsService.shared
    
    // MARK: - Initialization
    
    init() {
        self.settings = settingsRepo.settings
        self.statistics = settingsRepo.statistics
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // With @Observable, changes are automatically tracked
        updateFromRepositories()
    }
    
    private func updateFromRepositories() {
        settings = settingsRepo.settings
        statistics = settingsRepo.statistics
        isPremium = settings.isPremium
        isProtectionEnabled = settings.isProtectionEnabled
        notificationsEnabled = settings.notificationsEnabled
        soundEnabled = settings.soundEnabled
        selectedBlockingMode = settings.blockingMode
        selectedTheme = settings.theme
    }
    
    // MARK: - Settings Actions
    
    func toggleProtection() {
        settingsRepo.toggleProtection()
    }
    
    func toggleNotifications() {
        settingsRepo.toggleNotifications()
    }
    
    func toggleSound() {
        settingsRepo.toggleSound()
    }
    
    func setBlockingMode(_ mode: BlockingMode) {
        settingsRepo.setBlockingMode(mode)
    }
    
    func setTheme(_ theme: AppTheme) {
        settingsRepo.setTheme(theme)
    }
    
    // MARK: - Premium/IAP
    
    func purchasePremium() async {
        do {
            // In real implementation, use StoreKit 2 to purchase
            // let product = try await Product.products(for: ["com.pocketfence.premium"]).first
            // let result = try await product?.purchase()
            
            // For now, simulate purchase
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            settingsRepo.setPremiumStatus(true)
            successMessage = "Premium unlocked! Thank you for your support."
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
        }
    }
    
    func restorePurchases() async {
        do {
            // In real implementation, use StoreKit 2 to restore
            // try await AppStore.sync()
            
            // For now, check if premium is already set
            if settingsRepo.settings.isPremium {
                successMessage = "Premium already active"
            } else {
                errorMessage = "No previous purchases found"
            }
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Data Management
    
    func exportStatistics() -> String {
        statisticsService.exportStatisticsCSV()
    }
    
    func resetStatistics() {
        settingsRepo.resetStatistics()
        successMessage = "Statistics reset successfully"
    }
    
    func resetAllData() {
        settingsRepo.clearAll()
        deviceRepo.clearAll()
        blockedSiteRepo.clearAll()
        timeLimitRepo.clearAll()
        successMessage = "All data cleared successfully"
    }
    
    // MARK: - App Information
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var appVersionText: String {
        "Version \(appVersion) (\(buildNumber))"
    }
    
    // MARK: - Support URLs
    
    func openPrivacyPolicy() {
        if let url = URL(string: "https://pocketfence.app/privacy") {
            // In real app: UIApplication.shared.open(url)
            print("Opening privacy policy: \(url)")
        }
    }
    
    func openTermsOfService() {
        if let url = URL(string: "https://pocketfence.app/terms") {
            // In real app: UIApplication.shared.open(url)
            print("Opening terms of service: \(url)")
        }
    }
    
    func openSupport() {
        if let url = URL(string: "https://pocketfence.app/support") {
            // In real app: UIApplication.shared.open(url)
            print("Opening support: \(url)")
        }
    }
    
    func contactSupport() {
        let email = "support@pocketfence.app"
        if let url = URL(string: "mailto:\(email)") {
            // In real app: UIApplication.shared.open(url)
            print("Opening email to: \(email)")
        }
    }
    
    // MARK: - Computed Properties
    
    var showAds: Bool {
        !isPremium && settings.showAds
    }
    
    var protectionStatusText: String {
        isProtectionEnabled ? "Active" : "Disabled"
    }
    
    var totalBlocksText: String {
        "\(statistics.totalBlockedAttempts)"
    }
    
    var totalDevicesText: String {
        "\(statistics.totalConnectedDevices)"
    }
    
    var daysSinceStartText: String {
        "\(statistics.daysSinceStart) days"
    }
}
