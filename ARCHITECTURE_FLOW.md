# PocketFence iOS - Architecture & Flow

This document provides a comprehensive overview of PocketFence's architecture, design patterns, and data flow.

## 📐 Architecture Overview

PocketFence follows modern iOS development best practices with a clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    SwiftUI Views (iOS 17+)                  │
│  (Dashboard, Devices, Blocked Sites, Time Limits, Settings) │
│              Using NavigationStack & @State                 │
└───────────────────┬─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────────┐
│                        ViewModels                           │
│             (MVVM Pattern - @Observable Macro)              │
└───────────────────┬─────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
┌──────────┐  ┌──────────┐  ┌──────────────┐
│Services  │  │Repository│  │    Models    │
│  Layer   │  │  Layer   │  │  (Data)      │
│@Observable│ │@Observable│  │              │
└─────┬────┘  └────┬─────┘  └──────────────┘
      │            │
      ▼            ▼
┌──────────────────────────┐
│   Network Extension      │
│  (Complete DNS Filter)   │
└──────────────────────────┘
```

## 🏗️ Design Patterns

### 1. MVVM (Model-View-ViewModel) - iOS 17+ @Observable Pattern

**Why MVVM?**
- Native to SwiftUI's declarative approach
- Clear separation between UI and business logic
- Testable business logic
- Automatic observation with @Observable macro (iOS 17+)

**Implementation:**
- **Views**: SwiftUI views with NavigationStack (purely declarative)
- **ViewModels**: @Observable classes with automatic property tracking
- **Models**: Plain Swift structs (Codable, Identifiable)

**Modern iOS 17+ Flow:**
```swift
View (@State) → ViewModel (@Observable) → Repository (@Observable) → Service
     ↑                                                                    │
     └───────────────── Automatic Updates ────────────────────────────────┘
```

**Key Changes from ObservableObject:**
- No more `@Published` property wrappers
- Use `@State` instead of `@StateObject` in views
- Automatic change tracking without Combine
- Better performance with fine-grained observation

### 2. Repository Pattern - @Observable

**Purpose**: Centralize data access and management

**Benefits:**
- Single source of truth for each data type
- Abstracts storage implementation
- Easy to test and mock
- Consistent data access patterns

**Repositories:**
- `DeviceRepository`: Device data management
- `BlockedSiteRepository`: Blocked websites
- `TimeLimitRepository`: Time limits and quiet hours
- `SettingsRepository`: App settings and statistics

**Modern iOS 17+ Pattern:**
```swift
@Observable
class DeviceRepository {
    private(set) var devices: [Device] = []
    
    func loadDevices() { /* UserDefaults */ }
    func saveDevices() { /* UserDefaults */ }
    func addDevice(_ device: Device) { /* Update & Save */ }
}
```

### 3. Service Layer

**Purpose**: Encapsulate business logic and complex operations

**Services:**
- `NetworkFilterService`: VPN/Network Extension management
- `DeviceDetectionService`: Device discovery
- `BlockingService`: Blocking logic coordination
- `StatisticsService`: Statistics collection
- `AdService`: Advertisement management

**Responsibilities:**
- Complex business logic
- Cross-cutting concerns
- External API integration
- Background operations

### 4. Dependency Injection

**Approach**: Shared singletons for app-wide state

**Benefits:**
- Single instance across app
- Shared state management
- Easy access from any component
- Memory efficient

**Implementation:**
```swift
class DeviceRepository {
    static let shared = DeviceRepository()
    private init() {}
}

// Usage
@StateObject private var deviceRepo = DeviceRepository.shared
```

## 📊 Data Flow

### Blocking Flow

```
1. User enables protection in Dashboard
   ↓
2. NetworkFilterService.startFiltering()
   ↓
3. NEPacketTunnelProvider configured
   ↓
4. VPN tunnel established
   ↓
5. DNS requests intercepted
   ↓
6. Domain checked against blocklist
   ↓
7. If blocked: NXDOMAIN returned
   ↓
8. Statistics updated
   ↓
9. UI refreshed automatically
```

### Device Detection Flow

```
1. DeviceDetectionService starts periodic scanning
   ↓
2. Network.framework monitors connections
   ↓
3. Bonjour discovers local devices
   ↓
4. Device info extracted (IP, MAC, name)
   ↓
5. DeviceRepository updated
   ↓
6. ViewModels observe changes
   ↓
7. UI automatically updates
```

### Time Limit Enforcement Flow

```
1. Device usage tracked in real-time
   ↓
2. TimeLimitRepository checks limits
   ↓
3. If exceeded: Device marked as blocked
   ↓
