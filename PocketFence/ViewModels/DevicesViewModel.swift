//
//  DevicesViewModel.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Combine

/// ViewModel for the Devices tab
@MainActor
class DevicesViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var devices: [Device] = []
    @Published var isScanning = false
    @Published var selectedDevice: Device?
    @Published var showingDeviceDetail = false
    @Published var showingAddDevice = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let deviceRepo = DeviceRepository.shared
    private let deviceDetection = DeviceDetectionService.shared
    private let timeLimitRepo = TimeLimitRepository.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupObservers()
        loadDevices()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        deviceRepo.$devices
            .assign(to: &$devices)
        
        deviceDetection.$isScanning
            .assign(to: &$isScanning)
    }
    
    // MARK: - Data Loading
    
    func loadDevices() {
        deviceRepo.loadDevices()
    }
    
    func scanForDevices() async {
        await deviceDetection.scanForDevices()
    }
    
    // MARK: - Device Actions
    
    func toggleDeviceBlock(_ device: Device) {
        var updated = device
        updated.isBlocked.toggle()
        deviceRepo.updateDevice(updated)
    }
    
    func setTimeLimit(for device: Device, minutes: Int?) {
        var updated = device
        updated.dailyTimeLimit = minutes
        deviceRepo.updateDevice(updated)
    }
    
    func updateDeviceName(_ device: Device, name: String) {
        var updated = device
        updated.name = name
        deviceRepo.updateDevice(updated)
    }
    
    func removeDevice(_ device: Device) {
        deviceRepo.removeDevice(device)
    }
    
    func resetDailyUsage(for device: Device) {
        var updated = device
        updated.timeUsedToday = 0
        deviceRepo.updateDevice(updated)
    }
    
    func resetAllDailyUsage() {
        deviceRepo.resetDailyTimeUsage()
    }
    
    // MARK: - Manual Device Addition
    
    func addManualDevice(name: String, ipAddress: String, macAddress: String) {
        let device = Device(
            name: name,
            ipAddress: ipAddress,
            macAddress: macAddress
        )
        deviceRepo.addDevice(device)
    }
    
    // MARK: - Computed Properties
    
    var activeDevices: [Device] {
        devices.filter { $0.isActive }
    }
    
    var blockedDevices: [Device] {
        devices.filter { $0.isBlocked }
    }
    
    var devicesWithLimits: [Device] {
        devices.filter { $0.dailyTimeLimit != nil }
    }
    
    var activeDeviceCount: Int {
        activeDevices.count
    }
    
    // MARK: - Device Selection
    
    func selectDevice(_ device: Device) {
        selectedDevice = device
        showingDeviceDetail = true
    }
    
    func deselectDevice() {
        selectedDevice = nil
        showingDeviceDetail = false
    }
}
