//
//  BlockingService.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Combine
import Observation

/// Service for handling blocking logic and coordination
@Observable
class BlockingService {
    static let shared = BlockingService()
    
    var isBlocking = false
    
    private let blockedSiteRepo = BlockedSiteRepository.shared
    private let deviceRepo = DeviceRepository.shared
    private let timeLimitRepo = TimeLimitRepository.shared
    private let settingsRepo = SettingsRepository.shared
    private let networkFilter = NetworkFilterService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // With @Observable, repository changes are automatically tracked
        // Manual updates to filter rules should be triggered explicitly when needed
    }
    
    // MARK: - Blocking Logic
    
    /// Check if a URL should be blocked
    func shouldBlockURL(_ url: URL, for device: Device? = nil) -> BlockResult {
        // Check if protection is enabled
        guard settingsRepo.settings.isProtectionEnabled else {
            return .allowed
        }
        
        // Check device-specific blocks
        if let device = device {
            if device.isBlocked {
                return .blocked(reason: "Device is blocked")
            }
            
            if device.hasExceededTimeLimit {
                return .blocked(reason: "Daily time limit exceeded")
            }
        }
        
        // Check quiet hours
        if timeLimitRepo.isInQuietHours() {
            return .blocked(reason: "Quiet hours active")
        }
        
        // Check if domain is blocked
        if let host = url.host, blockedSiteRepo.isDomainBlocked(host) {
            return .blocked(reason: "Website blocked")
        }
        
        return .allowed
    }
    
    /// Process a blocked attempt
    func processBlockedAttempt(url: URL, device: Device?) {
        // Update statistics
        if let host = url.host {
            settingsRepo.incrementBlockedAttempts(for: host)
            blockedSiteRepo.incrementBlockCount(for: host)
        } else {
            settingsRepo.incrementBlockedAttempts()
        }
        
        // Update device statistics
        if let device = device {
            deviceRepo.incrementBlockedAttempts(for: device.id)
        }
        
        // Send notification if enabled
        if settingsRepo.settings.notificationsEnabled {
            sendBlockNotification(url: url, device: device)
        }
    }
    
    // MARK: - Filter Updates
    
    /// Update Network Extension filter rules
    func updateFilterRules() async {
        // Get all enabled blocked domains
        let blockedDomains = blockedSiteRepo.getEnabledBlockedSites()
            .map { $0.normalizedDomain }
        
        // Update Network Extension
        await networkFilter.updateBlockedDomains(blockedDomains)
        await networkFilter.updateDeviceRules(deviceRepo.devices)
    }
    
    /// Enable blocking
    func enableBlocking() async throws {
        try await networkFilter.configureVPN()
        try await networkFilter.startFiltering()
        await updateFilterRules()
        
        isBlocking = true
        
        var settings = settingsRepo.settings
        settings.isProtectionEnabled = true
        settingsRepo.updateSettings(settings)
    }
    
    /// Disable blocking
    func disableBlocking() async {
        await networkFilter.stopFiltering()
        isBlocking = false
        
        var settings = settingsRepo.settings
        settings.isProtectionEnabled = false
        settingsRepo.updateSettings(settings)
    }
    
    // MARK: - Preset Categories
    
    /// Block entire category of websites
    func blockCategory(_ category: WebsiteCategory) {
        let sites: [BlockedWebsite]
        
        switch category {
        case .socialMedia:
            sites = BlockedWebsite.socialMediaSites
        case .gaming:
            sites = BlockedWebsite.gamingSites
        case .gambling:
            sites = BlockedWebsite.gamblingSites
        case .adultContent:
            // Would need to implement adult content list
            sites = []
        case .custom:
            sites = []
        }
        
        blockedSiteRepo.addBlockedSites(sites)
    }
    
    /// Unblock entire category
    func unblockCategory(_ category: WebsiteCategory) {
        blockedSiteRepo.removeCategory(category)
    }
    
    // MARK: - Notifications
    
    private func sendBlockNotification(url: URL, device: Device?) {
        // In a real app, this would use UserNotifications framework
        // to send a local notification about the blocked attempt
        
        let deviceName = device?.displayName ?? "Unknown device"
        let domain = url.host ?? url.absoluteString
        
        print("📱 Notification: Blocked \(domain) for \(deviceName)")
        
        // TODO: Implement actual notification
        // let content = UNMutableNotificationContent()
        // content.title = "Site Blocked"
        // content.body = "Blocked \(domain) for \(deviceName)"
        // content.sound = settingsRepo.settings.soundEnabled ? .default : nil
    }
}

// MARK: - Block Result

enum BlockResult {
    case allowed
    case blocked(reason: String)
    
    var isBlocked: Bool {
        if case .blocked = self {
            return true
        }
        return false
    }
    
    var reason: String? {
        if case .blocked(let reason) = self {
            return reason
        }
        return nil
    }
}