4. IP added to blocked list
   ↓
5. Network Extension blocks traffic
   ↓
6. Statistics updated
   ↓
7. Notification sent (if enabled)
```

## 🔄 State Management

### Observable Pattern

PocketFence uses Combine and SwiftUI's native observation:

```swift
// Repository (Publisher)
class DeviceRepository: ObservableObject {
    @Published private(set) var devices: [Device] = []
}

// ViewModel (Subscriber)
class DevicesViewModel: ObservableObject {
    private let deviceRepo = DeviceRepository.shared
    
    init() {
        deviceRepo.$devices
            .assign(to: &$devices)
    }
}

// View (Observer)
struct DevicesView: View {
    @StateObject private var viewModel = DevicesViewModel()
    
    var body: some View {
        List(viewModel.devices) { device in
            // UI updates automatically when devices change
        }
    }
}
```

### Data Persistence

**Storage Strategy:**

1. **UserDefaults** (Lightweight data)
   - App settings
   - Simple preferences
   - Small data sets

2. **App Groups** (Shared data)
   - Extension communication
   - Blocked domains list
   - Real-time statistics

3. **Keychain** (Sensitive data)
   - Premium status
   - Encrypted settings

**Persistence Flow:**
```
Model Change → Repository.save() → UserDefaults/App Group → Disk
                                                              ↓
Model Needed ← Repository.load() ← UserDefaults/App Group ← Disk
```

## 🔌 Network Extension Architecture

### Extension Communication

**App ↔️ Extension Communication:**

```
┌──────────────┐                    ┌─────────────────────┐
│  Main App    │                    │ Network Extension   │
│              │                    │                     │
│  Updates     │──── App Group ───→│  Reads              │
│  Blocklist   │     UserDefaults   │  Blocklist          │
│              │                    │                     │
│  Reads       │←─── App Group ────│  Updates            │
│  Statistics  │     UserDefaults   │  Statistics         │
└──────────────┘                    └─────────────────────┘
```

**Shared Data:**
- `blockedDomains`: Array of domains to block
- `blockedIPs`: Array of IPs to block
- `totalBlockedAttempts`: Counter
- `isProtectionEnabled`: Boolean flag

### Packet Tunnel Provider

**DNS Filtering Implementation:**

```swift
class PacketTunnelProvider: NEPacketTunnelProvider {
    
    // 1. Start tunnel
    override func startTunnel(...) {
        loadBlockingRules()
        configureTunnelSettings()
        setTunnelNetworkSettings(settings) { ... }
    }
    
    // 2. Configure DNS routing
    private func createTunnelSettings() {
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])
        dnsSettings.matchDomains = [""] // All domains
        // ... route DNS through tunnel
    }
    
    // 3. Process DNS requests
    private func shouldBlockDomain(_ domain: String) -> Bool {
        return blockedDomains.contains { 
            domain.hasSuffix($0)
        }
    }
    
    // 4. Update statistics
    private func recordBlockedAttempt() {
        // Update shared UserDefaults
    }
}
```

## 📱 App Lifecycle

### App Startup

```
1. PocketFenceApp.swift initializes
   ↓
2. AppDelegate.swift configured
   ↓
3. Repositories instantiated (singletons)
   ↓
4. Services initialized
   ↓
5. Data loaded from storage
   ↓
6. ViewModels setup observers
   ↓
7. MainTabView displayed
   ↓
8. Protection status checked
```

### Background to Foreground

```
1. applicationWillEnterForeground()
   ↓
2. Reload data from repositories
   ↓
3. Check for day change (reset daily usage)
   ↓
4. Refresh device detection
   ↓
5. Update statistics
   ↓
6. UI refreshes automatically
```

### Background Operations

```
1. Periodic device scanning (30s intervals)
2. Statistics updates (60s intervals)
3. Network Extension runs continuously
4. VPN tunnel maintained
5. DNS filtering active
```

## 🔐 Security Architecture

### Data Protection

**Layers:**
1. **App Sandbox**: iOS enforces app isolation
2. **Local Storage**: All data stored locally
3. **App Groups**: Controlled sharing with extension
4. **Keychain**: Secure storage for sensitive data
5. **No Network**: No external communication

### Privacy by Design

**Principles:**
- Minimal data collection
- No user tracking
- No browsing history logging
- Local processing only
- Transparent operation

**What's Stored:**
- Device names, IPs, MACs (local only)
- Blocked domain list (user-defined)
- Block counts (anonymous)
- Time usage (per-device)
- App settings

**What's NOT Stored:**
- Browsing history
- Accessed URLs
- User credentials
- Personal information

## 🎭 View Architecture

### Tab-Based Navigation

```
MainTabView
├── DashboardView
│   ├── ProtectionStatusCard
│   ├── StatisticsGrid
│   ├── ConnectedDevicesSection
│   └── RecentBlocksSection
│
├── DevicesView
│   ├── DeviceListRow (for each device)
│   ├── DeviceDetailView (sheet)
│   └── AddDeviceView (sheet)
│
├── BlockedSitesView
│   ├── CategoryRow (for each category)
│   ├── BlockedSiteRow (for each site)
│   └── AddBlockedSiteView (sheet)
│
├── TimeLimitsView
│   ├── QuietHoursRow
│   ├── TimeLimitRow (for each limit)
│   ├── EditTimeLimitView (navigation)
│   └── QuietHoursEditorView (sheet)
│
└── SettingsView
    ├── PremiumCard (if not premium)
    ├── Settings sections
    ├── StatisticsView (navigation)
    └── PremiumPurchaseView (sheet)
