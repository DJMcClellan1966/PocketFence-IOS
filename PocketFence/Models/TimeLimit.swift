//
//  TimeLimit.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation

/// Represents time limit configuration
struct TimeLimit: Identifiable, Codable, Equatable {
    let id: UUID
    var deviceId: UUID?
    var dailyLimitMinutes: Int
    var isEnabled: Bool
    var quietHours: QuietHours?
    
    init(
        id: UUID = UUID(),
        deviceId: UUID? = nil,
        dailyLimitMinutes: Int,
        isEnabled: Bool = true,
        quietHours: QuietHours? = nil
    ) {
        self.id = id
        self.deviceId = deviceId
        self.dailyLimitMinutes = dailyLimitMinutes
        self.isEnabled = isEnabled
        self.quietHours = quietHours
    }
    
    /// Check if time limit applies to all devices
    var appliesToAllDevices: Bool {
        deviceId == nil
    }
}

/// Quiet hours configuration
struct QuietHours: Codable, Equatable {
    var isEnabled: Bool
    var startTime: Date
    var endTime: Date
    var daysOfWeek: Set<Int> // 1 = Sunday, 2 = Monday, etc.
    
    init(
        isEnabled: Bool = true,
        startTime: Date,
        endTime: Date,
        daysOfWeek: Set<Int> = Set(1...7)
    ) {
        self.isEnabled = isEnabled
        self.startTime = startTime
        self.endTime = endTime
        self.daysOfWeek = daysOfWeek
    }
    
    /// Check if current time is within quiet hours
    func isInQuietHours(at date: Date = Date()) -> Bool {
        guard isEnabled else { return false }
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        // Check if today is included in quiet hours days
        guard daysOfWeek.contains(weekday) else { return false }
        
        let currentTimeComponents = calendar.dateComponents([.hour, .minute], from: date)
        let startTimeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        guard let currentHour = currentTimeComponents.hour,
              let currentMinute = currentTimeComponents.minute,
              let startHour = startTimeComponents.hour,
              let startMinute = startTimeComponents.minute,
              let endHour = endTimeComponents.hour,
              let endMinute = endTimeComponents.minute else {
            return false
        }
        
        let currentMinutes = currentHour * 60 + currentMinute
        let startMinutes = startHour * 60 + startMinute
        let endMinutes = endHour * 60 + endMinute
        
        // Handle overnight quiet hours
        if endMinutes < startMinutes {
            return currentMinutes >= startMinutes || currentMinutes <= endMinutes
        } else {
            return currentMinutes >= startMinutes && currentMinutes <= endMinutes
        }
    }
    
    /// Display-friendly time range string
    var displayTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}

// MARK: - Sample Data
extension TimeLimit {
    static let sample = TimeLimit(
        dailyLimitMinutes: 120,
        quietHours: QuietHours(
            startTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!,
            endTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
        )
    )
    
    static let samples: [TimeLimit] = [
        TimeLimit(
            dailyLimitMinutes: 120,
            quietHours: QuietHours(
                startTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!,
                endTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
            )
        ),
        TimeLimit(
            deviceId: UUID(),
            dailyLimitMinutes: 180,
            quietHours: QuietHours(
                isEnabled: false,
                startTime: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!,
                endTime: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
            )
        )
    ]
}

extension QuietHours {
    static let sample = QuietHours(
        startTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!,
        endTime: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
    )
}
