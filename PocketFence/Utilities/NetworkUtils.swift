//
//  NetworkUtils.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Network

/// Utility functions for network operations
enum NetworkUtils {
    
    // MARK: - Domain Matching
    
    /// Check if a URL's domain matches a blocked domain
    static func isDomainBlocked(_ url: URL, against blockedDomains: [String]) -> Bool {
        guard let host = url.host else { return false }
        
        let normalizedHost = host.lowercased().replacingOccurrences(of: "www.", with: "")
        
        for blockedDomain in blockedDomains {
            let normalizedBlocked = blockedDomain.lowercased().replacingOccurrences(of: "www.", with: "")
            
            // Exact match
            if normalizedHost == normalizedBlocked {
                return true
            }
            
            // Subdomain match
            if normalizedHost.hasSuffix(".\(normalizedBlocked)") {
                return true
            }
        }
        
        return false
    }
    
    /// Extract domain from URL string
    static func extractDomain(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return url.host
    }
    
    // MARK: - IP Address
    
    /// Validate IPv4 address format
    static func isValidIPv4(_ ip: String) -> Bool {
        let parts = ip.split(separator: ".")
        guard parts.count == 4 else { return false }
        
        for part in parts {
            guard let num = Int(part), num >= 0 && num <= 255 else {
                return false
            }
        }
        
        return true
    }
    
    /// Get local IP addresses
    static func getLocalIPAddresses() -> [String] {
        var addresses: [String] = []
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return addresses }
        guard let firstAddr = ifaddr else { return addresses }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) {
                let name = String(cString: interface.ifa_name)
                
                // Skip loopback
                if name != "lo0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr,
                              socklen_t(interface.ifa_addr.pointee.sa_len),
                              &hostname,
                              socklen_t(hostname.count),
                              nil,
                              socklen_t(0),
                              NI_NUMERICHOST)
                    addresses.append(String(cString: hostname))
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return addresses
    }
    
    // MARK: - Network Status
    
    /// Check if device is connected to network
    static func isConnectedToNetwork() -> Bool {
        let monitor = NWPathMonitor()
        
        // Use actor-isolated class to safely capture the connection status
        final class ConnectionState: @unchecked Sendable {
            private let lock = NSLock()
            private var _isConnected = false
            
            var isConnected: Bool {
                get {
                    lock.lock()
                    defer { lock.unlock() }
                    return _isConnected
                }
                set {
                    lock.lock()
                    defer { lock.unlock() }
                    _isConnected = newValue
                }
            }
        }
        
        let state = ConnectionState()
        let semaphore = DispatchSemaphore(value: 0)
        
        monitor.pathUpdateHandler = { path in
            state.isConnected = path.status == .satisfied
            semaphore.signal()
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        _ = semaphore.wait(timeout: .now() + 1.0)
        monitor.cancel()
        
        return state.isConnected
    }
    
    // MARK: - DNS
    
    /// Perform DNS lookup for a domain
    static func resolveDNS(for domain: String, completion: @escaping ([String]) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            var addresses: [String] = []
            
            var hints = addrinfo()
            hints.ai_family = AF_INET // IPv4
            hints.ai_socktype = SOCK_STREAM
            
            var result: UnsafeMutablePointer<addrinfo>?
            let status = getaddrinfo(domain, nil, &hints, &result)
            
            if status == 0 {
                var res = result
                while res != nil {
                    if let addr = res?.pointee.ai_addr {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(addr,
                                  socklen_t(res!.pointee.ai_addrlen),
                                  &hostname,
                                  socklen_t(hostname.count),
                                  nil,
                                  0,
                                  NI_NUMERICHOST)
                        addresses.append(String(cString: hostname))
                    }
                    res = res?.pointee.ai_next
                }
                freeaddrinfo(result)
            }
            
            DispatchQueue.main.async {
                completion(addresses)
            }
        }
    }
    
    // MARK: - URL Normalization
    
    /// Normalize URL for comparison
    static func normalizeURL(_ urlString: String) -> String {
        var normalized = urlString.lowercased()
        
        // Remove protocol
        normalized = normalized.replacingOccurrences(of: "https://", with: "")
        normalized = normalized.replacingOccurrences(of: "http://", with: "")
        
        // Remove www
        normalized = normalized.replacingOccurrences(of: "www.", with: "")
        
        // Remove trailing slash
        if normalized.hasSuffix("/") {
            normalized = String(normalized.dropLast())
        }
        
        return normalized
    }
}
