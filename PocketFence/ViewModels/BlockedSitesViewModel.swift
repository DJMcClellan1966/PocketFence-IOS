//
//  BlockedSitesViewModel.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation
import Combine

/// ViewModel for the Blocked Sites tab
@MainActor
class BlockedSitesViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var blockedSites: [BlockedWebsite] = []
    @Published var selectedCategory: WebsiteCategory?
    @Published var searchText = ""
    @Published var showingAddSite = false
    @Published var showingCategoryPicker = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    private let blockedSiteRepo = BlockedSiteRepository.shared
    private let blockingService = BlockingService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupObservers()
        loadBlockedSites()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        blockedSiteRepo.$blockedSites
            .assign(to: &$blockedSites)
    }
    
    // MARK: - Data Loading
    
    func loadBlockedSites() {
        blockedSiteRepo.loadBlockedSites()
    }
    
    // MARK: - Filtering
    
    var filteredSites: [BlockedWebsite] {
        var sites = blockedSites
        
        // Filter by category if selected
        if let category = selectedCategory {
            sites = sites.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            sites = sites.filter { site in
                site.domain.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return sites.sorted { $0.domain < $1.domain }
    }
    
    var sitesByCategory: [WebsiteCategory: [BlockedWebsite]] {
        Dictionary(grouping: blockedSites) { $0.category }
    }
    
    // MARK: - Site Actions
    
    func addBlockedSite(domain: String, category: WebsiteCategory) {
        guard !domain.isEmpty else {
            errorMessage = "Domain cannot be empty"
            return
        }
        
        // Validate domain format
        guard isValidDomain(domain) else {
            errorMessage = "Invalid domain format"
            return
        }
        
        let site = BlockedWebsite(domain: domain, category: category)
        blockedSiteRepo.addBlockedSite(site)
    }
    
    func removeSite(_ site: BlockedWebsite) {
        blockedSiteRepo.removeBlockedSite(site)
    }
    
    func toggleSiteEnabled(_ site: BlockedWebsite) {
        blockedSiteRepo.toggleSiteEnabled(site.id)
    }
    
    func updateSite(_ site: BlockedWebsite) {
        blockedSiteRepo.updateBlockedSite(site)
    }
    
    // MARK: - Category Actions
    
    func blockCategory(_ category: WebsiteCategory) {
        blockingService.blockCategory(category)
    }
    
    func unblockCategory(_ category: WebsiteCategory) {
        blockingService.unblockCategory(category)
    }
    
    func getCategoryBlockedCount(_ category: WebsiteCategory) -> Int {
        blockedSiteRepo.getBlockedSites(for: category).count
    }
    
    func isCategoryBlocked(_ category: WebsiteCategory) -> Bool {
        !blockedSiteRepo.getBlockedSites(for: category).isEmpty
    }
    
    // MARK: - Bulk Actions
    
    func removeAllSites() {
        blockedSiteRepo.clearAll()
    }
    
    func enableAllSites() {
        for site in blockedSites where !site.isEnabled {
            blockedSiteRepo.toggleSiteEnabled(site.id)
        }
    }
    
    func disableAllSites() {
        for site in blockedSites where site.isEnabled {
            blockedSiteRepo.toggleSiteEnabled(site.id)
        }
    }
    
    // MARK: - Validation
    
    private func isValidDomain(_ domain: String) -> Bool {
        // Basic domain validation
        let domainRegex = "^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        let domainPredicate = NSPredicate(format: "SELF MATCHES %@", domainRegex)
        return domainPredicate.evaluate(with: domain)
    }
    
    // MARK: - Statistics
    
    var totalBlockedSites: Int {
        blockedSites.count
    }
    
    var enabledSitesCount: Int {
        blockedSites.filter { $0.isEnabled }.count
    }
    
    var totalBlockCount: Int {
        blockedSites.reduce(0) { $0 + $1.blockCount }
    }
    
    func getMostBlockedSites(limit: Int = 5) -> [BlockedWebsite] {
        blockedSites
            .sorted { $0.blockCount > $1.blockCount }
            .prefix(limit)
            .map { $0 }
    }
}
