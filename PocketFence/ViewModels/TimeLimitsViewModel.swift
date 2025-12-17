//
//  TimeLimitsViewModel.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Observation

/// ViewModel for the Time Limits tab
@MainActor
@Observable
class TimeLimitsViewModel {
    // MARK: - Properties
    
    var timeLimits: [TimeLimit] = []
    var globalQuietHours: QuietHours?
    var devices: [Device] = []
    var selectedDevice: Device?
    var showingQuietHoursEditor = false
    var showingTimeLimitEditor = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let timeLimitRepo = TimeLimitRepository.shared
    private let deviceRepo = DeviceRepository.shared
    
    // MARK: - Initialization
    
    init() {
        setupObservers()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // With @Observable, changes are automatically tracked
        updateFromRepositories()
    }
    
    private func updateFromRepositories() {
        timeLimits = timeLimitRepo.timeLimits
        globalQuietHours = timeLimitRepo.globalQuietHours
        devices = deviceRepo.devices
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        timeLimitRepo.loadTimeLimits()
        timeLimitRepo.loadQuietHours()
        deviceRepo.loadDevices()
        updateFromRepositories()
    }
    
    // MARK: - Time Limit Actions
    
    func setTimeLimit(for deviceId: UUID?, minutes: Int) {
        timeLimitRepo.updateTimeLimit(for: deviceId, minutes: minutes)
    }
    
    func removeTimeLimit(_ timeLimit: TimeLimit) {
        timeLimitRepo.removeTimeLimit(timeLimit)
    }
    
    func toggleTimeLimitEnabled(_ timeLimit: TimeLimit) {
        timeLimitRepo.toggleTimeLimitEnabled(timeLimit.id)
    }
    
    func getTimeLimit(for device: Device) -> TimeLimit? {
        timeLimitRepo.getTimeLimit(for: device.id)
    }
    
    func getGlobalTimeLimit() -> TimeLimit? {
        timeLimitRepo.getGlobalTimeLimit()
    }
    
    // MARK: - Quiet Hours Actions
    
    func setQuietHours(startTime: Date, endTime: Date, daysOfWeek: Set<Int>) {
        let quietHours = QuietHours(
            startTime: startTime,
            endTime: endTime,
            daysOfWeek: daysOfWeek
        )
        timeLimitRepo.setQuietHours(quietHours)
    }
    
    func removeQuietHours() {
        timeLimitRepo.removeQuietHours()
    }
    
    func toggleQuietHoursEnabled() {
        timeLimitRepo.toggleQuietHoursEnabled()
    }
    
    func isInQuietHours() -> Bool {
        timeLimitRepo.isInQuietHours()
    }
    
    // MARK: - Computed Properties
    
    var hasGlobalTimeLimit: Bool {
        getGlobalTimeLimit() != nil
    }
    
    var hasQuietHours: Bool {
        globalQuietHours != nil
    }
    
    var activeTimeLimits: [TimeLimit] {
        timeLimits.filter { $0.isEnabled }
    }
    
    var devicesWithLimits: [Device] {
        devices.filter { device in
            timeLimits.contains { $0.deviceId == device.id }
        }
    }
    
    var devicesWithoutLimits: [Device] {
        devices.filter { device in
            !timeLimits.contains { $0.deviceId == device.id }
        }
    }
    
    // MARK: - Time Formatting
    
    func formatTimeRemaining(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Validation
    
    func validateTimeLimit(_ minutes: Int) -> Bool {
        minutes > 0 && minutes <= 1440 // Max 24 hours
    }
    
    func validateQuietHours(start: Date, end: Date) -> Bool {
        // Quiet hours can span midnight, so this is always valid
        true
    }
}
