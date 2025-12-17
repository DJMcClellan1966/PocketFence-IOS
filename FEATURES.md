# PocketFence iOS - Features Documentation

Comprehensive guide to all features available in PocketFence for iOS.

## 🛡️ Core Protection Features

### Network Extension-Based Filtering

PocketFence uses iOS Network Extension framework to provide system-level content filtering.

**How it works:**
- Creates a local VPN tunnel using `NEPacketTunnelProvider`
- Intercepts DNS requests before they're resolved
- Blocks requests to domains in your blocklist
- Forwards allowed requests to upstream DNS servers

**Benefits:**
- Works system-wide across all apps
- No per-app configuration needed
- Blocks content before it loads
- Minimal battery impact

**Limitations:**
- Requires VPN permission from user
- Only one VPN can be active at a time
- HTTPS sites can't inspect encrypted traffic (by design for privacy)

### Personal Hotspot Device Management

Monitor and control devices connected to your iOS Personal Hotspot.

**Features:**
- Automatic device detection
- Device name customization
- Individual device blocking
- Per-device time limits
- Connection history tracking
- Block attempt counting

**Device Information Tracked:**
- Device name
- IP address
- MAC address
- First connection time
- Last seen time
- Total blocked attempts
- Daily time usage

**iOS Limitations:**
- Limited API access to hotspot client information
- Manual device addition supported for testing
- Best effort detection using network frameworks

## 📱 User Interface

### Dashboard Tab

Central hub for monitoring protection status and statistics.

**Components:**
1. **Protection Status Card**
   - Visual indicator (green shield = active, red = inactive)
   - Toggle button to enable/disable protection
   - Status description

2. **Statistics Grid**
   - Connected Devices count
   - Sites Blocked Today
   - Total Blocked count
   - Total Blocked Sites count

3. **Connected Devices Section**
   - List of active devices (up to 3 shown)
   - Device names and IPs
   - Block/limit indicators
   - "View All" link to Devices tab

4. **Recent Blocks Section**
   - Top 5 most blocked domains today
   - Block counts for each domain
   - Ranked list display

5. **Ad Banner** (Free version only)
   - Non-intrusive banner advertisement
   - Hidden for premium users

### Devices Tab

Comprehensive device management interface.

**Features:**
- **Device List**: All discovered devices with status indicators
- **Active Devices Section**: Currently connected devices
- **Device Details**: Tap any device for detailed view
- **Quick Actions**: Swipe gestures for block/delete
- **Scanning**: Manual device discovery
- **Manual Addition**: Add devices manually

**Device Detail View:**
- Edit device name
- View connection information
- Toggle device blocking
- Set time limits with slider
- View usage statistics
- Reset daily usage
- Delete device

**Device Indicators:**
- 🔵 Blue icon = Active device
- ⚫ Gray icon = Inactive device
- 🛑 Red icon = Blocked device
- ⏰ Orange = Time limit exceeded

### Blocked Sites Tab

Manage website blocklists with ease.

**Category Presets:**
1. **Social Media** (12 sites)
   - Facebook, Instagram, Twitter/X
   - TikTok, Snapchat, Reddit
   - LinkedIn, Pinterest, Tumblr
   - YouTube, Twitch

2. **Gaming** (10 sites)
   - Roblox, Minecraft, Fortnite
   - Epic Games, Steam
   - PlayStation, Xbox, EA, Origin

3. **Gambling** (7 sites)
   - Major betting platforms
   - Casino sites
   - Poker sites

4. **Custom**
   - User-added domains

**Features:**
- One-tap category blocking
- Individual site management
- Search functionality
- Enable/disable individual sites
- Block count tracking
- Last blocked timestamp
- Swipe to delete

**Adding Custom Sites:**
1. Tap menu (⋯) > Add Site
2. Enter domain (e.g., example.com)
3. Select category
4. Site is immediately active

**Domain Matching:**
- Exact domain matches
- Subdomain blocking (*.example.com)
- Case-insensitive
- www. prefix handled automatically

### Time Limits Tab

Configure daily usage limits and quiet hours.

**Global Time Limit:**
- Applies to all devices by default
- Set anywhere from 30 minutes to 8 hours
- Easy slider interface
- Can be overridden per device

**Per-Device Time Limits:**
- Override global limit for specific devices
- Individual usage tracking
- Remaining time display
- Daily reset at midnight

**Quiet Hours:**
- Set start and end times
- Select active days of week
- Blocks all internet during quiet hours
- Quick presets (weekdays, weekends, every day)
- Enable/disable toggle
- Handles overnight periods (e.g., 10 PM - 7 AM)

**Time Limit Features:**
- Progress bars showing usage
- Automatic blocking when limit reached
- Reset all usage option
- Usage statistics per device
- Visual time remaining indicators

### Settings Tab

App configuration and premium features.

**General Settings:**
- Protection Enabled toggle
- Notifications toggle
- Sound Effects toggle

**Blocking Mode:**
- **Strict**: Block all configured sites
- **Moderate**: Block explicit content, allow educational
- **Permissive**: Only block explicit adult content

**Appearance:**
- System theme (follows iOS)
- Light mode
- Dark mode

**Statistics:**
- View detailed statistics
- Export to CSV
- Total blocks count
- Connected devices
- Days active

**Data Management:**
- Reset Statistics
- Clear All Data
- Export functionality

**Premium:**
- Upgrade to Premium card (free version)
- Purchase interface
- Restore purchases
- Premium status indicator

**Support:**
- Privacy Policy link
- Terms of Service link
- Help & Support
- Contact Us email link

**About:**
- App version
- Build number
- Premium status

## 💰 Premium Features

### What's Included

