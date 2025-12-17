//
//  StatisticsService.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Combine
import Observation

/// Service for collecting and managing statistics
@Observable
class StatisticsService {
    static let shared = StatisticsService()
    
    private let settingsRepo = SettingsRepository.shared
    private let deviceRepo = DeviceRepository.shared
    private let blockedSiteRepo = BlockedSiteRepository.shared
    
    private var updateTimer: Timer?
    
    private init() {
        startPeriodicUpdates()
    }
    
    // MARK: - Periodic Updates
    
    /// Start periodic statistics updates
    func startPeriodicUpdates() {
        // Update statistics every minute
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.updateStatistics()
        }
        
        // Initial update
        updateStatistics()
    }
    
    /// Stop periodic updates
    func stopPeriodicUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    // MARK: - Statistics Updates
    
    /// Update current statistics
    func updateStatistics() {
        updateDeviceCount()
        updateBlockedSitesCount()
        updateActiveDevices()
        cleanupOldData()
    }
    
    private func updateDeviceCount() {
        let count = deviceRepo.devices.count
        settingsRepo.updateConnectedDevices(count)
    }
    
    private func updateBlockedSitesCount() {
        let count = blockedSiteRepo.blockedSites.count
        settingsRepo.updateBlockedSitesCount(count)
    }
    
    private func updateActiveDevices() {
        let activeCount = deviceRepo.getActiveDevices().count
        settingsRepo.updateActiveDevices(activeCount)
    }
    
    private func cleanupOldData() {
        // Clean up statistics older than 30 days
        settingsRepo.cleanupOldStatistics()
    }
    
    // MARK: - Statistics Queries
    
    /// Get statistics for a specific time period
    func getStatistics(for period: TimePeriod) -> PeriodStatistics {
        let stats = settingsRepo.statistics
        let calendar = Calendar.current
        
        let startDate: Date
        switch period {
        case .today:
            startDate = calendar.startOfDay(for: Date())
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date())!
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date())!
        case .all:
            startDate = stats.protectionStartDate
        }
        
        let relevantStats = stats.dailyStats.filter { $0.date >= startDate }
        
        let totalBlocks = relevantStats.reduce(0) { $0 + $1.blockedAttempts }
        let avgDevices = relevantStats.isEmpty ? 0 : relevantStats.reduce(0) { $0 + $1.activeDevices } / relevantStats.count
        
        // Aggregate top blocked domains
        var domainCounts: [String: Int] = [:]
        for stat in relevantStats {
            for (domain, count) in stat.topBlockedDomains {
                domainCounts[domain, default: 0] += count
            }
        }
        
        let topDomains = domainCounts
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { (domain: $0.key, count: $0.value) }
        
        return PeriodStatistics(
            period: period,
            totalBlocks: totalBlocks,
            averageDevices: avgDevices,
            topBlockedDomains: topDomains,
            dailyStats: relevantStats
        )
    }
    
    /// Get hourly statistics for today
    func getHourlyStatistics() -> [HourlyStatistic] {
        // This would be implemented with more granular data collection
        // For now, return empty array
        return []
    }
    
    // MARK: - Data Export
    
    /// Export statistics as CSV
    func exportStatisticsCSV() -> String {
        let stats = settingsRepo.statistics.dailyStats
        
        var csv = "Date,Blocked Attempts,Active Devices,Top Domain\n"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        for stat in stats {
            let date = formatter.string(from: stat.date)
            let topDomain = stat.topDomains(limit: 1).first?.domain ?? "N/A"
            csv += "\(date),\(stat.blockedAttempts),\(stat.activeDevices),\(topDomain)\n"
        }
        
        return csv
    }
    
    /// Export statistics as JSON
    func exportStatisticsJSON() -> Data? {
        let stats = settingsRepo.statistics
        return try? JSONEncoder().encode(stats)
    }
}

// MARK: - Supporting Types

enum TimePeriod {
    case today
    case week
    case month
    case all
    
    var displayName: String {
        switch self {
        case .today: return "Today"
        case .week: return "Last 7 Days"
        case .month: return "Last 30 Days"
        case .all: return "All Time"
        }
    }
}

struct PeriodStatistics {
    let period: TimePeriod
    let totalBlocks: Int
    let averageDevices: Int
    let topBlockedDomains: [(domain: String, count: Int)]
    let dailyStats: [DailyStatistic]
}

struct HourlyStatistic: Identifiable {
    let id = UUID()
    let hour: Int
    let blockedAttempts: Int
}
