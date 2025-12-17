# Contributing to PocketFence iOS

Thank you for considering contributing to PocketFence! This document provides guidelines for contributing to the project.

## 🤝 Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

**Positive behaviors:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

**Unacceptable behaviors:**
- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

## 🚀 Getting Started

### Prerequisites

- macOS 12.0 or later
- Xcode 13.0 or later
- iOS 15.0+ device (for testing Network Extension)
- Apple Developer account (for device testing)
- Git installed
- Basic knowledge of Swift and iOS development

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/PocketFence-IOS.git
   cd PocketFence-IOS
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/DJMcClellan1966/PocketFence-IOS.git
   ```

4. **Open in Xcode**
   ```bash
   open PocketFence.xcodeproj
   ```

5. **Configure signing**
   - Update bundle identifiers
   - Select your development team
   - Configure capabilities

6. **Build and run**
   - Select a physical device
   - Build (⌘R)

## 📋 Types of Contributions

We welcome various types of contributions:

### 🐛 Bug Reports

Found a bug? Help us fix it:

1. **Search existing issues** to avoid duplicates
2. **Create a new issue** with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - iOS version
   - App version
   - Screenshots if applicable

**Template:**
```markdown
### Description
Brief description of the bug

### Steps to Reproduce
1. Step one
2. Step two
3. Step three

### Expected Behavior
What should happen

### Actual Behavior
What actually happens

### Environment
- iOS Version: 15.5
- App Version: 1.0.0
- Device: iPhone 13 Pro

### Screenshots
[If applicable]
```

### ✨ Feature Requests

Have an idea? Share it:

1. **Search existing requests** to avoid duplicates
2. **Create a new issue** with:
   - Clear feature description
   - Use case / motivation
   - Proposed implementation (optional)
   - Alternative solutions considered

**Template:**
```markdown
### Feature Description
Clear description of the feature

### Motivation
Why is this feature needed?

### Proposed Solution
How could this be implemented?

### Alternatives Considered
What other solutions did you consider?

### Additional Context
Any other relevant information
```

### 🔧 Code Contributions

Ready to code? Follow these steps:

1. **Find or create an issue**
   - Comment that you're working on it
   - Discuss approach if non-trivial

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Follow code style guidelines
   - Write clean, documented code
   - Add/update tests if applicable

4. **Test thoroughly**
   - Run on physical device
   - Test all affected features
   - Verify no regressions

5. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: add awesome feature"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create Pull Request**
   - Fill out PR template
   - Link related issues
   - Request review

### 📝 Documentation

Improve our docs:
- Fix typos or unclear explanations
- Add missing documentation
- Improve code comments
- Create tutorials or guides
- Translate documentation

### 🎨 Design

Contribute to UI/UX:
- Design mockups
- Create icons or graphics
- Improve layouts
- Suggest UX improvements

## 📜 Code Style Guidelines

### Swift Style

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

**Naming:**
```swift
// Good
func fetchBlockedSites() -> [BlockedWebsite]
var isProtectionEnabled: Bool
let maximumDeviceCount = 50

// Bad
func getBSites() -> [BlockedWebsite]
var protEnabled: Bool
let MAX_DEV_CNT = 50
```

**Formatting:**
```swift
// Good
func process(device: Device, 
            with settings: AppSettings) {
    guard settings.isEnabled else { return }
    // ...
}

// Bad
func process(device:Device,with settings:AppSettings){
guard settings.isEnabled else{return}
// ...
}
```

**Comments:**
```swift
// Use comments for why, not what
// Good: Explain reasoning
// Reset usage at midnight to start fresh daily tracking
device.timeUsedToday = 0

// Bad: Obvious comment
// Set time used to zero
device.timeUsedToday = 0
```

### SwiftUI Style

**View Structure:**
```swift
struct MyView: View {
    // MARK: - Properties
    @StateObject private var viewModel = MyViewModel()
    @State private var showingSheet = false
    
    // MARK: - Body
    var body: some View {
        // Main content
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        // Header implementation
    }
}
```

**Extract Subviews:**
```swift
// Good: Extracted for clarity
struct DeviceRow: View {
    let device: Device
    var body: some View { /* ... */ }
}

// Bad: Inline complex views
var body: some View {
    List {
        ForEach(devices) { device in
            HStack {
                // 50 lines of complex UI
            }
        }
    }
}
```

### Architecture Guidelines

**MVVM Pattern:**
```swift
// ViewModel handles logic
class DevicesViewModel: ObservableObject {
    @Published var devices: [Device] = []
    
    func loadDevices() {
        devices = deviceRepo.devices
    }
}