```

### View Communication

**Parent → Child:**
```swift
struct ParentView: View {
    @State var device: Device
    
    var body: some View {
        ChildView(device: device)  // Pass down
    }
}
```

**Child → Parent:**
```swift
struct ChildView: View {
    @Binding var device: Device  // Two-way binding
    // OR
    var onSave: (Device) -> Void  // Callback
}
```

**ViewModel → View:**
```swift
class MyViewModel: ObservableObject {
    @Published var items: [Item]  // Auto-updates view
}

struct MyView: View {
    @StateObject var viewModel = MyViewModel()
    // View updates when viewModel.items changes
}
```

## 🧪 Testing Architecture

### Testable Components

**ViewModels:**
```swift
class DashboardViewModelTests: XCTestCase {
    var viewModel: DashboardViewModel!
    
    override func setUp() {
        viewModel = DashboardViewModel()
    }
    
    func testProtectionToggle() {
        // Test business logic without UI
    }
}
```

**Repositories:**
```swift
class DeviceRepositoryTests: XCTestCase {
    func testDeviceStorage() {
        let repo = DeviceRepository()
        // Test CRUD operations
    }
}
```

**Services:**
```swift
class BlockingServiceTests: XCTestCase {
    func testBlockingLogic() {
        // Test blocking decisions
    }
}
```

## 🔄 Update Flow Examples

### Add Blocked Site

```
User taps "Add Site"
   ↓
AddBlockedSiteView presented
   ↓
User enters domain
   ↓
viewModel.addBlockedSite(domain, category)
   ↓
BlockedSiteRepository.addBlockedSite()
   ↓
Save to UserDefaults
   ↓
@Published blockedSites updates
   ↓
BlockingService observes change
   ↓
NetworkFilterService.updateBlockedDomains()
   ↓
Write to App Group UserDefaults
   ↓
Network Extension reads new list
   ↓
DNS filtering updated
   ↓
View automatically refreshes
```

### Block Device

```
User swipes device
   ↓
Taps "Block"
   ↓
viewModel.toggleDeviceBlock(device)
   ↓
DeviceRepository.updateDevice()
   ↓
device.isBlocked = true
   ↓
Save to UserDefaults
   ↓
@Published devices updates
   ↓
BlockingService observes change
   ↓
NetworkFilterService.updateDeviceRules()
   ↓
Add IP to blockedIPs in App Group
   ↓
Network Extension blocks IP
   ↓
View shows red icon
```

## 📊 Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Load data only when needed
2. **Pagination**: Limit items displayed at once
3. **Debouncing**: Delay rapid updates
4. **Background Queues**: Heavy operations off main thread
5. **Caching**: Reuse computed values

### Memory Management

- **Weak References**: Avoid retain cycles
- **@StateObject vs @ObservedObject**: Proper ownership
- **Combine Cancellables**: Cleanup subscriptions
- **Singleton Pattern**: Single instance efficiency

### Network Extension Performance

- **Efficient Lookups**: Hash sets for O(1) domain checks
- **Minimal Logging**: Reduce I/O operations
- **Batch Updates**: Group changes together
- **Memory Limits**: Extension has lower memory cap

## 🚀 Scalability

### Current Limits

- Devices: Unlimited (practical limit ~50)
- Blocked Sites: Unlimited (practical limit ~10,000)
- Time Limits: One per device + global
- Quiet Hours: One global schedule
- Statistics: Last 30 days retained

### Future Enhancements

- Core Data for large datasets
- CloudKit for sync (optional)
- Background fetch for updates
- Widget support
- Shortcuts integration

---

For implementation details, see the source code documentation in each file.
For security details, see [SECURITY.md](SECURITY.md).
