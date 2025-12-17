//
//  DeviceRepository.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Combine
import Observation

/// Repository for managing device data persistence
@Observable
class DeviceRepository {
    static let shared = DeviceRepository()
    
    private(set) var devices: [Device] = []
    
    private let userDefaults = UserDefaults.standard
    private let devicesKey = "pocketfence.devices"
    
    private init() {
        loadDevices()
    }
    
    // MARK: - Public Methods
    
    /// Load all devices from storage
    func loadDevices() {
        guard let data = userDefaults.data(forKey: devicesKey),
              let decoded = try? JSONDecoder().decode([Device].self, from: data) else {
            devices = []
            return
        }
        devices = decoded
    }
    
    /// Save all devices to storage
    func saveDevices() {
        guard let encoded = try? JSONEncoder().encode(devices) else { return }
        userDefaults.set(encoded, forKey: devicesKey)
    }
    
    /// Add a new device
    func addDevice(_ device: Device) {
        // Check if device already exists (by MAC address)
        if let index = devices.firstIndex(where: { $0.macAddress == device.macAddress }) {
            devices[index] = device
        } else {
            devices.append(device)
        }
        saveDevices()
    }
    
    /// Update an existing device
    func updateDevice(_ device: Device) {
        guard let index = devices.firstIndex(where: { $0.id == device.id }) else { return }
        devices[index] = device
        saveDevices()
    }
    
    /// Remove a device
    func removeDevice(_ device: Device) {
        devices.removeAll { $0.id == device.id }
        saveDevices()
    }
    
    /// Get device by ID
    func getDevice(by id: UUID) -> Device? {
        devices.first { $0.id == id }
    }
    
    /// Get device by MAC address
    func getDevice(byMacAddress mac: String) -> Device? {
        devices.first { $0.macAddress == mac }
    }
    
    /// Update device's last seen timestamp
    func updateLastSeen(for deviceId: UUID) {
        guard let index = devices.firstIndex(where: { $0.id == deviceId }) else { return }
        devices[index].lastSeen = Date()
        saveDevices()
    }
    
    /// Increment blocked attempts for a device
    func incrementBlockedAttempts(for deviceId: UUID) {
        guard let index = devices.firstIndex(where: { $0.id == deviceId }) else { return }
        devices[index].totalBlockedAttempts += 1
        saveDevices()
    }
    
    /// Update time used for a device
    func updateTimeUsed(for deviceId: UUID, minutes: Int) {
        guard let index = devices.firstIndex(where: { $0.id == deviceId }) else { return }
        devices[index].timeUsedToday = minutes
        saveDevices()
    }
    
    /// Reset daily time usage for all devices
    func resetDailyTimeUsage() {
        for index in devices.indices {
            devices[index].timeUsedToday = 0
        }
        saveDevices()
    }
    
    /// Get active devices (seen in last 5 minutes)
    func getActiveDevices() -> [Device] {
        devices.filter { $0.isActive }
    }
    
    /// Get blocked devices
    func getBlockedDevices() -> [Device] {
        devices.filter { $0.isBlocked }
    }
    
    /// Clear all devices
    func clearAll() {
        devices = []
        userDefaults.removeObject(forKey: devicesKey)
    }
}
