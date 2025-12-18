//
//  WellnessAnalyticsService.swift
//  ScreenBalance
//
//  Created on 2025
//  Copyright © 2025 ScreenBalance. All rights reserved.
//

import Foundation
import Observation

/// Service for analyzing digital wellness patterns and generating insights
@Observable
final class WellnessAnalyticsService {
    static let shared = WellnessAnalyticsService()
    
    // MARK: - Properties
    
    private(set) var currentEnergyScore: DigitalEnergyScore
    private(set) var todayInsights: [WellnessInsight] = []
    private(set) var activeFocusSession: FocusSession?
    private(set) var focusSessionHistory: [FocusSession] = []
    
    // Usage tracking
    private var screenTimeToday: TimeInterval = 0
    private var breaksTakenToday: Int = 0
    private var distractionsToday: Int = 0
    private var lastBreakTime: Date?
    
    // Timer for periodic updates
    private var updateTimer: Timer?
    
    // MARK: - Initialization
    
    private init() {
        // Initialize with default score
        self.currentEnergyScore = DigitalEnergyScore()
        
        // Load saved data
        loadData()
        
        // Start periodic updates
        startPeriodicUpdates()
    }
    
    // MARK: - Public Methods
    
    /// Update screen time and recalculate wellness score
    func trackScreenTime(_ duration: TimeInterval) {
        screenTimeToday += duration
        updateEnergyScore()
    }
    
    /// Record a break taken
    func recordBreak() {
        breaksTakenToday += 1
        lastBreakTime = Date()
        updateEnergyScore()
        
        // Generate positive reinforcement
        if breaksTakenToday % 3 == 0 {
            let insight = WellnessInsight(
                title: "Great Job! 👏",
                message: "You've taken \(breaksTakenToday) breaks today. Keep up the healthy habits!",
                category: .achievement,
                priority: .low,
                actionable: false
            )
            todayInsights.append(insight)
        }
    }
    
    /// Record a distraction event
    func recordDistraction() {
        distractionsToday += 1
        
        // Update active focus session if exists
        activeFocusSession?.distractionCount += 1
        
        updateEnergyScore()
    }
    
    /// Start a new focus session
    func startFocusSession(type: SessionType, duration: TimeInterval) {
        let session = FocusSession(
            name: type.rawValue,
            goalDuration: duration,
            sessionType: type
        )
        activeFocusSession = session
        saveData()
    }
    
    /// End the current focus session
    func endFocusSession() {
        guard var session = activeFocusSession else { return }
        
        session.endTime = Date()
        session.isActive = false
        focusSessionHistory.append(session)
        activeFocusSession = nil
        
        // Generate insight about session
        let insight = WellnessInsight(
            title: session.goalAchieved ? "Focus Session Complete! 🎯" : "Session Ended",
            message: session.goalAchieved 
                ? "You successfully completed a \(session.durationString) focus session."
                : "You completed a \(session.durationString) focus session. Keep building that focus muscle!",
            category: .achievement,
            priority: .low,
            actionable: false
        )
        todayInsights.append(insight)
        
        updateEnergyScore()
        saveData()
    }
    
    /// Get wellness recommendation based on current state
    func getSmartRecommendation() -> String {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        
        // Check if break is needed
        if let lastBreak = lastBreakTime {
            let timeSinceBreak = now.timeIntervalSince(lastBreak)
            if timeSinceBreak > 2700 {  // 45 minutes
                return "You haven't taken a break in 45+ minutes. Time to rest your eyes! 👀"
            }
        }
        
        // Morning boost
        if hour >= 6 && hour < 10 {
            return "Good morning! Start your day with a focused session. Your mind is fresh! 🌅"
        }
        
        // Afternoon slump
        if hour >= 14 && hour < 16 {
            return "Afternoon energy dip? Try a quick 5-minute walk or stretch. 🚶"
        }
        
        // Evening wind-down
        if hour >= 20 {
            return "Evening time. Consider reducing screen time for better sleep. 🌙"
        }
        
        // Based on energy score
        if currentEnergyScore.score < 50 {
            return "Your energy is low. Take a break and recharge! ⚡"
        }
        
        // Default positive message
        return "You're doing great! Keep maintaining that healthy balance. 🌟"
    }
    
