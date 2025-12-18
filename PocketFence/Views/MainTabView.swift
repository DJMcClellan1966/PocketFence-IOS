//
//  MainTabView.swift
//  ScreenBalance
//
//  Created on 2025
//  Copyright © 2025 ScreenBalance. All rights reserved.
//

import SwiftUI

/// Main tab-based navigation view for ScreenBalance
struct MainTabView: View {
    @State private var settingsRepo = SettingsRepository.shared
    
    var body: some View {
        TabView {
            // Dashboard
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            // Focus & Productivity
            TimeLimitsView()
                .tabItem {
                    Label("Focus", systemImage: "target")
                }
            
            // Devices (keep for monitoring)
            DevicesView()
                .tabItem {
                    Label("Devices", systemImage: "iphone.and.ipad")
                }
            
            // Smart blocking (reframed as "Balance")
            BlockedSitesView()
                .tabItem {
                    Label("Balance", systemImage: "scale.3d")
                }
            
            // Settings
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
