# PocketFence for iOS 🛡️

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-green.svg)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

A comprehensive parental control application for iOS that provides network-level content filtering and device management through Personal Hotspot. PocketFence helps parents protect their children online by blocking harmful websites, setting time limits, and monitoring internet usage.

## 📱 Features

### Core Protection
- **🌐 Network Extension-Based Filtering**: Uses iOS Network Extension framework for system-level traffic filtering
- **📱 Device Management**: Detect and manage all devices connected to your iOS Personal Hotspot
- **🚫 Website Blocking**: Block specific websites or entire categories of harmful content
- **⏰ Time Limits**: Set daily internet usage limits for individual devices
- **🌙 Quiet Hours**: Schedule times when internet access is automatically blocked
- **📊 Real-time Monitoring**: Track connected devices and blocked sites in real-time

### User Interface
PocketFence features a modern SwiftUI interface with five main tabs:
- **Dashboard**: Overview of protection status, connected devices, and statistics
- **Devices**: View and manage all connected devices with individual controls
- **Blocked Sites**: Add/remove websites from blocklist with preset categories
- **Time Limits**: Configure daily limits and quiet hours schedules
- **Settings**: Premium features, app settings, and preferences

### Website Blocking Categories
- 📱 **Social Media**: Facebook, Instagram, Twitter, TikTok, Snapchat, etc.
- 🔞 **Adult Content**: Comprehensive adult content filtering
- 🎰 **Gambling**: Block betting and gambling websites
- 🎮 **Gaming**: Control access to gaming platforms
- ⭐ **Custom**: Add your own websites to block

### Premium Features
- ✨ Ad-free experience
- 📈 Advanced statistics and reports
- 👥 Multiple profiles support (coming soon)
- 💬 Priority support
- 💾 Data export capabilities

## 🏗️ Architecture

PocketFence for iOS follows modern iOS development best practices:

### Design Patterns
- **MVVM Architecture**: SwiftUI views with ObservableObject ViewModels
- **Repository Pattern**: Centralized data management with dedicated repositories
- **Service Layer**: Business logic separated into focused service classes
- **Dependency Injection**: Shared singleton instances for cross-app state management

### Project Structure
```
PocketFence/
├── App/                        # App entry point
│   ├── PocketFenceApp.swift
│   └── AppDelegate.swift
├── Models/                     # Data models
│   ├── Device.swift
│   ├── BlockedWebsite.swift
│   ├── TimeLimit.swift
│   ├── Statistics.swift
│   └── AppSettings.swift
├── ViewModels/                 # View models for MVVM
│   ├── DashboardViewModel.swift
│   ├── DevicesViewModel.swift
│   ├── BlockedSitesViewModel.swift
│   ├── TimeLimitsViewModel.swift
│   └── SettingsViewModel.swift
├── Views/                      # SwiftUI views
│   ├── Dashboard/
│   ├── Devices/
│   ├── BlockedSites/
│   ├── TimeLimits/
│   └── Settings/
├── Services/                   # Business logic services
│   ├── NetworkFilterService.swift
│   ├── DeviceDetectionService.swift
│   ├── BlockingService.swift
│   ├── StatisticsService.swift
│   └── AdService.swift
├── Repository/                 # Data persistence
│   ├── DeviceRepository.swift
│   ├── BlockedSiteRepository.swift
│   ├── TimeLimitRepository.swift
│   └── SettingsRepository.swift
├── NetworkExtension/          # Network Extension target
│   └── PacketTunnelProvider.swift
├── Utilities/                  # Helper utilities
│   ├── Constants.swift
│   ├── NetworkUtils.swift
│   └── Extensions/
└── Resources/                  # App resources
    ├── Info.plist
    └── PocketFence.entitlements
```

## 📋 Requirements

- **iOS 15.0+**
- **Xcode 13.0+**
- **Swift 5.5+**
- **SwiftUI**
- **Combine Framework**

