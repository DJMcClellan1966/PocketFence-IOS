# ScreenBalance - Visual Design & UI Mockups

## 🎨 Design Philosophy

**Calm · Intelligent · Empowering**

ScreenBalance uses a wellness-focused design language that promotes calm, provides clarity, and empowers users through positive visual feedback.

## 🌈 Color Palette

### Primary Colors
```
Wellness Primary (Calm Blue)
RGB: (102, 153, 255)
Hex: #6699FF
Usage: Primary actions, wellness indicators, focus states

Wellness Green (Healthy)
RGB: (51, 199, 89)
Hex: #33C759
Usage: Optimal scores, success states, achievements

Wellness Purple (Focus)
RGB: (153, 102, 230)
Hex: #9966E6
Usage: Focus sessions, deep work indicators

Wellness Orange (Warning)
RGB: (255, 148, 0)
Hex: #FF9400
Usage: Moderate concerns, break reminders

Wellness Red (Alert)
RGB: (235, 66, 54)
Hex: #EB4236
Usage: Critical alerts, urgent actions needed
```

### Neutral Colors
```
Card Background: System background (adaptive)
Secondary Background: System secondary background
Text Primary: System label
Text Secondary: System secondary label
```

## 📱 Main Dashboard (Wellness Tab)

### Layout Structure
```
┌─────────────────────────────────┐
│  ScreenBalance    [💡]          │  ← Navigation Bar
├─────────────────────────────────┤
│                                 │
│  ┌─────────────────────────┐   │
│  │  Digital Wellness   🌟  │   │  ← Header
│  │                         │   │
│  │       ╭─────────╮      │   │
│  │      ╱   85    ╲      │   │  ← Circular Score
│  │     │           │     │   │  (150px diameter)
│  │      ╲  Optimal ╱      │   │
│  │       ╰─────────╯      │   │
│  │                         │   │
│  │  ✨ Great job taking   │   │  ← Smart Recommendation
│  │  regular breaks! 🎉    │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │  ← Active Focus (if any)
│  │  🎯 Focus Session Active│   │
│  │  Deep Focus             │   │
│  │  32:15      3 distr.    │   │
│  │  ▓▓▓▓▓▓▓▓▓░░░ 53%      │   │
│  │              [End]      │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌───────┬────────┬─────────┐  │  ← Quick Actions
│  │  🎯   │  ⏸️   │   💡    │  │
│  │Focus  │ Break │ Insights│  │
│  └───────┴────────┴─────────┘  │
│                                 │
│  ┌─────────────────────────┐   │  ← Insights Preview
│  │  Today's Insights  [→]  │   │
│  │                         │   │
│  │  ⏰ Break Reminder      │   │
│  │  You've been focused... │   │
│  │                         │   │
│  │  🎯 Excellent Focus!    │   │
│  │  You've completed 3...  │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌───────┬───────┬─────────┐   │  ← Stats Grid
│  │ 🚶 3  │ 🎯 4  │  🛡️ 12 │   │
│  │Device │Focus  │ Blocked │   │
│  └───────┴───────┴─────────┘   │
│                                 │
│  ┌─────────────────────────┐   │  ← Recent Activity
│  │  Recent Activity        │   │
│  │  🚫 twitter.com    8×   │   │
│  │  🚫 facebook.com   5×   │   │
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

## 🎯 Energy Score Visualization

### Circular Progress Indicator

```
     Optimal (80-100)          Good (60-79)
        🌟                        😊
     ╭─────────╮              ╭─────────╮
    ╱   85    ╲             ╱   72    ╲
   │   ████    │           │   ███     │    ← Green fill
    ╲ Optimal ╱             ╲   Good  ╱     ← Blue fill
     ╰─────────╯              ╰─────────╯

    Moderate (40-59)         Critical (0-19)
        😐                        🔴
     ╭─────────╮              ╭─────────╮
    ╱   45    ╲             ╱   15    ╲
   │   ██      │           │   █       │    ← Orange fill
    ╲ Moderate╱             ╲ Critical╱     ← Red fill
     ╰─────────╯              ╰─────────╯
