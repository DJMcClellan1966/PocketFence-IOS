//
//  BlockedWebsite.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import Foundation

/// Categories for website blocking
enum WebsiteCategory: String, Codable, CaseIterable, Identifiable {
    case socialMedia = "Social Media"
    case adultContent = "Adult Content"
    case gambling = "Gambling"
    case gaming = "Gaming"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .socialMedia: return "person.3.fill"
        case .adultContent: return "hand.raised.fill"
        case .gambling: return "suit.club.fill"
        case .gaming: return "gamecontroller.fill"
        case .custom: return "star.fill"
        }
    }
    
    var description: String {
        switch self {
        case .socialMedia:
            return "Block popular social media platforms"
        case .adultContent:
            return "Block adult and inappropriate content"
        case .gambling:
            return "Block gambling and betting websites"
        case .gaming:
            return "Block online gaming platforms"
        case .custom:
            return "Custom websites added by you"
        }
    }
}

/// Represents a blocked website or domain
struct BlockedWebsite: Identifiable, Codable, Equatable {
    let id: UUID
    var domain: String
    var category: WebsiteCategory
    var isEnabled: Bool
    var addedDate: Date
    var blockCount: Int
    var lastBlockedDate: Date?
    
    init(
        id: UUID = UUID(),
        domain: String,
        category: WebsiteCategory,
        isEnabled: Bool = true,
        addedDate: Date = Date(),
        blockCount: Int = 0,
        lastBlockedDate: Date? = nil
    ) {
        self.id = id
        self.domain = domain.lowercased().trimmingCharacters(in: .whitespaces)
        self.category = category
        self.isEnabled = isEnabled
        self.addedDate = addedDate
        self.blockCount = blockCount
        self.lastBlockedDate = lastBlockedDate
    }
    
    /// Normalized domain without www prefix
    var normalizedDomain: String {
        domain.replacingOccurrences(of: "www.", with: "")
    }
    
    /// Display-friendly domain name
    var displayDomain: String {
        normalizedDomain
    }
}

// MARK: - Preset Blocked Websites
extension BlockedWebsite {
    /// Social Media presets
    static let socialMediaSites: [BlockedWebsite] = [
        BlockedWebsite(domain: "facebook.com", category: .socialMedia),
        BlockedWebsite(domain: "instagram.com", category: .socialMedia),
        BlockedWebsite(domain: "twitter.com", category: .socialMedia),
        BlockedWebsite(domain: "x.com", category: .socialMedia),
        BlockedWebsite(domain: "tiktok.com", category: .socialMedia),
        BlockedWebsite(domain: "snapchat.com", category: .socialMedia),
        BlockedWebsite(domain: "reddit.com", category: .socialMedia),
        BlockedWebsite(domain: "linkedin.com", category: .socialMedia),
        BlockedWebsite(domain: "pinterest.com", category: .socialMedia),
        BlockedWebsite(domain: "tumblr.com", category: .socialMedia),
        BlockedWebsite(domain: "youtube.com", category: .socialMedia),
        BlockedWebsite(domain: "twitch.tv", category: .socialMedia)
    ]
    
    /// Gaming presets
    static let gamingSites: [BlockedWebsite] = [
        BlockedWebsite(domain: "roblox.com", category: .gaming),
        BlockedWebsite(domain: "minecraft.net", category: .gaming),
        BlockedWebsite(domain: "fortnite.com", category: .gaming),
        BlockedWebsite(domain: "epicgames.com", category: .gaming),
        BlockedWebsite(domain: "steam.com", category: .gaming),
        BlockedWebsite(domain: "steampowered.com", category: .gaming),
        BlockedWebsite(domain: "playstation.com", category: .gaming),
        BlockedWebsite(domain: "xbox.com", category: .gaming),
        BlockedWebsite(domain: "ea.com", category: .gaming),
        BlockedWebsite(domain: "origin.com", category: .gaming)
    ]
    
    /// Gambling presets
    static let gamblingSites: [BlockedWebsite] = [
        BlockedWebsite(domain: "bet365.com", category: .gambling),
        BlockedWebsite(domain: "draftkings.com", category: .gambling),
        BlockedWebsite(domain: "fanduel.com", category: .gambling),
        BlockedWebsite(domain: "pokerstars.com", category: .gambling),
        BlockedWebsite(domain: "betfair.com", category: .gambling),
        BlockedWebsite(domain: "888casino.com", category: .gambling),
        BlockedWebsite(domain: "williamhill.com", category: .gambling)
    ]
    
    /// Sample data for previews
    static let sample = BlockedWebsite(
        domain: "facebook.com",
        category: .socialMedia,
        blockCount: 15,
        lastBlockedDate: Date()
    )
    
    static let samples: [BlockedWebsite] = [
        BlockedWebsite(domain: "facebook.com", category: .socialMedia, blockCount: 15),
        BlockedWebsite(domain: "instagram.com", category: .socialMedia, blockCount: 23),
        BlockedWebsite(domain: "tiktok.com", category: .socialMedia, blockCount: 42),
        BlockedWebsite(domain: "roblox.com", category: .gaming, blockCount: 8),
        BlockedWebsite(domain: "customsite.com", category: .custom, blockCount: 3)
    ]
}
