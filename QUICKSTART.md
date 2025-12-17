# PocketFence iOS - Quick Start Guide

This guide will help you get PocketFence up and running on your iOS device in just a few minutes.

## Prerequisites

Before you begin, make sure you have:
- ✅ Xcode 13.0 or later installed
- ✅ A physical iOS device running iOS 15.0 or later
- ✅ An Apple Developer account (for device testing)
- ✅ Basic knowledge of Xcode and iOS development

**⚠️ Important**: Network Extensions do not work in the iOS Simulator. You must use a physical device.

## Step 1: Clone the Repository

```bash
git clone https://github.com/DJMcClellan1966/PocketFence-IOS.git
cd PocketFence-IOS
```

## Step 2: Open the Project

Open the project in Xcode:
```bash
open PocketFence.xcodeproj
```

Or double-click `PocketFence.xcodeproj` in Finder.

## Step 3: Configure Bundle Identifiers

You'll need to update the bundle identifiers to match your Apple Developer account:

### Main App Target
1. Select the **PocketFence** target
2. Go to **Signing & Capabilities**
3. Change the Bundle Identifier to: `com.yourcompany.pocketfence`

### Network Extension Target
1. Select the **PocketFence NetworkExtension** target
2. Go to **Signing & Capabilities**
3. Change the Bundle Identifier to: `com.yourcompany.pocketfence.NetworkExtension`

## Step 4: Configure App Groups

Both targets need to use the same App Group for communication:

### For Main App:
1. Select **PocketFence** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add **App Groups**
4. Add group: `group.com.yourcompany.pocketfence`

### For Network Extension:
1. Select **PocketFence NetworkExtension** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add **App Groups**
4. Add the same group: `group.com.yourcompany.pocketfence`

### Update Code References
Update the App Group identifier in `Constants.swift`:
```swift
enum App {
    static let appGroupIdentifier = "group.com.yourcompany.pocketfence"
}
```

## Step 5: Configure Network Extension Capability

### For Main App:
1. Select **PocketFence** target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add **Network Extensions**
4. Enable **Packet Tunnel**

### For Network Extension:
1. Select **PocketFence NetworkExtension** target
2. Go to **Signing & Capabilities**
3. Verify **Network Extensions** capability is present
4. Ensure **Packet Tunnel** is enabled

## Step 6: Configure Signing

### For Both Targets:
1. Select each target (PocketFence and PocketFence NetworkExtension)
2. Go to **Signing & Capabilities**
3. Check **Automatically manage signing**
4. Select your **Team** from the dropdown
5. Xcode will automatically create provisioning profiles

If you encounter signing errors:
- Ensure your Apple Developer account is active
- Try manually creating App IDs and provisioning profiles on the Apple Developer portal
- Make sure Network Extension capability is enabled in your App ID

## Step 7: Build and Run

1. **Connect your iOS device** via USB
2. **Trust the device** if prompted on your Mac and iOS device
3. **Select your device** from the device menu in Xcode
4. **Build and run** the app (⌘R)

### First Launch
On first launch, you may see:
- A prompt to install the VPN configuration - **Allow** this
- A prompt for Local Network access - **Allow** this
- A notification permission request - **Allow** this

## Step 8: Enable Protection

1. Open PocketFence on your device
2. Tap the **Dashboard** tab
3. Tap **Enable Protection**
4. You'll be prompted to allow VPN configuration - enter your passcode
5. The protection status should show **"Protection Active"**

## Step 9: Configure Blocking (Optional)

### Add Blocked Sites
1. Go to **Blocked Sites** tab
2. Tap the menu (⋯) in the top right
3. Choose a category to block (e.g., Social Media)
4. Or tap **Add Site** to add a custom domain

### Set Time Limits
1. Go to **Time Limits** tab
2. Tap **Set Global Time Limit**
3. Adjust the slider to set daily minutes
4. Optionally add **Quiet Hours** for nighttime blocking

### Manage Devices
1. Go to **Devices** tab
2. Tap the menu (⋯) and select **Scan for Devices**
3. Detected devices will appear in the list
4. Tap a device to configure individual settings

## Troubleshooting

### VPN Configuration Fails
- **Solution**: Delete any existing PocketFence VPN profiles from Settings > General > VPN & Device Management
- Try restarting the app and enabling protection again

### Devices Not Detected
- **Solution**: Ensure Local Network permission is granted in Settings > Privacy > Local Network > PocketFence
- Make sure Personal Hotspot is active
- Try manually adding devices using the **Add Device** button

### Sites Not Being Blocked
- **Solution**: Verify protection is enabled (green shield on Dashboard)
- Check that sites are enabled in Blocked Sites list (toggle should be ON)
- Try disabling and re-enabling protection
- Restart the app

### Build Errors
- **Bundle ID conflicts**: Make sure your bundle IDs are unique
- **Signing errors**: Verify your Apple Developer account is active
- **Missing capabilities**: Ensure Network Extension capability is added to both targets
- **App Group errors**: Verify both targets use the same App Group ID

### Network Extension Not Loading
- **Solution**: Check that the Network Extension target builds successfully
- Verify the extension's Info.plist has correct NSExtensionPrincipalClass
- Ensure bundle identifiers match between app and extension configuration

## Testing

### Test Website Blocking
1. Enable protection
2. Add `example.com` to blocked sites
3. Open Safari and try to visit `http://example.com`
4. The site should fail to load
5. Check Dashboard for increased block count

### Test Time Limits
1. Set a very low time limit (e.g., 1 minute) for testing
2. Use a device for more than the limit
3. The device should be automatically blocked
4. Dashboard should show "Limit" status for the device

### Test Quiet Hours
1. Set quiet hours for the current time
2. Protection should activate immediately
3. All internet access should be blocked
4. Test by trying to load any website

## Next Steps

Now that PocketFence is running:

1. **Explore Features**: Check out [FEATURES.md](FEATURES.md) for detailed feature documentation
2. **Understand Architecture**: Read [ARCHITECTURE_FLOW.md](ARCHITECTURE_FLOW.md) to understand how it works
3. **Configure Premium**: See [MONETIZATION_GUIDE.md](MONETIZATION_GUIDE.md) to set up in-app purchases
4. **Review Security**: Learn about privacy in [SECURITY.md](SECURITY.md)

## Getting Help

If you encounter issues:
- Check the [Troubleshooting](#troubleshooting) section above
- Review [GitHub Issues](https://github.com/DJMcClellan1966/PocketFence-IOS/issues)
- Contact support at support@pocketfence.app

## Development Tips

### Debugging Network Extension
- Use `os_log` for logging in the Network Extension
- View logs in Console.app by filtering for "PocketFence"
- Check for extension crashes in Settings > Privacy > Analytics & Improvements

### Testing on Multiple Devices
- Use TestFlight for distributing to test devices
- Share provisioning profiles with team members
- Use the same App Group ID across all installations

### Local Development
- Changes to the Network Extension require stopping and restarting protection
- Use breakpoints in Xcode for debugging the main app
- Network Extension debugging requires attaching to the extension process

---

🎉 **Congratulations!** You now have PocketFence running on your iOS device. Enjoy safer internet browsing!
