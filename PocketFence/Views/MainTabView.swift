//
//  MainTabView.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import SwiftUI

/// Main tab-based navigation view
struct MainTabView: View {
    @StateObject private var settingsRepo = SettingsRepository.shared
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "shield.fill")
                }
            
            DevicesView()
                .tabItem {
                    Label("Devices", systemImage: "iphone.and.ipad")
                }
            
            BlockedSitesView()
                .tabItem {
                    Label("Blocked Sites", systemImage: "hand.raised.fill")
                }
            
            TimeLimitsView()
                .tabItem {
                    Label("Time Limits", systemImage: "clock.fill")
                }
            
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
