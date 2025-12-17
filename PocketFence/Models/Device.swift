//
//  Device.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation

/// Represents a device connected to the Personal Hotspot
struct Device: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var ipAddress: String
    var macAddress: String
    var isBlocked: Bool
    var dailyTimeLimit: Int? // in minutes
    var timeUsedToday: Int // in minutes
    var lastSeen: Date
    var firstConnected: Date
    var totalBlockedAttempts: Int
    
    init(
        id: UUID = UUID(),
        name: String,
        ipAddress: String,
        macAddress: String,
        isBlocked: Bool = false,
        dailyTimeLimit: Int? = nil,
        timeUsedToday: Int = 0,
        lastSeen: Date = Date(),
        firstConnected: Date = Date(),
        totalBlockedAttempts: Int = 0
    ) {
        self.id = id
        self.name = name
        self.ipAddress = ipAddress
        self.macAddress = macAddress
        self.isBlocked = isBlocked
        self.dailyTimeLimit = dailyTimeLimit
        self.timeUsedToday = timeUsedToday
        self.lastSeen = lastSeen
        self.firstConnected = firstConnected
        self.totalBlockedAttempts = totalBlockedAttempts
    }
    
    /// Check if device has exceeded time limit
    var hasExceededTimeLimit: Bool {
        guard let limit = dailyTimeLimit else { return false }
        return timeUsedToday >= limit
    }
    
    /// Remaining time in minutes
    var remainingTime: Int? {
        guard let limit = dailyTimeLimit else { return nil }
        return max(0, limit - timeUsedToday)
    }
    
    /// Check if device is currently active (seen in last 5 minutes)
    var isActive: Bool {
        Date().timeIntervalSince(lastSeen) < 300 // 5 minutes
    }
    
    /// Friendly display name (falls back to IP if name is empty)
    var displayName: String {
        name.isEmpty ? ipAddress : name
    }
}

// MARK: - Sample Data for Previews
extension Device {
    static let sample = Device(
        name: "iPhone 13",
        ipAddress: "192.168.1.101",
        macAddress: "AA:BB:CC:DD:EE:FF",
        isBlocked: false,
        dailyTimeLimit: 120,
        timeUsedToday: 45,
        totalBlockedAttempts: 12
    )
    
    static let samples: [Device] = [
        Device(
            name: "iPhone 13",
            ipAddress: "192.168.1.101",
            macAddress: "AA:BB:CC:DD:EE:FF",
            dailyTimeLimit: 120,
            timeUsedToday: 45,
            totalBlockedAttempts: 12
        ),
        Device(
            name: "iPad Pro",
            ipAddress: "192.168.1.102",
            macAddress: "11:22:33:44:55:66",
            isBlocked: true,
            totalBlockedAttempts: 28
        ),
        Device(
            name: "MacBook Air",
            ipAddress: "192.168.1.103",
            macAddress: "77:88:99:AA:BB:CC",
            dailyTimeLimit: 240,
            timeUsedToday: 180,
            totalBlockedAttempts: 5
        )
    ]
}
