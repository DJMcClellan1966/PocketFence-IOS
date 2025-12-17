//
//  TimeLimitRepository.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Combine

/// Repository for managing time limits and quiet hours
class TimeLimitRepository: ObservableObject {
    static let shared = TimeLimitRepository()
    
    @Published private(set) var timeLimits: [TimeLimit] = []
    @Published private(set) var globalQuietHours: QuietHours?
    
    private let userDefaults = UserDefaults.standard
    private let timeLimitsKey = "pocketfence.timeLimits"
    private let quietHoursKey = "pocketfence.quietHours"
    
    private init() {
        loadTimeLimits()
        loadQuietHours()
    }
    
    // MARK: - Time Limits
    
    /// Load all time limits from storage
    func loadTimeLimits() {
        guard let data = userDefaults.data(forKey: timeLimitsKey),
              let decoded = try? JSONDecoder().decode([TimeLimit].self, from: data) else {
            timeLimits = []
            return
        }
        timeLimits = decoded
    }
    
    /// Save all time limits to storage
    func saveTimeLimits() {
        guard let encoded = try? JSONEncoder().encode(timeLimits) else { return }
        userDefaults.set(encoded, forKey: timeLimitsKey)
    }
    
    /// Add or update time limit
    func setTimeLimit(_ timeLimit: TimeLimit) {
        if let index = timeLimits.firstIndex(where: { $0.id == timeLimit.id }) {
            timeLimits[index] = timeLimit
        } else {
            timeLimits.append(timeLimit)
        }
        saveTimeLimits()
    }
    
    /// Remove a time limit
    func removeTimeLimit(_ timeLimit: TimeLimit) {
        timeLimits.removeAll { $0.id == timeLimit.id }
        saveTimeLimits()
    }
    
    /// Get time limit for a specific device
    func getTimeLimit(for deviceId: UUID) -> TimeLimit? {
        timeLimits.first { $0.deviceId == deviceId }
    }
    
    /// Get global time limit (applies to all devices)
    func getGlobalTimeLimit() -> TimeLimit? {
        timeLimits.first { $0.appliesToAllDevices }
    }
    
    /// Update time limit for device
    func updateTimeLimit(for deviceId: UUID?, minutes: Int) {
        if let existingLimit = timeLimits.first(where: { $0.deviceId == deviceId }) {
            var updatedLimit = existingLimit
            updatedLimit.dailyLimitMinutes = minutes
            setTimeLimit(updatedLimit)
        } else {
            let newLimit = TimeLimit(deviceId: deviceId, dailyLimitMinutes: minutes)
            setTimeLimit(newLimit)
        }
    }
    
    /// Toggle time limit enabled status
    func toggleTimeLimitEnabled(_ timeLimitId: UUID) {
        guard let index = timeLimits.firstIndex(where: { $0.id == timeLimitId }) else { return }
        timeLimits[index].isEnabled.toggle()
        saveTimeLimits()
    }
    
    // MARK: - Quiet Hours
    
    /// Load quiet hours from storage
    func loadQuietHours() {
        guard let data = userDefaults.data(forKey: quietHoursKey),
              let decoded = try? JSONDecoder().decode(QuietHours.self, from: data) else {
            globalQuietHours = nil
            return
        }
        globalQuietHours = decoded
    }
    
    /// Save quiet hours to storage
    func saveQuietHours() {
        guard let quietHours = globalQuietHours,
              let encoded = try? JSONEncoder().encode(quietHours) else {
            userDefaults.removeObject(forKey: quietHoursKey)
            return
        }
        userDefaults.set(encoded, forKey: quietHoursKey)
    }
    
    /// Set global quiet hours
    func setQuietHours(_ quietHours: QuietHours) {
        globalQuietHours = quietHours
        saveQuietHours()
    }
    
    /// Remove quiet hours
    func removeQuietHours() {
        globalQuietHours = nil
        userDefaults.removeObject(forKey: quietHoursKey)
    }
    
    /// Check if currently in quiet hours
    func isInQuietHours() -> Bool {
        globalQuietHours?.isInQuietHours() ?? false
    }
    
    /// Toggle quiet hours enabled status
    func toggleQuietHoursEnabled() {
        guard var quietHours = globalQuietHours else { return }
        quietHours.isEnabled.toggle()
        globalQuietHours = quietHours
        saveQuietHours()
    }
    
    // MARK: - Utilities
    
    /// Clear all time limits and quiet hours
    func clearAll() {
        timeLimits = []
        globalQuietHours = nil
        userDefaults.removeObject(forKey: timeLimitsKey)
        userDefaults.removeObject(forKey: quietHoursKey)
    }
}
