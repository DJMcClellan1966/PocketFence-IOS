# PocketFence iOS - Security & Privacy

This document details PocketFence's security architecture, privacy practices, and data handling policies.

## 🔒 Security Principles

PocketFence is built on these core security principles:

1. **Privacy by Design**: Privacy is fundamental, not an afterthought
2. **Local First**: All data stored and processed locally
3. **Minimal Collection**: Collect only what's necessary
4. **Transparency**: Open source and auditable
5. **User Control**: Users own their data

## 🛡️ Data Privacy

### What Data is Collected

PocketFence collects **minimal data** necessary for its operation:

#### Device Information
- **Device Name**: User-provided name for identification
- **IP Address**: For network filtering (temporary)
- **MAC Address**: For device identification (local only)
- **Connection Times**: First seen and last seen timestamps

**Purpose**: Device management and time limit enforcement
**Storage**: Local device only (UserDefaults)
**Sharing**: Never shared externally

#### Blocked Websites
- **Domain Names**: Websites to block (user-configured)
- **Categories**: User-selected categories
- **Block Counts**: Number of times blocked

**Purpose**: Website filtering functionality
**Storage**: Local device only (UserDefaults)
**Sharing**: Never shared externally

#### Usage Statistics
- **Total Blocks**: Aggregate count of blocked attempts
- **Daily Stats**: Per-day blocking statistics
- **Top Domains**: Most frequently blocked sites

**Purpose**: User insights and app functionality
**Storage**: Local device only (UserDefaults)
**Sharing**: Never shared externally
**Retention**: Last 30 days only

#### App Settings
- **Premium Status**: Purchase state
- **User Preferences**: App configuration
- **Protection Status**: On/off state

**Purpose**: App functionality
**Storage**: Local device (UserDefaults) and Keychain
**Sharing**: Never shared externally

### What Data is NOT Collected

PocketFence explicitly does **NOT** collect:

- ❌ Browsing history
- ❌ Visited URLs (beyond blocked attempts)
- ❌ Personal information
- ❌ Location data
- ❌ Contact information
- ❌ Photos or media
- ❌ Email or messages
- ❌ App usage patterns
- ❌ Device identifiers for tracking
- ❌ Analytics data (beyond basic App Store metrics)

## 🔐 Data Storage

### Storage Methods

#### UserDefaults (Unencrypted)
**Used for**: Non-sensitive data
- Device list
- Blocked websites
- Statistics
- App preferences

**Security**: 
- App Sandbox protected
- OS-level encryption (when device locked)
- Not accessible by other apps

#### App Groups (Shared)
**Used for**: Extension communication
- Blocked domains list
- Blocked IPs
- Real-time statistics

**Security**:
- Shared only between main app and Network Extension
- Protected by App Group entitlement
- Not accessible by other apps

#### Keychain (Encrypted)
**Used for**: Sensitive data
- Premium purchase status (optional)
- Secure settings (if needed)

**Security**:
- Hardware-encrypted
- Biometric protection available
- Survives app deletion

### Data Flow

```
User Action
    ↓
App Process (Main App)
    ↓
Repository Layer (In-Memory)
    ↓
Storage Layer (UserDefaults/Keychain)
    ↓
Device Storage (iOS Sandbox)
```

**No external servers involved at any step.**

## 🌐 Network Extension Security

### VPN Implementation

PocketFence uses Network Extension to create a **local VPN**:

**What it does:**
- Routes DNS requests through local filtering
- Blocks matching domains
- Returns NXDOMAIN for blocked sites
- Forwards allowed requests to real DNS

**What it doesn't do:**
- ❌ Route traffic through remote servers
- ❌ Log browsing activity
- ❌ Inspect HTTPS traffic content
- ❌ Decrypt encrypted connections
- ❌ Store accessed URLs

### DNS Filtering

**Process:**
1. Device makes DNS request
2. Request intercepted by Network Extension
3. Domain checked against local blocklist
4. If blocked: Return NXDOMAIN (site unreachable)
5. If allowed: Forward to real DNS server
6. No logging of allowed requests

**Privacy:**
- Only blocked domains are recorded
- Allowed domains are never logged
- No browsing history created
- HTTPS content remains encrypted

### Local Processing

All filtering happens **on-device**:
- Blocklist stored locally
- Matching performed locally
- No queries sent to external services
- No cloud processing

## 🔒 Security Features

### App Sandbox

iOS App Sandbox provides:
- Process isolation
- File system isolation
- Network access control
- IPC restrictions
- Cryptographic key protection

### Entitlements

PocketFence requests minimal entitlements:

```xml
<!-- Required for Network Extension -->
<key>com.apple.developer.networking.networkextension</key>
<array>
    <string>packet-tunnel-provider</string>
</array>

<!-- Required for extension communication -->
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.pocketfence.ios</string>
</array>

<!-- Required for WiFi information -->
<key>com.apple.developer.networking.wifi-info</key>
<true/>
```

Each entitlement serves a specific, necessary purpose.

### Code Signing

- All code is signed with Apple Developer Certificate
- Extensions verified by iOS
- Prevents code injection
- Ensures app integrity

### Permissions

PocketFence requests these permissions:

**VPN Configuration** (Required)
- Purpose: Network traffic filtering
- When: First protection enable
- Can Deny: App won't filter traffic

**Local Network** (Required)
- Purpose: Device detection on Personal Hotspot
- When: App launch
- Can Deny: Device detection limited

**Notifications** (Optional)
- Purpose: Alert about blocks and limits
- When: First app launch
- Can Deny: No notifications sent

**No other permissions requested.**

## 🚫 What PocketFence Cannot Do

Due to iOS security restrictions and by design:

