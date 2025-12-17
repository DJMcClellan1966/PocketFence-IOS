//
//  NetworkFilterService.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import NetworkExtension
import Combine

/// Service for managing Network Extension and traffic filtering
class NetworkFilterService: ObservableObject {
    static let shared = NetworkFilterService()
    
    @Published private(set) var isVPNActive = false
    @Published private(set) var filterStatus: FilterStatus = .inactive
    
    private var statusObserver: AnyCancellable?
    
    enum FilterStatus {
        case inactive
        case connecting
        case active
        case disconnecting
        case error(String)
        
        var description: String {
            switch self {
            case .inactive: return "Inactive"
            case .connecting: return "Connecting..."
            case .active: return "Active"
            case .disconnecting: return "Disconnecting..."
            case .error(let message): return "Error: \(message)"
            }
        }
    }
    
    private init() {
        observeVPNStatus()
    }
    
    // MARK: - VPN Configuration
    
    /// Configure and save VPN/Network Extension settings
    func configureVPN() async throws {
        let manager = NETunnelProviderManager()
        
        // Load existing configuration or create new one
        try await manager.loadFromPreferences()
        
        // Configure tunnel protocol
        let protocolConfiguration = NETunnelProviderProtocol()
        protocolConfiguration.providerBundleIdentifier = "com.pocketfence.ios.NetworkExtension"
        protocolConfiguration.serverAddress = "PocketFence"
        
        manager.protocolConfiguration = protocolConfiguration
        manager.localizedDescription = "PocketFence Content Filter"
        manager.isEnabled = true
        
        // Save configuration
        try await manager.saveToPreferences()
        try await manager.loadFromPreferences()
    }
    
    /// Start the VPN/Network Extension
    func startFiltering() async throws {
        filterStatus = .connecting
        
        // Load VPN manager
        guard let manager = try await loadVPNManager() else {
            throw NetworkFilterError.configurationNotFound
        }
        
        guard manager.isEnabled else {
            throw NetworkFilterError.notEnabled
        }
        
        // Start VPN connection
        try manager.connection.startVPNTunnel()
        filterStatus = .active
        isVPNActive = true
    }
    
    /// Stop the VPN/Network Extension
    func stopFiltering() async {
        filterStatus = .disconnecting
        
        if let manager = try? await loadVPNManager() {
            manager.connection.stopVPNTunnel()
        }
        
        filterStatus = .inactive
        isVPNActive = false
    }
    
    /// Load existing VPN manager
    private func loadVPNManager() async throws -> NETunnelProviderManager? {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        return managers.first
    }
    
    /// Remove VPN configuration
    func removeVPNConfiguration() async throws {
        if let manager = try await loadVPNManager() {
            try await manager.removeFromPreferences()
        }
        filterStatus = .inactive
        isVPNActive = false
    }
    
    // MARK: - Status Monitoring
    
    /// Observe VPN connection status
    private func observeVPNStatus() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(vpnStatusDidChange),
            name: .NEVPNStatusDidChange,
            object: nil
        )
    }
    
    @objc private func vpnStatusDidChange(_ notification: Notification) {
        Task { @MainActor in
            if let manager = try? await loadVPNManager() {
                updateStatus(from: manager.connection.status)
            }
        }
    }
    
    private func updateStatus(from status: NEVPNStatus) {
        switch status {
        case .invalid:
            filterStatus = .inactive
            isVPNActive = false
        case .disconnected:
            filterStatus = .inactive
            isVPNActive = false
        case .connecting:
            filterStatus = .connecting
            isVPNActive = false
        case .connected:
            filterStatus = .active
            isVPNActive = true
        case .reasserting:
            filterStatus = .connecting
            isVPNActive = false
        case .disconnecting:
            filterStatus = .disconnecting
            isVPNActive = false
        @unknown default:
            filterStatus = .inactive
            isVPNActive = false
        }
    }
    
    // MARK: - Filtering Rules
    
    /// Send updated blocked domains to Network Extension
    func updateBlockedDomains(_ domains: [String]) async {
        // In a real implementation, this would communicate with the Network Extension
        // to update the blocked domains list
        // This could be done via shared UserDefaults in an App Group
        
        let appGroupId = "group.com.pocketfence.ios"
        if let userDefaults = UserDefaults(suiteName: appGroupId) {
            userDefaults.set(domains, forKey: "blockedDomains")
            userDefaults.synchronize()
        }
    }
    
    /// Send updated device rules to Network Extension
    func updateDeviceRules(_ devices: [Device]) async {
        // Communicate device blocking rules to Network Extension
        let appGroupId = "group.com.pocketfence.ios"
        if let userDefaults = UserDefaults(suiteName: appGroupId) {
            let blockedIPs = devices.filter { $0.isBlocked || $0.hasExceededTimeLimit }
                .map { $0.ipAddress }
            userDefaults.set(blockedIPs, forKey: "blockedIPs")
            userDefaults.synchronize()
        }
    }
}

// MARK: - Errors

enum NetworkFilterError: LocalizedError {
    case configurationNotFound
    case notEnabled
    case permissionDenied
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .configurationNotFound:
            return "VPN configuration not found. Please reconfigure the network filter."
        case .notEnabled:
            return "Network filter is not enabled. Please enable it in settings."
        case .permissionDenied:
            return "Permission denied. Please grant VPN permissions in iOS Settings."
        case .unknown(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}
