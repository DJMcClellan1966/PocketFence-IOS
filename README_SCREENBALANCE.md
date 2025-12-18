# ScreenBalance for iOS 🌟

[![Platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-green.svg)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](LICENSE)

**The Digital Wellness Coach Everyone Needs But No One Has**

ScreenBalance is an intelligent iOS app that goes beyond simple screen time tracking. It's your personal digital wellness coach that predicts unhealthy patterns, provides actionable insights, and helps you build sustainable digital habits through AI-powered behavioral analysis.

## 🎯 What Makes ScreenBalance Unique

Unlike traditional parental controls or simple timers, ScreenBalance:

✨ **Predicts Burnout**: Uses pattern analysis to detect when you're entering unhealthy digital habits  
🧠 **AI-Powered Insights**: Generates personalized recommendations based on your unique behavior  
🎯 **Focus Enhancement**: Helps you enter and maintain productive flow states  
💚 **Positive Reinforcement**: Rewards healthy behavior instead of just restricting access  
📊 **Digital Energy Score**: Real-time wellness metric (0-100) showing your current state  
⚡ **Proactive Coaching**: Suggests breaks and activities before you burn out

## 📱 Core Features

### 🌟 Digital Energy Score
Your wellness at a glance. A dynamic 0-100 score that considers:
- Screen time duration and patterns
- Break frequency and quality
- Focus session completion
- Distraction levels
- Time of day patterns

**Visual feedback with emoji indicators:**
- 🌟 80-100: Optimal wellness
- 😊 60-79: Good balance
- 😐 40-59: Moderate concern
- 😕 20-39: Low wellness
- 🔴 0-19: Critical attention needed

### 🎯 Smart Focus Sessions
Transform your productivity with guided focus periods:
- **Multiple Session Types**: Work, Study, Creative, Deep Focus, Reading, Meditation
- **Customizable Durations**: 5-60 minutes with intelligent defaults
- **Distraction Tracking**: Monitors and counts interruptions
- **Success Metrics**: Calculate completion rates and quality
- **Real-time Progress**: Visual timer with goal tracking

### 💡 Intelligent Insights
AI-generated wellness insights that learn from your patterns:
- **Pattern Recognition**: Identifies unhealthy trends before they become problems
- **Actionable Recommendations**: Specific steps to improve wellness
- **Category-based Analysis**: Screen time, breaks, focus, achievements, wellbeing
- **Priority Levels**: Critical, high, medium, low alerts
- **Contextual Suggestions**: Time-aware recommendations (morning, afternoon, evening)

### 🚶 Smart Break Reminders
Never forget to rest:
- Tracks time since last break
- Suggests optimal break duration
- Provides specific break activities
- Celebrates consistent break-taking
- Integrates with wellness score

### 📊 Wellness Analytics
Comprehensive tracking and visualization:
- Daily energy score trends
- Focus session history
- Break patterns
- Distraction analysis
- Week-over-week comparisons
- Long-term wellness trajectory

## 🏗️ Architecture

ScreenBalance leverages the existing PocketFence infrastructure while adding innovative wellness features:

### New Components

```
PocketFence/
├── Models/
│   ├── DigitalEnergyScore.swift      # Wellness scoring system
│   ├── FocusSession.swift            # Productivity tracking
│   └── WellnessInsight.swift         # AI insights engine
│
├── Services/
│   └── WellnessAnalyticsService.swift # Intelligence layer
│
└── Views/
    └── Dashboard/
        └── WellnessDashboardView.swift # Wellness-first UI
```

### Design Philosophy

**From Restrictive to Empowering:**
- PocketFence: "Block what's bad"
- ScreenBalance: "Enhance what's good"

**From Reactive to Proactive:**
- Traditional: React to excessive usage
- ScreenBalance: Predict and prevent before problems occur

**From Generic to Personal:**
- Standard: One-size-fits-all rules
- ScreenBalance: Learns your unique patterns and needs

## 🎨 User Experience

### Enhanced Dashboard
The wellness-first dashboard shows:
1. **Hero Element**: Large circular energy score with emoji
2. **Smart Recommendation**: Contextual advice based on current state
3. **Active Focus Session**: Live timer if session in progress
4. **Quick Actions**: One-tap access to Focus, Break, and Insights
5. **Today's Insights**: Preview of AI-generated recommendations
6. **Wellness Stats**: Devices, focus sessions, blocks at a glance

### Tab Navigation (Wellness-First)
1. **Wellness** 💚 - Your digital energy and insights
2. **Focus** 🎯 - Productivity and time management
3. **Devices** 📱 - Connected device monitoring
4. **Balance** ⚖️ - Smart content filtering
5. **Settings** ⚙️ - App preferences and premium

## 💰 Monetization

### Free Version
- Full wellness tracking
- Digital energy score
- Basic insights (3 per day)
- Focus sessions (25 min max)
- Ad-supported

### Premium ($4.99 one-time)
- ✨ Unlimited insights
- 📈 Advanced analytics and trends
- 🎯 Extended focus sessions (up to 4 hours)
- 📊 Wellness reports and exports
- 💬 Priority support
- 🚫 Ad-free experience
- 🔮 Predictive pattern analysis

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
   - Main App: `com.screenbalance.ios`
   - Network Extension: `com.screenbalance.ios.NetworkExtension`
   - App Group: `group.com.screenbalance.ios`

