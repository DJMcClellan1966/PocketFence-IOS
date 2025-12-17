//
//  PocketFenceApp.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import SwiftUI

@main
struct PocketFenceApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var settingsRepo = SettingsRepository.shared
    @State private var deviceRepo = DeviceRepository.shared
    @State private var blockedSiteRepo = BlockedSiteRepository.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(colorScheme)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    // MARK: - Computed Properties
    
    private var colorScheme: ColorScheme? {
        switch settingsRepo.settings.theme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
    
    // MARK: - Setup
    
    private func setupApp() {
        // Initialize services
        _ = StatisticsService.shared
        _ = DeviceDetectionService.shared
        _ = BlockingService.shared
        _ = AdService.shared
        
        // Load initial data
        deviceRepo.loadDevices()
        blockedSiteRepo.loadBlockedSites()
        
        // Setup notifications
        setupNotifications()
        
        // Check for daily reset
        checkDailyReset()
    }
    
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private func checkDailyReset() {
        let lastResetKey = "lastDailyReset"
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastReset = UserDefaults.standard.object(forKey: lastResetKey) as? Date {
            let lastResetDay = calendar.startOfDay(for: lastReset)
            
            if today > lastResetDay {
                // New day - reset daily usage
                deviceRepo.resetDailyTimeUsage()
                UserDefaults.standard.set(today, forKey: lastResetKey)
            }
        } else {
            // First launch
            UserDefaults.standard.set(today, forKey: lastResetKey)
        }
    }
}
