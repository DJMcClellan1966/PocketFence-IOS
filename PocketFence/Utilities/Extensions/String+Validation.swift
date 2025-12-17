//
//  String+Validation.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation

extension String {
    /// Validate if string is a valid domain name
    var isValidDomain: Bool {
        let domainRegex = "^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let domainPredicate = NSPredicate(format: "SELF MATCHES %@", domainRegex)
        return domainPredicate.evaluate(with: self)
    }
    
    /// Validate if string is a valid IP address (IPv4)
    var isValidIPv4: Bool {
        let ipRegex = "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
        let ipPredicate = NSPredicate(format: "SELF MATCHES %@", ipRegex)
        return ipPredicate.evaluate(with: self)
    }
    
    /// Validate if string is a valid MAC address
    var isValidMACAddress: Bool {
        let macRegex = "^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$"
        let macPredicate = NSPredicate(format: "SELF MATCHES %@", macRegex)
        return macPredicate.evaluate(with: self)
    }
    
    /// Normalize domain by removing www prefix and lowercasing
    var normalizedDomain: String {
        self.lowercased()
            .replacingOccurrences(of: "www.", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
    
    /// Remove protocol from URL string
    var withoutProtocol: String {
        self.replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
    }
    
    /// Check if string contains only alphanumeric characters
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    /// Truncate string to specified length with ellipsis
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
    /// Convert string to URL
    var url: URL? {
        URL(string: self)
    }
    
    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        trimmingCharacters(in: .whitespaces).isEmpty
    }
}
