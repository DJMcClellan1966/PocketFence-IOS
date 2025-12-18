//
//  WellnessDashboardView.swift
//  ScreenBalance
//
//  Created on 2025
//  Copyright © 2025 ScreenBalance. All rights reserved.
//

import SwiftUI

/// Enhanced dashboard showing digital wellness insights
struct WellnessDashboardView: View {
    @State private var wellnessService = WellnessAnalyticsService.shared
    @State private var viewModel: DashboardViewModel
    @State private var showFocusSessionSheet = false
    @State private var showInsightsSheet = false
    
    init() {
        _viewModel = State(wrappedValue: MainActor.assumeIsolated {
            DashboardViewModel()
        })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Digital Energy Score - The Hero Feature
                    DigitalEnergyCard(
                        score: wellnessService.currentEnergyScore,
                        recommendation: wellnessService.getSmartRecommendation()
                    )
                    
                    // Active Focus Session (if any)
                    if let session = wellnessService.activeFocusSession {
                        ActiveFocusSessionCard(session: session) {
                            wellnessService.endFocusSession()
                        }
                    }
                    
                    // Quick Actions
                    QuickActionsRow(
                        onStartFocus: { showFocusSessionSheet = true },
                        onTakeBreak: { wellnessService.recordBreak() },
                        onViewInsights: { showInsightsSheet = true }
                    )
                    
                    // Today's Insights Preview
                    if !wellnessService.todayInsights.isEmpty {
                        InsightsPreviewCard(insights: Array(wellnessService.todayInsights.prefix(2))) {
                            showInsightsSheet = true
                        }
                    }
                    
                    // Wellness Statistics
                    WellnessStatisticsGrid(
                        activeDevices: viewModel.activeDeviceCount,
                        focusSessions: wellnessService.focusSessionHistory.count,
                        totalBlocked: viewModel.totalBlockedAttempts
                    )
                    
                    // Recent Activity
                    if !viewModel.recentBlocks.isEmpty {
                        RecentActivityCard(blocks: Array(viewModel.recentBlocks.prefix(3)))
                    }
                }
                .padding()
            }
            .navigationTitle("ScreenBalance")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showInsightsSheet = true }) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.wellnessPrimary)
                    }
                }
            }
            .sheet(isPresented: $showFocusSessionSheet) {
                StartFocusSessionSheet { type, duration in
                    wellnessService.startFocusSession(type: type, duration: duration)
                    showFocusSessionSheet = false
                }
            }
            .sheet(isPresented: $showInsightsSheet) {
                InsightsDetailSheet(insights: wellnessService.todayInsights)
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
}

// MARK: - Digital Energy Card

struct DigitalEnergyCard: View {
    let score: DigitalEnergyScore
    let recommendation: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Digital Wellness")
                    .font(.headline)
                Spacer()
                Text(score.emoji)
                    .font(.title)
            }
            
            // Energy Score Circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score.score) / 100)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: score.score)
                
                VStack {
                    Text("\(score.score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(scoreColor)
                    Text(score.wellnessLevel.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical)
            
            // Smart Recommendation
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.wellnessPrimary)
                Text(recommendation)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private var scoreColor: Color {
        switch score.wellnessLevel {
        case .optimal: return .wellnessGreen
        case .good: return .wellnessPrimary
        case .moderate: return .wellnessOrange
        case .low: return .wellnessOrange
        case .critical: return .wellnessRed
        }
    }
}

// MARK: - Active Focus Session Card

struct ActiveFocusSessionCard: View {
    let session: FocusSession
    let onEnd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: session.sessionType.icon)
                    .foregroundColor(.wellnessPurple)
                Text("Focus Session Active")
                    .font(.headline)
                Spacer()
                Button("End", action: onEnd)
                    .font(.subheadline)
                    .foregroundColor(.wellnessPrimary)
            }
            
            Text(session.name)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Text(session.durationString)
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.medium)
                Spacer()
                Text("\(session.distractionCount) distractions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: session.actualDuration, total: session.goalDuration)
                .tint(.wellnessPurple)
        }
        .padding()
        .background(Color.wellnessPurple.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.wellnessPurple.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Quick Actions Row

struct QuickActionsRow: View {
    let onStartFocus: () -> Void
    let onTakeBreak: () -> Void
    let onViewInsights: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                icon: "target",
                title: "Focus",
                color: .wellnessPurple,
                action: onStartFocus
            )
            
            QuickActionButton(
                icon: "pause.circle.fill",
                title: "Break",
                color: .wellnessGreen,
                action: onTakeBreak
            )
            
            QuickActionButton(
                icon: "lightbulb.fill",
                title: "Insights",
                color: .wellnessPrimary,
                action: onViewInsights
            )
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Insights Preview Card

struct InsightsPreviewCard: View {
    let insights: [WellnessInsight]
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today's Insights")
                    .font(.headline)
                Spacer()
                Button("View All", action: onViewAll)
                    .font(.subheadline)
            }
            
            ForEach(insights) { insight in
                InsightRow(insight: insight)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct InsightRow: View {
    let insight: WellnessInsight
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.category.icon)
                .foregroundColor(categoryColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(insight.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        switch insight.category.color {
        case "blue": return .wellnessPrimary
        case "green": return .wellnessGreen
        case "purple": return .wellnessPurple
        case "yellow": return .yellow
        case "pink": return .pink
        case "orange": return .wellnessOrange
        default: return .gray
        }
    }
}

// MARK: - Wellness Statistics Grid

struct WellnessStatisticsGrid: View {
    let activeDevices: Int
    let focusSessions: Int
    let totalBlocked: Int
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatCard(
                icon: "figure.walk",
                title: "Devices",
                value: "\(activeDevices)",
                color: .wellnessPrimary
            )
            
            StatCard(
                icon: "target",
                title: "Focus",
                value: "\(focusSessions)",
                color: .wellnessPurple
            )
            
            StatCard(
                icon: "shield.fill",
                title: "Blocked",
                value: "\(totalBlocked)",
                color: .wellnessGreen
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

// MARK: - Recent Activity Card

struct RecentActivityCard: View {
    let blocks: [(domain: String, count: Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
            
            ForEach(blocks, id: \.domain) { block in
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.wellnessOrange)
                        .font(.caption)
                    Text(block.domain)
                        .font(.subheadline)
                    Spacer()
                    Text("\(block.count)×")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

// MARK: - Supporting Sheets

struct StartFocusSessionSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onStart: (SessionType, TimeInterval) -> Void
    
    @State private var selectedType: SessionType = .work
    @State private var duration: Double = 25
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Session Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(SessionType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }
                
                Section("Duration") {
                    Slider(value: $duration, in: 5...60, step: 5) {
                        Text("Duration")
                    }
                    Text("\(Int(duration)) minutes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Start Focus Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        onStart(selectedType, duration * 60)
                    }
                }
            }
        }
    }
}

struct InsightsDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let insights: [WellnessInsight]
    
    var body: some View {
        NavigationStack {
            List(insights) { insight in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: insight.category.icon)
                            .foregroundColor(.wellnessPrimary)
                        Text(insight.title)
                            .font(.headline)
                    }
                    
                    Text(insight.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !insight.suggestedActions.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Suggested Actions:")
                                .font(.caption)
                                .fontWeight(.medium)
                            ForEach(insight.suggestedActions, id: \.self) { action in
                                Text("• \(action)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Wellness Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    WellnessDashboardView()
}