```

### Animation
- Smooth spring animation on score changes
- Emoji transitions when crossing thresholds
- Subtle pulse effect when showing
- Color transitions between wellness levels

## 🎯 Focus Session Interface

### Active Session Card
```
┌─────────────────────────────────┐
│  🧠 Focus Session Active        │
│                                 │
│  Deep Focus                     │  ← Session name
│  45:23                          │  ← Live timer
│                                 │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░  76%        │  ← Progress
│                                 │
│  2 distractions                 │  ← Tracking
│                                 │
│           [End Session]         │
└─────────────────────────────────┘
```

### Start Session Sheet
```
┌─────────────────────────────────┐
│  ← Cancel  Start Focus   Start  │
│                                 │
│  Session Type                   │
│  ○ 💼 Work                      │
│  ● 📚 Study         ← Selected  │
│  ○ 🎨 Creative                  │
│  ○ 🧠 Deep Focus                │
│  ○ 📖 Reading                   │
│  ○ 🧘 Meditation                │
│                                 │
│  Duration                       │
│  ●────────────○────────  30 min │
│  5 min                  60 min  │
│                                 │
└─────────────────────────────────┘
```

## 💡 Insights Interface

### Insights List
```
┌─────────────────────────────────┐
│  ← Back    Wellness Insights    │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 🎯 Excellent Focus Today! │ │  ← Achievement
│  │ You've completed 4 focus  │ │
│  │ sessions. Outstanding!    │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ ⏰ High Screen Time       │ │  ← Alert
│  │ 6.5 hours today. Consider │ │
│  │ taking extended break.    │ │
│  │                           │ │
│  │ Suggested Actions:        │ │
│  │ • Take 15-minute walk     │ │
│  │ • Try 5-minute meditation │ │
│  │ • Stretch your body       │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 💚 Great Break Habits!    │ │  ← Positive
│  │ You've taken 5 breaks     │ │
│  │ today. Keep it up! 👏     │ │
│  └───────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

## 📊 Statistics View (Future)

### Wellness Trends
```
┌─────────────────────────────────┐
│  Energy Score - Last 7 Days     │
│                                 │
│  100│    ●───●               │
│   80│ ●──┘   └──●            │
│   60│              └──●       │  ← Line graph
│   40│                 └──●    │
│   20│                        │
│    0│───────────────────────│
│      Mon Tue Wed Thu Fri Sat  │
│                                 │
│  Average: 76  ↑ +8 from last   │
└─────────────────────────────────┘
```

## 🗂️ Tab Bar Design

```
┌─────────────────────────────────┐
│                                 │
│         (Main Content)          │
│                                 │
├─────────────────────────────────┤
│ 💚     🎯     📱     ⚖️    ⚙️  │
│Wellness Focus Devices Balance Set│
│   ●                              │  ← Selected indicator
└─────────────────────────────────┘
```

### Tab Items
1. **Wellness** 💚 - Main dashboard (selected by default)
2. **Focus** 🎯 - Time management and productivity
3. **Devices** 📱 - Connected device monitoring
4. **Balance** ⚖️ - Content filtering (reframed positively)
5. **Settings** ⚙️ - App preferences

## 🎨 Typography

### Font System
```
Title Large:     SF Pro Display, 34pt, Bold
Title:           SF Pro Display, 28pt, Bold
Headline:        SF Pro Text, 17pt, Semibold
Body:            SF Pro Text, 17pt, Regular
Subheadline:     SF Pro Text, 15pt, Regular
Caption:         SF Pro Text, 12pt, Regular
```

### Usage
- **Title Large**: Main dashboard title "ScreenBalance"
- **Title**: Energy score number (85)
- **Headline**: Card headers, insight titles
- **Body**: Recommendations, insight messages
- **Subheadline**: Secondary information
- **Caption**: Timestamps, metadata

## 🌟 Iconography

### System Icons (SF Symbols)
```
Wellness:     heart.circle.fill
Energy:       bolt.circle.fill
Focus:        target
Break:        pause.circle.fill
Insight:      lightbulb.fill
Balance:      scale.3d
Achievement:  star.fill
Alert:        exclamationmark.triangle.fill
Success:      checkmark.circle.fill
```

### Icon Colors
- Primary actions: Wellness Primary (blue)
- Success/Optimal: Wellness Green
- Focus features: Wellness Purple
- Warnings: Wellness Orange
- Alerts: Wellness Red

## 🎭 Animation & Transitions

