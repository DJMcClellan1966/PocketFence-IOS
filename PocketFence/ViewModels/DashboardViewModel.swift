//
//  DashboardViewModel.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Combine
import Observation

/// ViewModel for the Dashboard tab
@MainActor
@Observable
class DashboardViewModel {
    // MARK: - Properties
    
    var isProtectionEnabled = true
    var connectedDevices: [Device] = []
    var totalBlockedAttempts = 0
    var totalBlockedSites = 0
    var recentBlocks: [(domain: String, count: Int)] = []
    var isLoading = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let settingsRepo = SettingsRepository.shared
    private let deviceRepo = DeviceRepository.shared
    private let blockedSiteRepo = BlockedSiteRepository.shared
    private let blockingService = BlockingService.shared
    private let statisticsService = StatisticsService.shared
    private let networkFilter = NetworkFilterService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupObservers()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // With @Observable, changes are automatically tracked
        // Manually update derived properties from repositories
        updateFromRepositories()
    }
    
    private func updateFromRepositories() {
        isProtectionEnabled = settingsRepo.settings.isProtectionEnabled
        connectedDevices = deviceRepo.devices.filter { $0.isActive }
        totalBlockedAttempts = settingsRepo.statistics.totalBlockedAttempts
        totalBlockedSites = settingsRepo.statistics.totalBlockedSites
        updateRecentBlocks(from: settingsRepo.statistics)
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        
        // Load repositories
        deviceRepo.loadDevices()
        blockedSiteRepo.loadBlockedSites()
        
        // Update statistics
        statisticsService.updateStatistics()
        
        // Update derived properties
        updateFromRepositories()
        
        isLoading = false
    }
    
    func refreshData() async {
        isLoading = true
        
        // Reload all data
        loadData()
        
        // Small delay for UX
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        isLoading = false
    }
    
    // MARK: - Actions
    
    func toggleProtection() async {
        errorMessage = nil
        
        do {
            if isProtectionEnabled {
                await blockingService.disableBlocking()
            } else {
                try await blockingService.enableBlocking()
            }
        } catch {
            errorMessage = error.localizedDescription
            // Revert toggle on error
            isProtectionEnabled.toggle()
        }
    }
    
    // MARK: - Computed Properties
    
    var protectionStatusText: String {
        isProtectionEnabled ? "Protection Active" : "Protection Disabled"
    }
    
    var protectionStatusColor: String {
        isProtectionEnabled ? "green" : "red"
    }
    
    var activeDeviceCount: Int {
        connectedDevices.count
    }
    
    var blockedTodayCount: Int {
        settingsRepo.statistics.todayStats?.blockedAttempts ?? 0
    }
    
    // MARK: - Helper Methods
    
    private func updateRecentBlocks(from statistics: Statistics) {
        // Get top blocked domains from today's statistics
        if let todayStats = statistics.todayStats {
            recentBlocks = todayStats.topDomains(limit: 5)
        } else {
            recentBlocks = []
        }
    }
}
