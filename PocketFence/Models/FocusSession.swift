//
//  FocusSession.swift
//  ScreenBalance
//
//  Created on 2025
//  Copyright © 2025 ScreenBalance. All rights reserved.
//

import Foundation

/// Represents a focused work session
struct FocusSession: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var startTime: Date
    var endTime: Date?
    var goalDuration: TimeInterval  // in seconds
    var distractionCount: Int
    var isActive: Bool
    var sessionType: SessionType
    
    init(
        id: UUID = UUID(),
        name: String = "Focus Session",
        startTime: Date = Date(),
        endTime: Date? = nil,
        goalDuration: TimeInterval = 1500,  // 25 minutes default
        distractionCount: Int = 0,
        isActive: Bool = true,
        sessionType: SessionType = .work
    ) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.goalDuration = goalDuration
        self.distractionCount = distractionCount
        self.isActive = isActive
        self.sessionType = sessionType
    }
    
    /// Calculate actual duration of the session
    var actualDuration: TimeInterval {
        if let end = endTime {
            return end.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
    
    /// Calculate success rate (0.0 to 1.0)
    var successRate: Double {
        let timeRate = min(1.0, actualDuration / goalDuration)
        let distractionRate = max(0.0, 1.0 - (Double(distractionCount) * 0.1))
        return (timeRate + distractionRate) / 2.0
    }
    
    /// Check if goal was achieved
    var goalAchieved: Bool {
        actualDuration >= goalDuration && distractionCount < 5
    }
    
    /// Get formatted duration string
    var durationString: String {
        let duration = isActive ? actualDuration : (endTime?.timeIntervalSince(startTime) ?? 0)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

/// Types of focus sessions
enum SessionType: String, Codable, CaseIterable {
    case work = "Work"
    case study = "Study"
    case creative = "Creative"
    case deepFocus = "Deep Focus"
    case reading = "Reading"
    case meditation = "Meditation"
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .study: return "book.fill"
        case .creative: return "paintbrush.fill"
        case .deepFocus: return "brain.head.profile"
        case .reading: return "text.book.closed.fill"
        case .meditation: return "figure.mind.and.body"
        }
    }
    
    var suggestedDuration: TimeInterval {
        switch self {
        case .work: return 1500  // 25 minutes
        case .study: return 1800  // 30 minutes
        case .creative: return 2700  // 45 minutes
        case .deepFocus: return 3600  // 60 minutes
        case .reading: return 1200  // 20 minutes
        case .meditation: return 600  // 10 minutes
        }
    }
}
