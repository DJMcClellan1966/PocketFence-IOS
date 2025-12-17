//
//  Statistics.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation

/// App-wide statistics
struct Statistics: Codable, Equatable {
    var totalBlockedAttempts: Int
    var totalConnectedDevices: Int
    var totalBlockedSites: Int
    var protectionStartDate: Date
    var lastUpdated: Date
    var dailyStats: [DailyStatistic]
    
    init(
        totalBlockedAttempts: Int = 0,
        totalConnectedDevices: Int = 0,
        totalBlockedSites: Int = 0,
        protectionStartDate: Date = Date(),
        lastUpdated: Date = Date(),
        dailyStats: [DailyStatistic] = []
    ) {
        self.totalBlockedAttempts = totalBlockedAttempts
        self.totalConnectedDevices = totalConnectedDevices
        self.totalBlockedSites = totalBlockedSites
        self.protectionStartDate = protectionStartDate
        self.lastUpdated = lastUpdated
        self.dailyStats = dailyStats
    }
    
    /// Days since protection started
    var daysSinceStart: Int {
        Calendar.current.dateComponents([.day], from: protectionStartDate, to: Date()).day ?? 0
    }
    
    /// Average blocks per day
    var averageBlocksPerDay: Double {
        let days = max(1, daysSinceStart)
        return Double(totalBlockedAttempts) / Double(days)
    }
    
    /// Get today's statistics
    var todayStats: DailyStatistic? {
        let calendar = Calendar.current
        return dailyStats.first { calendar.isDateInToday($0.date) }
    }
    
    /// Get this week's total blocks
    var weeklyBlocks: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return dailyStats
            .filter { $0.date >= weekAgo }
            .reduce(0) { $0 + $1.blockedAttempts }
    }
}

/// Daily statistics record
struct DailyStatistic: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var blockedAttempts: Int
    var activeDevices: Int
    var topBlockedDomains: [String: Int] // domain: count
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        blockedAttempts: Int = 0,
        activeDevices: Int = 0,
        topBlockedDomains: [String: Int] = [:]
    ) {
        self.id = id
        self.date = date
        self.blockedAttempts = blockedAttempts
        self.activeDevices = activeDevices
        self.topBlockedDomains = topBlockedDomains
    }
    
    /// Get top N most blocked domains
    func topDomains(limit: Int = 5) -> [(domain: String, count: Int)] {
        topBlockedDomains
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { (domain: $0.key, count: $0.value) }
    }
}

// MARK: - Sample Data
extension Statistics {
    static let sample = Statistics(
        totalBlockedAttempts: 1247,
        totalConnectedDevices: 5,
        totalBlockedSites: 127,
        protectionStartDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
        dailyStats: DailyStatistic.samples
    )
}

extension DailyStatistic {
    static let sample = DailyStatistic(
        date: Date(),
        blockedAttempts: 42,
        activeDevices: 3,
        topBlockedDomains: [
            "facebook.com": 15,
            "instagram.com": 12,
            "tiktok.com": 8,
            "twitter.com": 5,
            "reddit.com": 2
        ]
    )
    
    static let samples: [DailyStatistic] = {
        var stats: [DailyStatistic] = []
        let calendar = Calendar.current
        
        for daysAgo in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
            let stat = DailyStatistic(
                date: date,
                blockedAttempts: Int.random(in: 20...80),
                activeDevices: Int.random(in: 1...5),
                topBlockedDomains: [
                    "facebook.com": Int.random(in: 5...20),
                    "instagram.com": Int.random(in: 3...15),
                    "tiktok.com": Int.random(in: 2...10)
                ]
            )
            stats.append(stat)
        }
        
        return stats.sorted { $0.date > $1.date }
    }()
}
