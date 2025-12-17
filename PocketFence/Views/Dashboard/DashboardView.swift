//
//  DashboardView.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    @State private var adService = AdService.shared
    
    init() {
        _viewModel = State(wrappedValue: DashboardViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Protection Status Card
                    ProtectionStatusCard(
                        isEnabled: viewModel.isProtectionEnabled,
                        onToggle: {
                            Task {
                                await viewModel.toggleProtection()
                            }
                        }
                    )
                    
                    // Statistics Cards
                    StatisticsGrid(
                        connectedDevices: viewModel.activeDeviceCount,
                        blockedToday: viewModel.blockedTodayCount,
                        totalBlocked: viewModel.totalBlockedAttempts,
                        totalSites: viewModel.totalBlockedSites
                    )
                    
                    // Connected Devices Section
                    if !viewModel.connectedDevices.isEmpty {
                        ConnectedDevicesSection(devices: viewModel.connectedDevices)
                    }
                    
                    // Recent Blocks Section
                    if !viewModel.recentBlocks.isEmpty {
                        RecentBlocksSection(blocks: viewModel.recentBlocks)
                    }
                    
                    // Ad Banner (if not premium)
                    if adService.canShowAds {
                        AdBannerView()
                            .frame(height: 50)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refreshData()
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

// MARK: - Protection Status Card

struct ProtectionStatusCard: View {
    let isEnabled: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: isEnabled ? "checkmark.shield.fill" : "xmark.shield.fill")
                .font(.system(size: 50))
                .foregroundColor(isEnabled ? .green : .red)
            
            Text(isEnabled ? "Protection Active" : "Protection Disabled")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(isEnabled ? "Your network is protected" : "Enable protection to start blocking")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onToggle) {
                Text(isEnabled ? "Disable Protection" : "Enable Protection")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isEnabled ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// MARK: - Statistics Grid

struct StatisticsGrid: View {
    let connectedDevices: Int
    let blockedToday: Int
    let totalBlocked: Int
    let totalSites: Int
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            StatCard(title: "Connected Devices", value: "\(connectedDevices)", icon: "iphone.and.ipad")
            StatCard(title: "Blocked Today", value: "\(blockedToday)", icon: "hand.raised.fill")
            StatCard(title: "Total Blocked", value: "\(totalBlocked)", icon: "shield.checkmark.fill")
            StatCard(title: "Blocked Sites", value: "\(totalSites)", icon: "globe")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - Connected Devices Section

struct ConnectedDevicesSection: View {
    let devices: [Device]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connected Devices")
                .font(.headline)
            
            ForEach(devices.prefix(3)) { device in
                DeviceRow(device: device)
            }
            
            if devices.count > 3 {
                NavigationLink("View All Devices") {
                    Text("Devices View")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct DeviceRow: View {
    let device: Device
    
    var body: some View {
        HStack {
            Image(systemName: "iphone")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(device.displayName)
                    .font(.subheadline)
                Text(device.ipAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if device.isBlocked {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(.red)
            } else if let remaining = device.remainingTime {
                Text("\(remaining)m")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Recent Blocks Section

struct RecentBlocksSection: View {
    let blocks: [(domain: String, count: Int)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Blocked Today")
                .font(.headline)
            
            ForEach(blocks.indices, id: \.self) { index in
                HStack {
                    Text("\(index + 1).")
                        .foregroundColor(.secondary)
                    
                    Text(blocks[index].domain)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(blocks[index].count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// MARK: - Ad Banner Placeholder

struct AdBannerView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
            Text("Advertisement")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .cornerRadius(8)
    }
}

#Preview {
    DashboardView()
}