    /// Predict if user is entering unhealthy pattern
    func predictUnhealthyPattern() -> Bool {
        // Simple pattern detection
        let recentDistractions = distractionsToday > 10
        let excessiveScreenTime = screenTimeToday > 21600  // 6 hours
        let insufficientBreaks = breaksTakenToday < 2 && screenTimeToday > 7200  // 2 hours
        
        return recentDistractions || excessiveScreenTime || insufficientBreaks
    }
    
    /// Reset daily statistics (called at midnight)
    func resetDailyStats() {
        screenTimeToday = 0
        breaksTakenToday = 0
        distractionsToday = 0
        todayInsights.removeAll()
        
        // Archive completed focus sessions
        focusSessionHistory = focusSessionHistory.filter { session in
            guard let endTime = session.endTime else { return true }
            return Calendar.current.isDateInToday(endTime)
        }
        
        updateEnergyScore()
        saveData()
    }
    
    // MARK: - Private Methods
    
    private func updateEnergyScore() {
        let focusCount = focusSessionHistory.filter { session in
            Calendar.current.isDateInToday(session.startTime)
        }.count
        
        currentEnergyScore = DigitalEnergyScore.calculate(
            screenTime: screenTimeToday,
            breaksTaken: breaksTakenToday,
            focusSessions: focusCount,
            distractionCount: distractionsToday
        )
        
        // Generate new insights
        generateInsights()
        
        saveData()
    }
    
    private func generateInsights() {
        let newInsights = WellnessInsight.generateInsights(
            screenTime: screenTimeToday,
            breaksTaken: breaksTakenToday,
            distractionCount: distractionsToday,
            focusSessions: focusSessionHistory.count
        )
        
        // Add only new insights (avoid duplicates)
        for insight in newInsights {
            if !todayInsights.contains(where: { $0.title == insight.title }) {
                todayInsights.append(insight)
            }
        }
    }
    
    private func startPeriodicUpdates() {
        // Update every 10 minutes to minimize battery impact
        // Updates also trigger on user actions (breaks, focus sessions, etc.)
        updateTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { [weak self] _ in
            self?.updateEnergyScore()
        }
    }
    
    private func loadData() {
        let defaults = UserDefaults.standard
        
        if let scoreData = defaults.data(forKey: "currentEnergyScore"),
           let score = try? JSONDecoder().decode(DigitalEnergyScore.self, from: scoreData) {
            currentEnergyScore = score
        }
        
        if let insightsData = defaults.data(forKey: "todayInsights"),
           let insights = try? JSONDecoder().decode([WellnessInsight].self, from: insightsData) {
            todayInsights = insights
        }
        
        if let sessionData = defaults.data(forKey: "activeFocusSession"),
           let session = try? JSONDecoder().decode(FocusSession.self, from: sessionData) {
            activeFocusSession = session
        }
        
        if let historyData = defaults.data(forKey: "focusSessionHistory"),
           let history = try? JSONDecoder().decode([FocusSession].self, from: historyData) {
            focusSessionHistory = history
        }
        
        screenTimeToday = defaults.double(forKey: "screenTimeToday")
        breaksTakenToday = defaults.integer(forKey: "breaksTakenToday")
        distractionsToday = defaults.integer(forKey: "distractionsToday")
        
        if let lastBreak = defaults.object(forKey: "lastBreakTime") as? Date {
            lastBreakTime = lastBreak
        }
    }
    
    private func saveData() {
        let defaults = UserDefaults.standard
        
        if let scoreData = try? JSONEncoder().encode(currentEnergyScore) {
            defaults.set(scoreData, forKey: "currentEnergyScore")
        }
        
        if let insightsData = try? JSONEncoder().encode(todayInsights) {
            defaults.set(insightsData, forKey: "todayInsights")
        }
        
        if let session = activeFocusSession,
           let sessionData = try? JSONEncoder().encode(session) {
            defaults.set(sessionData, forKey: "activeFocusSession")
        } else {
            defaults.removeObject(forKey: "activeFocusSession")
        }
        
        if let historyData = try? JSONEncoder().encode(focusSessionHistory) {
            defaults.set(historyData, forKey: "focusSessionHistory")
        }
        
        defaults.set(screenTimeToday, forKey: "screenTimeToday")
        defaults.set(breaksTakenToday, forKey: "breaksTakenToday")
        defaults.set(distractionsToday, forKey: "distractionsToday")
        
        if let lastBreak = lastBreakTime {
            defaults.set(lastBreak, forKey: "lastBreakTime")
        }
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}
