//
//  WellnessInsight.swift
//  ScreenBalance
//
//  Created on 2025
//  Copyright © 2025 ScreenBalance. All rights reserved.
//

import Foundation

/// Represents an AI-generated insight about digital wellness
struct WellnessInsight: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var message: String
    var category: InsightCategory
    var timestamp: Date
    var priority: Priority
    var actionable: Bool
    var suggestedActions: [String]
    
    init(
        id: UUID = UUID(),
        title: String,
        message: String,
        category: InsightCategory,
        timestamp: Date = Date(),
        priority: Priority = .medium,
        actionable: Bool = false,
        suggestedActions: [String] = []
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.category = category
        self.timestamp = timestamp
        self.priority = priority
        self.actionable = actionable
        self.suggestedActions = suggestedActions
    }
    
    /// Generate insights based on usage patterns
    static func generateInsights(
        screenTime: TimeInterval,
        breaksTaken: Int,
        distractionCount: Int,
        focusSessions: Int
    ) -> [WellnessInsight] {
        var insights: [WellnessInsight] = []
        let hours = screenTime / 3600
        
        // Screen time insights
        if hours > 6 {
            insights.append(
                WellnessInsight(
                    title: "High Screen Time Alert",
                    message: "You've spent \(String(format: "%.1f", hours)) hours on screen today. Consider taking an extended break.",
                    category: .screenTime,
                    priority: .high,
                    actionable: true,
                    suggestedActions: ["Take a 15-minute walk", "Try a 5-minute meditation", "Stretch your body"]
                )
            )
        } else if hours > 4 && breaksTaken < 3 {
            insights.append(
                WellnessInsight(
                    title: "Break Reminder",
                    message: "You've been focused for a while. A short break can boost your productivity.",
                    category: .breaks,
                    priority: .medium,
                    actionable: true,
                    suggestedActions: ["5-minute walk", "Eye rest exercise", "Drink water"]
                )
            )
        }
        
        // Focus session insights
        if focusSessions >= 3 {
            insights.append(
                WellnessInsight(
                    title: "Excellent Focus Today! 🎉",
                    message: "You've completed \(focusSessions) focus sessions. Your productivity is outstanding!",
                    category: .achievement,
                    priority: .low,
                    actionable: false,
                    suggestedActions: []
                )
            )
        }
        
        // Distraction insights
        if distractionCount > 15 {
            insights.append(
                WellnessInsight(
                    title: "High Distraction Level",
                    message: "You've been distracted \(distractionCount) times today. Try a focused session to regain concentration.",
                    category: .focus,
                    priority: .high,
                    actionable: true,
                    suggestedActions: ["Start a 25-min focus session", "Turn off notifications", "Use Do Not Disturb mode"]
                )
            )
        }
        
        // Pattern-based insights
        let currentHour = Calendar.current.component(.hour, from: Date())
        if currentHour >= 22 && screenTime > 3600 {
            insights.append(
                WellnessInsight(
                    title: "Late Night Screen Time",
                    message: "Using screens late at night can affect sleep quality. Consider winding down.",
                    category: .wellbeing,
                    priority: .medium,
                    actionable: true,
                    suggestedActions: ["Enable Night Shift", "Start bedtime routine", "Read a book instead"]
                )
            )
        }
        
        return insights
    }
}

/// Categories of insights
enum InsightCategory: String, Codable, CaseIterable {
    case screenTime = "Screen Time"
    case breaks = "Breaks"
    case focus = "Focus"
    case achievement = "Achievement"
    case wellbeing = "Wellbeing"
    case patterns = "Patterns"
    
    var icon: String {
        switch self {
        case .screenTime: return "clock.fill"
        case .breaks: return "pause.circle.fill"
        case .focus: return "target"
        case .achievement: return "star.fill"
        case .wellbeing: return "heart.fill"
        case .patterns: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var color: String {
        switch self {
        case .screenTime: return "blue"
        case .breaks: return "green"
        case .focus: return "purple"
        case .achievement: return "yellow"
        case .wellbeing: return "pink"
        case .patterns: return "orange"
        }
    }
}

/// Priority levels for insights
enum Priority: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}
