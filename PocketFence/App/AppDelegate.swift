//
//  AppDelegate.swift
//  PocketFence
//
//  Created on 2025
//  Copyright © 2025 PocketFence. All rights reserved.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, @unchecked Sendable {
    
    func application(_ application: UIApplication, 
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Initialize AdMob (if using)
        // GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // Setup background tasks
        setupBackgroundTasks()
        
        return true
    }
    
    // MARK: - Background Tasks
    
    private func setupBackgroundTasks() {
        // Register background tasks for periodic updates
        // This would require Background Modes capability
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        
        // Parse notification type and handle accordingly
        if let notificationType = userInfo["type"] as? String {
            // Extract only the needed String value to avoid capturing non-Sendable dictionary
            let typeCopy = notificationType
            Task { @MainActor [weak self] in
                await self?.handleNotification(type: typeCopy)
            }
        }
        
        completionHandler()
    }
    
    @MainActor
    private func handleNotification(type: String) async {
        switch type {
        case Constants.Notifications.deviceBlocked:
            // Navigate to devices tab
            break
        case Constants.Notifications.siteBlocked:
            // Navigate to blocked sites tab
            break
        case Constants.Notifications.timeLimitExceeded:
            // Navigate to time limits tab
            break
        default:
            break
        }
    }
    
    // MARK: - App Lifecycle
    
    func applicationWillResignActive(_ application: UIApplication) {
        // App is about to become inactive
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save any pending changes
        DeviceRepository.shared.saveDevices()
        BlockedSiteRepository.shared.saveBlockedSites()
        TimeLimitRepository.shared.saveTimeLimits()
        SettingsRepository.shared.saveSettings()
        SettingsRepository.shared.saveStatistics()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Refresh data when returning to foreground
        DeviceRepository.shared.loadDevices()
        
        // Check if it's a new day
        checkForDayChange()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Clear badge
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    private func checkForDayChange() {
        let lastResetKey = "lastDailyReset"
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastReset = UserDefaults.standard.object(forKey: lastResetKey) as? Date {
            let lastResetDay = calendar.startOfDay(for: lastReset)
            
            if today > lastResetDay {
                // New day - reset daily usage
                DeviceRepository.shared.resetDailyTimeUsage()
                UserDefaults.standard.set(today, forKey: lastResetKey)
            }
        }
    }
}