4. **Build and Run**
   - Select a physical device (required for Network Extensions)
   - Build and run (⌘R)

### First Launch Experience

1. **Welcome Screen**: Introduction to ScreenBalance concept
2. **Wellness Tutorial**: How the energy score works
3. **Permission Setup**: Network extension and notifications
4. **First Focus Session**: Guided intro to productivity features
5. **Dashboard**: Start your wellness journey

## 🧪 Use Cases

### For Individuals
**"I want to be more productive"**
- Use focus sessions to maintain concentration
- Track distraction patterns
- Get break reminders when needed
- Build sustainable work habits

**"I'm experiencing digital burnout"**
- Monitor your energy score daily
- Follow AI-generated insights
- Take recommended breaks
- Gradually improve wellness

**"I want better work-life balance"**
- Set quiet hours for evening wind-down
- Track screen time patterns
- Receive time-aware recommendations
- Celebrate progress and achievements

### For Students
- Focus sessions for study periods
- Break reminders during long study marathons
- Block distracting sites during exam prep
- Track productivity patterns

### For Remote Workers
- Maintain healthy screen time boundaries
- Prevent work-from-home burnout
- Structured focus and break cycles
- Evening disconnect reminders

### For Anyone
- Build awareness of digital habits
- Reduce mindless scrolling
- Improve sleep through evening recommendations
- Create sustainable digital wellness

## 🔬 How It Works

### Wellness Score Algorithm

```
Base Score: 100

Adjustments:
- Screen Time: -30 if >6h, -15 if >4h
- Breaks: -20 if insufficient (should be 1 every 30-45min)
- Focus Sessions: +5 per session (max +15)
- Distractions: -15 if >10, -8 if >5

Final: max(0, min(100, adjusted_score))
```

### Insight Generation

The AI insight engine analyzes:
1. **Usage Patterns**: Time of day, duration, frequency
2. **Behavioral Trends**: Comparing to previous days/weeks
3. **Context Awareness**: Morning vs evening, weekday vs weekend
4. **Personal Baselines**: Your normal vs current state
5. **Risk Factors**: Early warning signs of burnout

### Predictive Analysis

Pattern detection flags:
- Excessive screen time (>6 hours)
- High distraction levels (>10 per day)
- Insufficient breaks (<2 in 2+ hours of use)
- Late-night usage (after 10 PM)
- Declining energy score trends

## 📊 Data & Privacy

**All data stays on your device:**
- ✅ Local storage only (UserDefaults)
- ✅ No cloud sync
- ✅ No external servers
- ✅ No user tracking
- ✅ No data selling
- ✅ Open source and auditable

**What we track:**
- Energy scores (daily calculations)
- Focus session data (duration, type, success)
- Break timing (when and how many)
- Distractions (count only, no details)
- Generated insights (to avoid duplicates)

**What we DON'T track:**
- Browsing history
- App usage details
- Personal information
- Location data
- Contacts or messages

## 🛠️ Technical Details

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 6.0
- Physical device (Network Extensions don't work in Simulator)

### Frameworks
- **SwiftUI**: Modern, declarative UI
- **Observation**: iOS 17+ reactive state management
- **NetworkExtension**: Traffic monitoring
- **UserNotifications**: Break reminders and alerts
- **Foundation**: Core functionality

### Architecture
- **MVVM**: Clear separation of concerns
- **Service Layer**: Business logic isolation
- **Repository Pattern**: Data persistence
- **Reactive Updates**: Observation framework

## 🤝 Contributing

We welcome contributions! Areas of interest:

- 🧠 **Machine Learning**: Improve pattern detection
- 📊 **Visualization**: Better wellness charts
- 🎨 **Design**: UI/UX improvements
- 🌍 **Localization**: Multi-language support
- 🧪 **Testing**: Unit and UI tests
- 📱 **iPad**: Optimize for larger screens

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on the foundation of PocketFence iOS
- Inspired by digital wellness research
- Powered by iOS frameworks and Swift
- Community feedback and contributions

## 📞 Support

- **Email**: support@screenbalance.app
- **Issues**: [GitHub Issues](https://github.com/DJMcClellan1966/PocketFence-IOS/issues)
- **Discussions**: [GitHub Discussions](https://github.com/DJMcClellan1966/PocketFence-IOS/discussions)

## 🗺️ Roadmap

### Version 1.0 (Current)
- ✅ Digital energy score
- ✅ Focus sessions
- ✅ AI insights
- ✅ Smart recommendations

### Version 1.1
- [ ] Machine learning integration
- [ ] Wellness trend visualizations
- [ ] Customizable insight triggers
- [ ] Break activity suggestions
- [ ] Gamification and achievements

### Version 1.2
- [ ] Apple Health integration
- [ ] Screen Time API integration
- [ ] Social features (anonymous community)
- [ ] Wellness challenges
- [ ] Export to wellness apps

### Version 2.0
- [ ] Apple Watch companion
- [ ] Siri shortcuts
- [ ] Widget support
- [ ] Advanced ML predictions
- [ ] Personalized wellness coaching

---

**ScreenBalance: The app everyone needs but no one has — until now.**

Made with 💚 for your digital wellbeing
