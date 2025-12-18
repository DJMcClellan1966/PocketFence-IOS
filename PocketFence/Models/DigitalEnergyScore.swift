//
//  DigitalEnergyScore.swift
//  ScreenBalance
//
//  Created on 2025
//  Copyright © 2025 ScreenBalance. All rights reserved.
//

import Foundation

/// Represents the user's current digital wellness state
struct DigitalEnergyScore: Identifiable, Codable, Equatable {
    let id: UUID
    var score: Int  // 0-100, where 100 is optimal wellness
    var timestamp: Date
    var factors: WellnessFactors
    var recommendations: [String]
    
    init(
        id: UUID = UUID(),
        score: Int = 100,
        timestamp: Date = Date(),
        factors: WellnessFactors = WellnessFactors(),
        recommendations: [String] = []
    ) {
        self.id = id
        self.score = max(0, min(100, score))
        self.timestamp = timestamp
        self.factors = factors
        self.recommendations = recommendations
    }
    
    /// Calculate score based on various wellness factors
    static func calculate(
        screenTime: TimeInterval,
        breaksTaken: Int,
        focusSessions: Int,
        distractionCount: Int
    ) -> DigitalEnergyScore {
        var score = 100
        var factors = WellnessFactors()
        var recommendations: [String] = []
        
        // Screen time analysis (ideal: < 4 hours per day)
        let hours = screenTime / 3600
        if hours > 6 {
            score -= 30
            factors.screenTimeImpact = -30
            recommendations.append("Your screen time is quite high. Consider taking longer breaks.")
        } else if hours > 4 {
            score -= 15
            factors.screenTimeImpact = -15
            recommendations.append("You're approaching high screen time. Time for a break?")
        } else {
            factors.screenTimeImpact = 0
        }
        
        // Break analysis (ideal: every 30-45 minutes)
        let idealBreaks = max(1, Int(hours * 2))
        if breaksTaken < idealBreaks {
            score -= 20
            factors.breakDeficit = -20
            recommendations.append("Take more frequent breaks to maintain focus and energy.")
        } else {
            factors.breakDeficit = 0
            recommendations.append("Great job taking regular breaks! 🎉")
        }
        
        // Focus session bonus
        if focusSessions > 0 {
            let bonus = min(15, focusSessions * 5)
            score += bonus
            factors.focusBonus = bonus
        }
        
        // Distraction penalty
        if distractionCount > 10 {
            score -= 15
            factors.distractionPenalty = -15
            recommendations.append("You seem distracted today. Try a focused session.")
        } else if distractionCount > 5 {
            score -= 8
            factors.distractionPenalty = -8
        }
        
        // Ensure score is in valid range
        score = max(0, min(100, score))
        
        return DigitalEnergyScore(
            score: score,
            factors: factors,
            recommendations: recommendations
        )
    }
    
    /// Get descriptive level based on score
    var wellnessLevel: WellnessLevel {
        switch score {
        case 80...100:
            return .optimal
        case 60..<80:
            return .good
        case 40..<60:
            return .moderate
        case 20..<40:
            return .low
        default:
            return .critical
        }
    }
    
    /// Get emoji representation of wellness level
    var emoji: String {
        wellnessLevel.emoji
    }
}

/// Factors contributing to wellness score
struct WellnessFactors: Codable, Equatable {
    var screenTimeImpact: Int = 0
    var breakDeficit: Int = 0
    var focusBonus: Int = 0
    var distractionPenalty: Int = 0
}

/// Wellness level categories
enum WellnessLevel: String, Codable {
    case optimal = "Optimal"
    case good = "Good"
    case moderate = "Moderate"
    case low = "Low"
    case critical = "Critical"
    
    var emoji: String {
        switch self {
        case .optimal: return "🌟"
        case .good: return "😊"
        case .moderate: return "😐"
        case .low: return "😕"
        case .critical: return "🔴"
        }
    }
    
    var color: String {
        switch self {
        case .optimal: return "green"
        case .good: return "blue"
        case .moderate: return "yellow"
        case .low: return "orange"
        case .critical: return "red"
        }
    }
}
