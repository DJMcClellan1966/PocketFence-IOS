import Foundation
import NetworkExtension
import os

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let logger = Logger(subsystem: "com.pocketfence.app", category: "PacketTunnel")
    private var blockedDomains: Set<String> = []
    private var appGroupDefaults: UserDefaults?
    
    override init() {
        super.init()
        self.appGroupDefaults = UserDefaults(suiteName: "group.com.pocketfence.ios")
        loadBlockedDomains()
    }
    
    // MARK: - Blocked Domains
    
    // Load blocked domains from App Group
    private func loadBlockedDomains() {
        if let domains = appGroupDefaults?.array(forKey: "blockedDomains") as? [String] {
            blockedDomains = Set(domains)
            logger.info("Loaded \(domains.count) blocked domains")
        }
    }
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        logger.info("Starting PocketFence tunnel")
        
        // Reload blocked domains
        loadBlockedDomains()
        
        let tunnelNetworkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        
        // Configure IPv4 settings
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        tunnelNetworkSettings.ipv4Settings = ipv4Settings
        
        // Configure DNS settings - route through our filter
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        dnsSettings.matchDomains = [""] // Match all domains
        tunnelNetworkSettings.dnsSettings = dnsSettings
        
        setTunnelNetworkSettings(tunnelNetworkSettings) { [weak self] error in
            if let error = error {
                self?.logger.error("Failed to set tunnel network settings: \(error.localizedDescription)")
                completionHandler(error)
            } else {
                self?.logger.info("Tunnel network settings applied successfully")
                self?.startPacketProcessing()
                completionHandler(nil)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        logger.info("Stopping tunnel with reason: \(reason.rawValue)")
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        logger.info("Received app message")
        
        // Handle reload command
        if let message = try? JSONDecoder().decode([String: String].self, from: messageData),
           message["command"] == "reload" {
            loadBlockedDomains()
        }
        
        completionHandler?(nil)
    }

    // MARK: - Packet Processing
    
    private func startPacketProcessing() {
        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self = self else { return }
            
            self.filterPackets(packets: packets, protocols: protocols)
            self.startPacketProcessing()
        }
    }
    
    private func filterPackets(packets: [Data], protocols: [NSNumber]) {
        var filteredPackets: [Data] = []
        var filteredProtocols: [NSNumber] = []
        
        for (index, packet) in packets.enumerated() {
            if shouldAllowPacket(packet) {
                filteredPackets.append(packet)
                filteredProtocols.append(protocols[index])
            } else {
                recordBlockedAttempt()
            }
        }
        
        if !filteredPackets.isEmpty {
            packetFlow.writePackets(filteredPackets, withProtocols: filteredProtocols)
        }
    }
    
    private func shouldAllowPacket(_ packet: Data) -> Bool {
        // Basic DNS packet analysis
        guard packet.count > 12 else { return true }
        
        // Extract domain from DNS query (simplified)
        if let domain = extractDomainFromDNSPacket(packet) {
            let isBlocked = isDomainBlocked(domain)
            if isBlocked {
                logger.info("Blocked domain: \(domain)")
            }
            return !isBlocked
        }
        
        return true
    }
    
    private func extractDomainFromDNSPacket(_ packet: Data) -> String? {
        // Simplified DNS parsing - in production use proper DNS library
        guard packet.count > 20 else { return nil }
        
        var domain = ""
        var index = 12
        
        while index < packet.count && index < 256 {
            let length = Int(packet[index])
            guard length > 0 && length < 64 else { break }
            
            index += 1
            guard index + length <= packet.count else { break }
            
            if !domain.isEmpty {
                domain += "."
            }
            
            if let part = String(data: packet[index..<index+length], encoding: .ascii) {
                domain += part
            }
            
            index += length
        }
        
        return domain.isEmpty ? nil : domain
    }
    
    private func isDomainBlocked(_ domain: String) -> Bool {
        let normalizedDomain = domain.lowercased()
        
        // Check exact match
        if blockedDomains.contains(normalizedDomain) {
            return true
        }
        
        // Check if any blocked domain is a suffix (subdomain blocking)
        return blockedDomains.contains { blockedDomain in
            normalizedDomain.hasSuffix("." + blockedDomain) || normalizedDomain == blockedDomain
        }
    }
    
    private func recordBlockedAttempt() {
        guard let defaults = appGroupDefaults else { return }
        
        let currentCount = defaults.integer(forKey: "totalBlockedAttempts")
        defaults.set(currentCount + 1, forKey: "totalBlockedAttempts")
        defaults.synchronize()
    }
}