### Energy Score
```
Entrance: Scale up from 0.8 with spring
Update:   Smooth arc animation over 0.5s
Color:    Gradient transition between states
Emoji:    Bounce effect on change
```

### Insights
```
Appear:   Slide from bottom with fade
Dismiss:  Slide to right
New:      Subtle pulse to draw attention
```

### Focus Session
```
Timer:    Smooth count-up, monospaced font
Progress: Linear fill animation
End:      Celebration confetti effect
```

## 📐 Spacing & Layout

### Grid System
```
Base unit: 8px
Small:     8px  (1 unit)
Medium:    16px (2 units)
Large:     24px (3 units)
XLarge:    32px (4 units)
```

### Card Padding
```
Internal:  16px all sides
Between:   20px vertical spacing
Edge:      16px from screen edges
```

### Corner Radius
```
Small:     8px  (buttons, tags)
Medium:    12px (stat cards)
Large:     16px (main cards)
Circle:    50% (energy score, avatars)
```

## 🌓 Dark Mode

### Adaptations
- All colors use semantic system colors
- Automatic adaptation to appearance
- Card backgrounds use system backgrounds
- Maintains WCAG AA contrast ratios
- Energy score remains vibrant

### Example
```
Light Mode              Dark Mode
──────────              ─────────
Background: White       Background: Black (#000)
Cards: Light Gray       Cards: Dark Gray (#1C1C1E)
Text: Black             Text: White
Score: Vibrant          Score: Same vibrance
```

## ♿ Accessibility

### Features
- Dynamic Type support (all text)
- VoiceOver labels on all interactive elements
- Minimum 44×44pt touch targets
- Color-blind friendly (icons + text)
- High contrast mode support
- Reduce motion support

### VoiceOver Examples
```
Energy Score: "Digital wellness score: 85 out of 100. Optimal."
Focus Button: "Start focus session. Button."
Insight: "High screen time alert. You've spent 6.5 hours..."
```

## 🎬 Onboarding Flow

### Welcome Screens
```
Screen 1: Hero
┌─────────────────────────────────┐
│         🌟                      │
│                                 │
│    Welcome to                   │
│    ScreenBalance                │
│                                 │
│  Your Digital Wellness Coach    │
│                                 │
│          [Continue]             │
└─────────────────────────────────┘

Screen 2: Energy Score
┌─────────────────────────────────┐
│      ╭─────────╮                │
│     ╱   85    ╲                │
│    │  ████     │                │
│     ╲ Optimal ╱                 │
│      ╰─────────╯                │
│                                 │
│  Real-time Wellness Score       │
│  Track your digital health      │
│                                 │
│          [Continue]             │
└─────────────────────────────────┘

Screen 3: Focus Sessions
┌─────────────────────────────────┐
│         🎯                      │
│                                 │
│   Smart Focus Sessions          │
│   Enter productive flow states  │
│   with intelligent tracking     │
│                                 │
│          [Continue]             │
└─────────────────────────────────┘

Screen 4: Insights
┌─────────────────────────────────┐
│         💡                      │
│                                 │
│   AI-Powered Insights           │
│   Personalized recommendations  │
│   that adapt to you             │
│                                 │
│          [Get Started]          │
└─────────────────────────────────┘
```

## 🎊 Celebration Moments

### Achievements
```
┌─────────────────────────────────┐
│                                 │
│           🎉                    │
│                                 │
│      Achievement Unlocked!      │
│                                 │
│     First Focus Session         │
│                                 │
│   You completed your first      │
│   25-minute focus session!      │
│                                 │
│          [Awesome!]             │
│                                 │
└─────────────────────────────────┘
```

## 📱 Device Compatibility

### iPhone
- iPhone 12 and later: Full feature set
- iPhone SE (2020+): Optimized layout
- Portrait orientation primary
- Landscape support for charts

### iPad (Future)
- Two-column layout in landscape
- Larger energy score visualization
- Side-by-side insights and stats
- Keyboard shortcuts support

---

**Design System Version:** 1.0  
**Last Updated:** December 2025  
**Platform:** iOS 17.0+

**Design Tools:**
- Figma (mockups)
- SF Symbols (icons)
- Xcode (interface builder)

**Inspiration:**
- Apple Health
- Apple Fitness
- Calm
- Headspace
- Screen Time (but better!)

---

Made with 💚 for beautiful, wellness-focused design