**Free Version:**
- ✅ Full protection features
- ✅ Unlimited devices
- ✅ Unlimited blocked sites
- ✅ Time limits and quiet hours
- ✅ Real-time statistics
- ⚠️ Ad-supported

**Premium Version ($4.99 one-time):**
- ✨ **Ad-Free**: No advertisements
- 📊 **Advanced Statistics**: Detailed reports and charts
- 📈 **Export Data**: CSV export of all statistics
- 👥 **Multiple Profiles**: Coming soon
- 💬 **Priority Support**: Faster response times
- 🔄 **Restore Purchases**: Works across devices with same Apple ID

### Purchasing Premium

1. Go to Settings tab
2. Tap "Upgrade to Premium" card
3. Review features
4. Tap "Purchase Premium"
5. Authenticate with Apple ID
6. Ads removed immediately
7. Premium features unlocked

### Restoring Purchases

If you've purchased on another device:
1. Settings > Restore Purchase
2. Authenticate with Apple ID
3. Premium status restored if found

## 📊 Statistics & Monitoring

### Real-Time Stats

**Tracked Metrics:**
- Total blocked attempts (all-time)
- Total blocked attempts today
- Connected devices count
- Active devices count
- Total blocked sites count
- Days since protection started
- Average blocks per day
- Weekly block count

**Daily Statistics:**
- Blocks per day (last 30 days)
- Active devices per day
- Top blocked domains per day
- Hour-by-hour breakdown (premium)

**Top Blocked Sites:**
- Ranked by block count
- Domain names
- Block counts
- Last blocked timestamp
- Category identification

### Statistics View

Accessible from Settings > Statistics:

**Overall Section:**
- Total Blocks
- Total Devices
- Blocked Sites
- Days Active
- Average Blocks/Day

**This Week Section:**
- Weekly block count
- Trend indication

**Today Section:**
- Today's blocks
- Active devices today
- Top 5 blocked domains with counts

### Data Export

Premium feature to export statistics:
- CSV format
- Includes all daily statistics
- Importable to spreadsheets
- Email or save to Files app

## 🔒 Security & Privacy Features

### Data Storage

**Local Only:**
- All data stored on device
- No cloud synchronization
- No external servers contacted
- No analytics tracking

**Storage Methods:**
- UserDefaults: App settings and preferences
- App Groups: Shared data with Network Extension
- Keychain: Sensitive settings (if needed)

### Privacy Protection

**What PocketFence Does:**
- ✅ Blocks harmful websites
- ✅ Tracks blocking statistics
- ✅ Monitors device connections

**What PocketFence Doesn't Do:**
- ❌ Log browsing history
- ❌ Store accessed URLs
- ❌ Share data with third parties
- ❌ Track user behavior
- ❌ Sell user data

### VPN Configuration

**Transparency:**
- Local VPN only (no remote server)
- DNS filtering only
- No packet inspection beyond DNS
- No traffic logging
- All traffic stays on device

## 🎯 Use Case Examples

### Parental Control

**Scenario**: Parent with young children
1. Block Social Media category
2. Block Adult Content
3. Set 2-hour daily limit
4. Enable quiet hours 9 PM - 7 AM
5. Monitor from Dashboard

### Study Focus

**Scenario**: Student needing focus
1. Block Social Media and Gaming
2. Set 1-hour limit during weekdays
3. Allow unlimited on weekends
4. Quiet hours during study time

### Self-Control

**Scenario**: Professional wanting productivity
1. Block specific distracting sites
2. Strict mode during work hours
3. Use quiet hours as work hours
4. Review statistics weekly

### Family Safety

**Scenario**: Protecting multiple devices
1. Enable protection on parent's device
2. Share hotspot with family
3. Different limits per device
4. Comprehensive category blocking

## ⚙️ Advanced Configuration

### Custom Blocking Rules

While the UI provides category-based blocking, advanced users can:
- Add any domain to blocklist
- Use wildcard matching (automatic subdomain blocking)
- Combine categories with custom sites
- Enable/disable sites individually

### Blocking Modes

**Strict Mode:**
- Blocks all sites in blocklist
- Most restrictive
- Recommended for young children

**Moderate Mode:**
- Blocks explicit content
- Allows educational sites
- Balanced approach

**Permissive Mode:**
- Only blocks explicit adult content
- Maximum freedom
- Recommended for older teens

### Network Extension Configuration

For developers wanting to customize:
- Modify `PacketTunnelProvider.swift`
- Adjust DNS servers
- Change filtering logic
- Add custom logging

### App Group Communication

The app and extension communicate via App Groups:
- Blocked domains list
- Blocked IPs list
- Statistics updates
- Configuration changes

## 🐛 Known Limitations

### iOS Restrictions

1. **VPN Conflicts**: Only one VPN can be active
2. **Simulator**: Network Extension doesn't work in simulator
3. **Personal Hotspot**: Limited API access
4. **HTTPS Inspection**: Not possible (by design)
5. **Background Refresh**: Limited background execution time

### Feature Limitations

1. **Device Detection**: Best-effort on iOS
2. **Real-time Blocking**: DNS-level only
3. **Browser-level**: Can't block HTTPS content inspection
4. **App-specific**: Can't set limits per app

## 🔄 Future Features

Planned enhancements:
- [ ] Screen Time API integration
- [ ] iCloud sync (optional)
- [ ] User profiles
- [ ] Schedule templates
- [ ] Geofencing
- [ ] Enhanced statistics
- [ ] Browser extension detection
- [ ] Custom DNS servers
- [ ] Whitelist mode

---

For technical details, see [ARCHITECTURE_FLOW.md](ARCHITECTURE_FLOW.md)
