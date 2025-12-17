//
//  BlockedSiteRepository.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Combine

/// Repository for managing blocked websites data persistence
class BlockedSiteRepository: ObservableObject {
    static let shared = BlockedSiteRepository()
    
    @Published private(set) var blockedSites: [BlockedWebsite] = []
    
    private let userDefaults = UserDefaults.standard
    private let blockedSitesKey = "pocketfence.blockedSites"
    
    private init() {
        loadBlockedSites()
    }
    
    // MARK: - Public Methods
    
    /// Load all blocked sites from storage
    func loadBlockedSites() {
        guard let data = userDefaults.data(forKey: blockedSitesKey),
              let decoded = try? JSONDecoder().decode([BlockedWebsite].self, from: data) else {
            blockedSites = []
            return
        }
        blockedSites = decoded
    }
    
    /// Save all blocked sites to storage
    func saveBlockedSites() {
        guard let encoded = try? JSONEncoder().encode(blockedSites) else { return }
        userDefaults.set(encoded, forKey: blockedSitesKey)
    }
    
    /// Add a new blocked website
    func addBlockedSite(_ site: BlockedWebsite) {
        // Check if site already exists
        if let index = blockedSites.firstIndex(where: { $0.normalizedDomain == site.normalizedDomain }) {
            blockedSites[index] = site
        } else {
            blockedSites.append(site)
        }
        saveBlockedSites()
    }
    
    /// Add multiple blocked websites (for category presets)
    func addBlockedSites(_ sites: [BlockedWebsite]) {
        for site in sites {
            // Only add if not already present
            if !blockedSites.contains(where: { $0.normalizedDomain == site.normalizedDomain }) {
                blockedSites.append(site)
            }
        }
        saveBlockedSites()
    }
    
    /// Update an existing blocked site
    func updateBlockedSite(_ site: BlockedWebsite) {
        guard let index = blockedSites.firstIndex(where: { $0.id == site.id }) else { return }
        blockedSites[index] = site
        saveBlockedSites()
    }
    
    /// Remove a blocked site
    func removeBlockedSite(_ site: BlockedWebsite) {
        blockedSites.removeAll { $0.id == site.id }
        saveBlockedSites()
    }
    
    /// Check if a domain is blocked
    func isDomainBlocked(_ domain: String) -> Bool {
        let normalized = domain.lowercased().replacingOccurrences(of: "www.", with: "")
        return blockedSites.contains { site in
            site.isEnabled && (site.normalizedDomain == normalized || normalized.hasSuffix(".\(site.normalizedDomain)"))
        }
    }
    
    /// Increment block count for a domain
    func incrementBlockCount(for domain: String) {
        let normalized = domain.lowercased().replacingOccurrences(of: "www.", with: "")
        guard let index = blockedSites.firstIndex(where: { $0.normalizedDomain == normalized }) else { return }
        
        blockedSites[index].blockCount += 1
        blockedSites[index].lastBlockedDate = Date()
        saveBlockedSites()
    }
    
    /// Get blocked sites by category
    func getBlockedSites(for category: WebsiteCategory) -> [BlockedWebsite] {
        blockedSites.filter { $0.category == category }
    }
    
    /// Get enabled blocked sites
    func getEnabledBlockedSites() -> [BlockedWebsite] {
        blockedSites.filter { $0.isEnabled }
    }
    
    /// Toggle site enabled status
    func toggleSiteEnabled(_ siteId: UUID) {
        guard let index = blockedSites.firstIndex(where: { $0.id == siteId }) else { return }
        blockedSites[index].isEnabled.toggle()
        saveBlockedSites()
    }
    
    /// Remove all sites in a category
    func removeCategory(_ category: WebsiteCategory) {
        blockedSites.removeAll { $0.category == category }
        saveBlockedSites()
    }
    
    /// Get total block count
    func getTotalBlockCount() -> Int {
        blockedSites.reduce(0) { $0 + $1.blockCount }
    }
    
    /// Clear all blocked sites
    func clearAll() {
        blockedSites = []
        userDefaults.removeObject(forKey: blockedSitesKey)
    }
}