### Cannot See

- ❌ Passwords or credentials
- ❌ Banking information
- ❌ Credit card numbers
- ❌ Messages or emails
- ❌ Photos or files
- ❌ Other app data
- ❌ Decrypted HTTPS content

### Cannot Track

- ❌ Physical location
- ❌ User behavior across apps
- ❌ Advertising ID usage
- ❌ Cross-site tracking
- ❌ Analytics beyond basic App Store metrics

### Cannot Share

- ❌ Data with third parties
- ❌ Data with advertisers (beyond generic ads)
- ❌ Data with analytics services
- ❌ Data across user devices (no cloud sync)

## 🔍 Transparency

### Open Source

PocketFence is open source:
- Full source code available
- Independently auditable
- Community reviewed
- No hidden functionality

### No Analytics

PocketFence includes:
- ✅ Apple's basic App Store metrics (anonymous)
- ❌ No third-party analytics
- ❌ No crash reporting services
- ❌ No behavior tracking
- ❌ No usage metrics collection

### Ad Privacy

Free version includes ads via AdMob:
- Generic ads only
- No personalized tracking
- ATT framework respected
- User can limit ad tracking in iOS Settings
- Ads removed with Premium purchase

## 🛡️ Threat Model

### What PocketFence Protects Against

✅ **Access to Harmful Content**
- Blocks configured websites
- Prevents access to categories
- Enforces time limits

✅ **Unauthorized Device Usage**
- Time limit enforcement
- Quiet hours blocking
- Device-specific controls

### What PocketFence Doesn't Protect Against

❌ **Advanced Evasion**
- VPN services can bypass filtering
- Tor and proxies not blocked
- Technical users can disable

❌ **Malware/Viruses**
- Not an antivirus
- Doesn't scan files
- Website blocking only

❌ **Phishing**
- Doesn't verify site authenticity
- Doesn't check certificates
- Blocks known bad domains only

### Known Limitations

**iOS Restrictions:**
- Only one VPN can be active
- Limited hotspot client APIs
- Cannot inspect HTTPS content
- Cannot block at app level

**User Control:**
- Users can disable protection
- Users can delete app
- Device owner has full control

## 🔐 Security Best Practices

### For Users

1. **Passcode Protection**: Set a device passcode
2. **Restrict Settings**: Use Screen Time to limit Settings access
3. **Premium**: Consider premium for additional features
4. **Updates**: Keep app and iOS updated
5. **Review**: Periodically review blocked sites list

### For Developers

1. **Code Review**: Review all changes carefully
2. **Dependency Scanning**: Check third-party libraries
3. **Least Privilege**: Request minimal permissions
4. **Data Minimization**: Collect only necessary data
5. **Regular Updates**: Keep dependencies updated
6. **Security Testing**: Regular security audits

## 📜 Compliance

### Apple App Store Guidelines

PocketFence complies with:
- ✅ 2.5.15: VPN apps guidelines
- ✅ 5.1.2: Data Use and Sharing
- ✅ 2.3.8: Parental controls apps
- ✅ 4.0: Design guidelines

### Privacy Regulations

**GDPR (EU):**
- ✅ No personal data collection
- ✅ Local storage only
- ✅ User data control
- ✅ No cross-border transfers
- ✅ Transparent practices

**CCPA (California):**
- ✅ No data selling
- ✅ No tracking
- ✅ Clear privacy policy
- ✅ User rights respected

**COPPA (Children):**
- ⚠️ Parental permission required for users under 13
- ✅ No data collection from children
- ✅ Age-appropriate content

## 🔄 Data Retention

**During App Use:**
- All data retained locally
- No automatic deletion

**After App Deletion:**
- All local data deleted by iOS
- App Group data deleted
- Keychain data persists (can be deleted manually)
- No cloud data to clean up

**Statistics Cleanup:**
- Daily stats older than 30 days auto-deleted
- User can manually reset statistics
- User can clear all data via Settings

## 🚨 Security Incident Response

If security issue discovered:

1. **Report**: Email security@pocketfence.app (if available)
2. **Investigation**: Issue investigated within 24 hours
3. **Fix**: Patch developed if confirmed
4. **Release**: Update released ASAP
5. **Disclosure**: Responsible disclosure after fix

## 🔒 Secure Development

### Code Practices

- ✅ Input validation
- ✅ Error handling
- ✅ No hardcoded secrets
- ✅ Secure coding guidelines
- ✅ Regular dependency updates

### Build Security

- ✅ Code signing
- ✅ Reproducible builds
- ✅ Dependency verification
- ✅ Build environment isolation

## 📱 Device Security Recommendations

For maximum security:

1. **Enable Find My iPhone**
2. **Use Strong Passcode** (not 1234)
3. **Enable Face ID/Touch ID**
4. **Keep iOS Updated**
5. **Review App Permissions** regularly
6. **Use Screen Time** for additional controls
7. **Enable Two-Factor Authentication** on Apple ID

## 📞 Security Contact

For security concerns or vulnerability reports:
- **Email**: security@pocketfence.app (if available)
- **GitHub**: Report via private security advisory
- **Response Time**: Within 24 hours

## ✅ Security Checklist

Before releasing updates:

- [ ] Code reviewed
- [ ] Dependencies updated
- [ ] Permissions justified
- [ ] Data collection documented
- [ ] Privacy policy updated
- [ ] Security testing performed
- [ ] No sensitive data in logs
- [ ] Entitlements minimized
- [ ] Network traffic reviewed
- [ ] App Store guidelines verified

---

**Last Updated**: December 2025
**Version**: 1.0.0

PocketFence prioritizes your privacy and security. All code is open source and available for audit.
