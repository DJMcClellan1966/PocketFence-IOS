//
//  PacketTunnelProvider.swift
//  PocketFence Network Extension
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import NetworkExtension
import os.log

/// Packet Tunnel Provider for filtering network traffic
class PacketTunnelProvider: NEPacketTunnelProvider {
    
    private let log = OSLog(subsystem: "com.pocketfence.ios.NetworkExtension", category: "PacketTunnel")
    
    private var blockedDomains: Set<String> = []
    private var blockedIPs: Set<String> = []
    
    // MARK: - Lifecycle
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log("Starting PocketFence tunnel", log: log, type: .info)
        
        // Load blocked domains and IPs from shared UserDefaults
        loadBlockingRules()
        
        // Configure tunnel settings
        let tunnelNetworkSettings = createTunnelSettings()
        
        setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            if let error = error {
                os_log("Failed to set tunnel settings: %{public}@", log: self?.log ?? OSLog.default, type: .error, error.localizedDescription)
                completionHandler(error)
                return
            }
            
            os_log("PocketFence tunnel started successfully", log: self?.log ?? OSLog.default, type: .info)
            completionHandler(nil)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("Stopping PocketFence tunnel: %{public}@", log: log, type: .info, "\(reason)")
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Handle messages from main app
        os_log("Received app message", log: log, type: .debug)
        
        // Reload blocking rules when app sends update
        loadBlockingRules()
        
        completionHandler?(nil)
    }
    
    // MARK: - Configuration
    
    private func createTunnelSettings() -> NEPacketTunnelNetworkSettings {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        
        // IPv4 settings
        let ipv4Settings = NEIPv4Settings(addresses: ["172.16.0.1"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        settings.ipv4Settings = ipv4Settings
        
        // DNS settings - route DNS through our tunnel
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        dnsSettings.matchDomains = [""] // Match all domains
        settings.dnsSettings = dnsSettings
        
        // MTU
        settings.mtu = 1500
        
        return settings
    }
    
    // MARK: - Blocking Rules
    
    private func loadBlockingRules() {
        let appGroupId = "group.com.pocketfence.ios"
        guard let userDefaults = UserDefaults(suiteName: appGroupId) else {
            os_log("Failed to access shared UserDefaults", log: log, type: .error)
            return
        }
        
        // Load blocked domains
        if let domains = userDefaults.array(forKey: "blockedDomains") as? [String] {
            blockedDomains = Set(domains.map { $0.lowercased() })
            os_log("Loaded %d blocked domains", log: log, type: .info, blockedDomains.count)
        }
        
        // Load blocked IPs
        if let ips = userDefaults.array(forKey: "blockedIPs") as? [String] {
            blockedIPs = Set(ips)
            os_log("Loaded %d blocked IPs", log: log, type: .info, blockedIPs.count)
        }
    }
    
    // MARK: - Packet Processing
    
    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        // This would be implemented for more advanced traffic filtering
        // For DNS-based filtering, we primarily rely on DNS settings
        os_log("New flow: %{public}@", log: log, type: .debug, flow.debugDescription)
        return true
    }
    
    // MARK: - DNS Filtering (Conceptual)
    
    /// Check if a domain should be blocked
    private func shouldBlockDomain(_ domain: String) -> Bool {
        let normalizedDomain = domain.lowercased()
        
        // Check exact match
        if blockedDomains.contains(normalizedDomain) {
            return true
        }
        
        // Check if it's a subdomain of a blocked domain
        for blockedDomain in blockedDomains {
            if normalizedDomain.hasSuffix(".\(blockedDomain)") {
                return true
            }
        }
        
        return false
    }
    
    /// Check if an IP should be blocked
    private func shouldBlockIP(_ ip: String) -> Bool {
        return blockedIPs.contains(ip)
    }
    
    // MARK: - Statistics
    
    private func recordBlockedAttempt(domain: String) {
        // In a full implementation, this would:
        // 1. Increment counters in shared storage
        // 2. Notify main app
        // 3. Log for statistics
        
        os_log("Blocked: %{public}@", log: log, type: .info, domain)
        
        let appGroupId = "group.com.pocketfence.ios"
        guard let userDefaults = UserDefaults(suiteName: appGroupId) else { return }
        
        let key = "totalBlockedAttempts"
        let count = userDefaults.integer(forKey: key)
        userDefaults.set(count + 1, forKey: key)
    }
}

// MARK: - DNS Filter Provider (Alternative Approach)

/// Alternative implementation using NEDNSProxyProvider for DNS-level filtering
/// This would be in a separate target if using DNS Proxy approach
class DNSFilterProvider: NEDNSProxyProvider {
    
    private let log = OSLog(subsystem: "com.pocketfence.ios.DNSFilter", category: "DNS")
    private var blockedDomains: Set<String> = []
    
    override func startProxy(options: [String : Any]?, completionHandler: @escaping (Error?) -> Void) {
        os_log("Starting DNS proxy", log: log, type: .info)
        
        loadBlockedDomains()
        completionHandler(nil)
    }
    
    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("Stopping DNS proxy", log: log, type: .info)
        completionHandler()
    }
    
    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        // Handle DNS queries
        if let dnsFlow = flow as? NEAppProxyUDPFlow {
            // Process DNS query
            return handleDNSQuery(dnsFlow)
        }
        return false
    }
    
    private func handleDNSQuery(_ flow: NEAppProxyUDPFlow) -> Bool {
        // In a full implementation:
        // 1. Parse DNS query
        // 2. Check against blocklist
        // 3. Return NXDOMAIN for blocked domains
        // 4. Forward allowed queries to upstream DNS
        return true
    }
    
    private func loadBlockedDomains() {
        let appGroupId = "group.com.pocketfence.ios"
        guard let userDefaults = UserDefaults(suiteName: appGroupId),
              let domains = userDefaults.array(forKey: "blockedDomains") as? [String] else {
            return
        }
        
        blockedDomains = Set(domains.map { $0.lowercased() })
        os_log("Loaded %d blocked domains", log: log, type: .info, blockedDomains.count)
    }
}
