//
//  SettingsView.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    
    init() {
        _viewModel = State(wrappedValue: SettingsViewModel())
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Premium Section
                if !viewModel.isPremium {
                    Section {
                        PremiumCard(viewModel: viewModel)
                    }
                }
                
                // General Settings
                Section("General") {
                    Toggle("Protection Enabled", isOn: .constant(viewModel.isProtectionEnabled))
                        .onChange(of: viewModel.isProtectionEnabled) { _ in
                            viewModel.toggleProtection()
                        }
                    
                    Toggle("Notifications", isOn: .constant(viewModel.notificationsEnabled))
                        .onChange(of: viewModel.notificationsEnabled) { _ in
                            viewModel.toggleNotifications()
                        }
                    
                    Toggle("Sound Effects", isOn: .constant(viewModel.soundEnabled))
                        .onChange(of: viewModel.soundEnabled) { _ in
                            viewModel.toggleSound()
                        }
                }
                
                // Blocking Mode
                Section {
                    Picker("Blocking Mode", selection: $viewModel.selectedBlockingMode) {
                        ForEach(BlockingMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    
                    Text(viewModel.selectedBlockingMode.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Blocking Mode")
                }
                
                // Appearance
                Section("Appearance") {
                    Picker("Theme", selection: $viewModel.selectedTheme) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }
                
                // Statistics
                Section("Statistics") {
                    NavigationLink {
                        StatisticsView(statistics: viewModel.statistics)
                    } label: {
                        LabeledContent("Total Blocks", value: viewModel.totalBlocksText)
                    }
                    
                    LabeledContent("Connected Devices", value: viewModel.totalDevicesText)
                    LabeledContent("Protection Active", value: viewModel.daysSinceStartText)
                    
                    Button("Export Statistics") {
                        let csv = viewModel.exportStatistics()
                        print("Exporting CSV: \(csv)")
                        // In real app: share/save CSV
                    }
                }
                
                // Data Management
                Section("Data Management") {
                    Button("Reset Statistics") {
                        viewModel.showingResetConfirmation = true
                    }
                    
                    Button("Clear All Data", role: .destructive) {
                        viewModel.resetAllData()
                    }
                }
                
                // Support
                Section("Support") {
                    Button("Privacy Policy") {
                        viewModel.openPrivacyPolicy()
                    }
                    
                    Button("Terms of Service") {
                        viewModel.openTermsOfService()
                    }
                    
                    Button("Help & Support") {
                        viewModel.openSupport()
                    }
                    
                    Button("Contact Us") {
                        viewModel.contactSupport()
                    }
                }
                
                // About
                Section("About") {
                    LabeledContent("Version", value: viewModel.appVersionText)
                    
                    if viewModel.isPremium {
                        Label("Premium Active", systemImage: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $viewModel.showingPurchaseSheet) {
                PremiumPurchaseView(viewModel: viewModel)
            }
            .confirmationDialog("Reset Statistics", isPresented: $viewModel.showingResetConfirmation) {
                Button("Reset", role: .destructive) {
                    viewModel.resetStatistics()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear all statistics data. This action cannot be undone.")
            }
            .alert("Success", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") {
                    viewModel.successMessage = nil
                }
            } message: {
                if let message = viewModel.successMessage {
                    Text(message)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Premium Card

struct PremiumCard: View {
    @Bindable var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
            
            Text("Upgrade to Premium")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Remove ads and unlock advanced features")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                viewModel.showingPurchaseSheet = true
            } label: {
                Text("Upgrade Now")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

// MARK: - Premium Purchase View

struct PremiumPurchaseView: View {
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                        .padding(.top, 40)
                    
                    Text("PocketFence Premium")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "xmark.circle.fill", title: "Ad-Free Experience", description: "Remove all advertisements")
                        FeatureRow(icon: "chart.bar.fill", title: "Advanced Statistics", description: "Detailed reports and insights")
                        FeatureRow(icon: "person.3.fill", title: "Multiple Profiles", description: "Manage different user profiles")
                        FeatureRow(icon: "questionmark.circle.fill", title: "Priority Support", description: "Get help faster")
                    }
                    .padding()
                    
                    // Price
                    VStack(spacing: 8) {
                        Text("$4.99")
                            .font(.system(size: 48, weight: .bold))
                        Text("One-time purchase")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Purchase Button
                    Button {
                        Task {
                            await viewModel.purchasePremium()
                            dismiss()
                        }
                    } label: {
                        Text("Purchase Premium")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Restore Button
                    Button {
                        Task {
                            await viewModel.restorePurchases()
                        }
                    } label: {
                        Text("Restore Purchase")
                            .font(.subheadline)
                    }
                    .padding()
                    
                    // Terms
                    Text("Terms and conditions apply")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 40)
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Statistics View

struct StatisticsView: View {
    let statistics: Statistics
    
    var body: some View {
        List {
            Section("Overall") {
                LabeledContent("Total Blocks", value: "\(statistics.totalBlockedAttempts)")
                LabeledContent("Total Devices", value: "\(statistics.totalConnectedDevices)")
                LabeledContent("Blocked Sites", value: "\(statistics.totalBlockedSites)")
                LabeledContent("Days Active", value: "\(statistics.daysSinceStart)")
                LabeledContent("Avg Blocks/Day", value: String(format: "%.1f", statistics.averageBlocksPerDay))
            }
            
            Section("This Week") {
                LabeledContent("Blocks", value: "\(statistics.weeklyBlocks)")
            }
            
            if let todayStats = statistics.todayStats {
                Section("Today") {
                    LabeledContent("Blocks", value: "\(todayStats.blockedAttempts)")
                    LabeledContent("Active Devices", value: "\(todayStats.activeDevices)")
                    
                    if !todayStats.topBlockedDomains.isEmpty {
                        ForEach(todayStats.topDomains(limit: 5), id: \.domain) { item in
                            LabeledContent(item.domain, value: "\(item.count)")
                        }
                    }
                }
            }
        }
        .navigationTitle("Statistics")
    }
}

#Preview {
    SettingsView()
}