// View displays UI
struct DevicesView: View {
    @StateObject var viewModel = DevicesViewModel()
    
    var body: some View {
        List(viewModel.devices) { device in
            // UI only
        }
    }
}
```

**Repository Pattern:**
```swift
class DeviceRepository: ObservableObject {
    @Published private(set) var devices: [Device] = []
    
    func loadDevices() { /* Storage access */ }
    func saveDevices() { /* Storage access */ }
}
```

## 🧪 Testing Guidelines

### Unit Tests

Write unit tests for:
- ViewModels business logic
- Repository operations
- Service methods
- Utility functions

**Example:**
```swift
class DevicesViewModelTests: XCTestCase {
    var viewModel: DevicesViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = DevicesViewModel()
    }
    
    func testToggleDeviceBlock() {
        let device = Device.sample
        viewModel.toggleDeviceBlock(device)
        
        // Assert expected behavior
        XCTAssertTrue(device.isBlocked)
    }
}
```

### Manual Testing

Before submitting PR:
- [ ] App builds without warnings
- [ ] All features work as expected
- [ ] No crashes or bugs introduced
- [ ] Tested on physical device
- [ ] Network Extension tested
- [ ] UI looks correct
- [ ] Performance is acceptable

## 📝 Commit Message Guidelines

Use [Conventional Commits](https://www.conventionalcommits.org/):

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(dashboard): add real-time statistics chart

fix(blocking): resolve DNS filtering race condition

docs(readme): update installation instructions

refactor(services): extract network utilities
```

## 🔀 Pull Request Process

### Before Submitting

1. **Update from upstream**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests** (if tests exist)
   ```bash
   # Run test scheme in Xcode
   ```

3. **Check code style**
   - No compiler warnings
   - Follows style guidelines
   - Well-documented

4. **Update documentation**
   - README if needed
   - Code comments
   - Architecture docs

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Closes #123

## Testing
- [ ] Tested on physical device
- [ ] Manual testing performed
- [ ] Unit tests added/updated

## Screenshots
[If applicable]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex code
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tested thoroughly
```

### Review Process

1. **Automated checks** run automatically
2. **Maintainer review** happens within 3-5 days
3. **Address feedback** if changes requested
4. **Merge** after approval

## 🏷️ Issue Labels

- `bug`: Something isn't working
- `feature`: New feature request
- `documentation`: Documentation improvements
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `question`: Further information requested
- `wontfix`: Will not be worked on
- `duplicate`: Duplicate issue

## 🎯 Priority Contributions

These areas especially need help:

### High Priority
- Bug fixes
- Security improvements
- Performance optimizations
- iOS 16/17 compatibility
- Accessibility improvements

### Medium Priority
- New blocking categories
- UI/UX enhancements
- Documentation improvements
- Unit test coverage
- Localization

### Low Priority
- Code refactoring
- Minor UI tweaks
- Additional statistics
- Optional features

## 📚 Resources

### Learning Resources
- [Swift Documentation](https://docs.swift.org)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Network Extension](https://developer.apple.com/documentation/networkextension)
- [StoreKit 2](https://developer.apple.com/documentation/storekit)

### Project Resources
- [README.md](README.md) - Project overview
- [ARCHITECTURE_FLOW.md](ARCHITECTURE_FLOW.md) - Architecture details
- [FEATURES.md](FEATURES.md) - Feature documentation
- [SECURITY.md](SECURITY.md) - Security information

## 💬 Community

### Getting Help

- **GitHub Discussions**: For questions and discussions
- **GitHub Issues**: For bugs and features
- **Email**: support@pocketfence.app (if available)

### Communication Guidelines

- Be respectful and professional
- Stay on topic
- Help others when you can
- Provide constructive feedback
- Be patient with responses

## 🎉 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Credited in release notes
- Thanked in the community

## ⚖️ Legal

By contributing, you agree that:
- Your contributions will be licensed under MIT License
- You have rights to submit the contribution
- You grant us rights to use your contribution

## 📋 Checklist for Contributors

Before first contribution:
- [ ] Read Code of Conduct
- [ ] Read Contributing Guidelines
- [ ] Set up development environment
- [ ] Understand project architecture
- [ ] Join community discussions

Before each contribution:
- [ ] Check existing issues/PRs
- [ ] Create/discuss issue first
- [ ] Follow code style guidelines
- [ ] Write clean, documented code
- [ ] Test thoroughly
- [ ] Update documentation
- [ ] Write good commit messages
- [ ] Create descriptive PR

---

Thank you for contributing to PocketFence! Your efforts help make the internet safer for everyone. 🛡️