### Required Capabilities
- Network Extension
- App Groups (for extension communication)
- Local Network
- Background Modes

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/DJMcClellan1966/PocketFence-IOS.git
   cd PocketFence-IOS
   ```

2. **Open in Xcode**
   ```bash
   open PocketFence.xcodeproj
   ```

3. **Configure Bundle Identifiers**
   - Main App: `com.pocketfence.ios`
   - Network Extension: `com.pocketfence.ios.NetworkExtension`
   - App Group: `group.com.pocketfence.ios`

4. **Configure Signing & Capabilities**
   - Select your development team
   - Enable Network Extension capability
   - Add App Groups capability with identifier: `group.com.pocketfence.ios`

5. **Build and Run**
   - Select a device (Network Extensions don't work in Simulator)
   - Build and run the project (⌘R)

For detailed setup instructions, see [QUICKSTART.md](QUICKSTART.md)

## 🔒 Security & Privacy

PocketFence prioritizes user privacy and data security:

- ✅ **All data stored locally** on device using UserDefaults and Core Data
- ✅ **No cloud services** or external data sharing
- ✅ **Network traffic stays on device** - filtering happens locally
- ✅ **Encrypted settings storage** using iOS Keychain
- ✅ **No user tracking** - your data is your data
- ✅ **Open source** - transparent and auditable code

For more details, see [SECURITY.md](SECURITY.md)

## 📱 How It Works

1. **Enable Protection**: Tap the protection toggle in the Dashboard
2. **Configure Blocking Rules**: Add websites or enable category presets
3. **Set Time Limits**: Configure daily limits for devices (optional)
4. **Enable Quiet Hours**: Set times when internet is blocked (optional)
5. **Monitor Activity**: View real-time statistics and blocked attempts

The app uses iOS Network Extension to create a local VPN tunnel that inspects DNS requests and blocks matching domains before they're resolved.

## 🎯 Use Cases

- **Parents**: Protect children from inappropriate content
- **Productivity**: Block distracting websites during work hours
- **Self-control**: Limit access to time-wasting sites
- **Education**: Enforce focused study time for students
- **Family Safety**: Comprehensive protection for all family devices

## 💰 Monetization

PocketFence uses a freemium model:

### Free Version
- Full core protection features
- Website blocking and time limits
- Device management
- Ad-supported (banner and interstitial ads)

### Premium ($4.99 one-time)
- Ad-free experience
- Advanced statistics and reports
- Multiple profiles support
- Priority support
- Data export

For integration details, see [MONETIZATION_GUIDE.md](MONETIZATION_GUIDE.md)

## 🔧 Technical Details

### Network Extension Implementation
PocketFence uses `NEPacketTunnelProvider` to create a local VPN connection:
- Intercepts DNS requests at the system level
- Analyzes packet destinations against blocklist
- Blocks packets to blacklisted domains
- Forwards allowed packets normally
- Updates statistics in real-time

### Device Detection
Device discovery uses multiple iOS frameworks:
- Network.framework for local network discovery
- Bonjour service discovery for device identification
- Personal Hotspot APIs (where available)
- MAC/IP address tracking

### Data Persistence
- **UserDefaults**: Lightweight settings and preferences
- **App Groups**: Shared data between app and extension
- **Keychain**: Secure storage for sensitive settings

## 📊 Statistics & Analytics

Track important metrics:
- Total sites blocked
- Connected devices count
- Time remaining for devices with limits
- Blocked attempts over time
- Protection uptime
- Most blocked websites

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

## 📄 Documentation

- [QUICKSTART.md](QUICKSTART.md) - Getting started guide
- [FEATURES.md](FEATURES.md) - Detailed feature documentation
- [ARCHITECTURE_FLOW.md](ARCHITECTURE_FLOW.md) - Architecture overview
- [MONETIZATION_GUIDE.md](MONETIZATION_GUIDE.md) - In-app purchase setup
- [SECURITY.md](SECURITY.md) - Security and privacy details
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines

## 🆚 Comparison with Android Version

PocketFence for iOS provides feature parity with the [Android version](https://github.com/DJMcClellan1966/PocketFence-Android):

| Feature | Android | iOS |
|---------|---------|-----|
| Network Filtering | VPN Service | Network Extension |
| Device Detection | VPN Client Info | Local Network + Bonjour |
| Website Blocking | ✅ | ✅ |
| Time Limits | ✅ | ✅ |
| Quiet Hours | ✅ | ✅ |
| Statistics | ✅ | ✅ |
| Premium Version | ✅ | ✅ |
| Ad Support | AdMob | AdMob |

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **PocketFence Team** - [DJMcClellan1966](https://github.com/DJMcClellan1966)

## 🙏 Acknowledgments

- Based on the Android version: [PocketFence-Android](https://github.com/DJMcClellan1966/PocketFence-Android)
- iOS frameworks: NetworkExtension, Network, Combine, SwiftUI
- Community feedback and contributions

## 📞 Support

- **Email**: support@pocketfence.app
- **Issues**: [GitHub Issues](https://github.com/DJMcClellan1966/PocketFence-IOS/issues)
- **Discussions**: [GitHub Discussions](https://github.com/DJMcClellan1966/PocketFence-IOS/discussions)

## 🗺️ Roadmap

- [ ] Screen Time API integration
- [ ] Advanced scheduling options
- [ ] User profiles
- [ ] Web dashboard
- [ ] Family sharing
- [ ] Custom blocking rules with regex
- [ ] Browser extension blocking
- [ ] Activity reports via email
- [ ] Geofencing features

---

**Note**: Network Extension features require testing on a physical iOS device. They do not work in the iOS Simulator.

Made with ❤️ for safer internet browsing
