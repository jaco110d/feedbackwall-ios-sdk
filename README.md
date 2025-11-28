# FeedbackWall iOS SDK

A lightweight, non-intrusive iOS SDK for displaying in-app surveys at key moments in your app.

## Features

- 🚀 **Non-blocking** – All network calls are asynchronous with short timeouts
- 🛡️ **Fail-silent** – Network errors are handled gracefully
- 🎯 **Trigger-based** – Show surveys at specific points in your app flow
- 🎨 **Themeable** – Customize colors and styling via backend configuration
- 📱 **iOS 15+** – Built with modern Swift and UIKit

## Installation

### Swift Package Manager

#### Using Xcode

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies…**
3. Enter the repository URL:
   ```
   https://github.com/jaco110d/feedbackwall-ios-sdk.git
   ```
4. Select the version rule (e.g., "Up to Next Major Version")
5. Click **Add Package**

#### Using Package.swift

Add the following to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/jaco110d/feedbackwall-ios-sdk.git", from: "1.0.0")
]
```

Then add `FeedbackWall` to your target dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: ["FeedbackWall"]
)
```

## Quick Start

### 1. Configure the SDK

Call `configure` once at app launch. Your `apiKey` and `baseURL` are provided by FeedbackWall.

```swift
import SwiftUI
import FeedbackWall

@main
struct YourApp: App {
    init() {
        FeedbackWall.configure(
            apiKey: "YOUR_API_KEY",
            baseURL: URL(string: "https://feedbackwall.io")!
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Identify the User

After login or when user information becomes available:

```swift
FeedbackWall.identify(
    userId: "user_123",
    traits: [
        "plan": "premium",
        "signupDate": "2024-01-15"
    ]
)
```

### 3. Trigger Surveys

Show surveys at key points in your app:

```swift
// After onboarding
FeedbackWall.showIfAvailable(trigger: "onboarding_completed")

// After a purchase
FeedbackWall.showIfAvailable(trigger: "purchase_completed")

// After using a feature
FeedbackWall.showIfAvailable(trigger: "feature_used")
```

## API Reference

### `FeedbackWall.configure(apiKey:baseURL:)`

Initializes the SDK. Must be called once at app launch before any other SDK methods.

| Parameter | Type | Description |
|-----------|------|-------------|
| `apiKey` | `String` | Your FeedbackWall API key (provided by FeedbackWall) |
| `baseURL` | `URL` | The FeedbackWall backend URL (provided by FeedbackWall) |

**When to call:** In your `AppDelegate.application(_:didFinishLaunchingWithOptions:)` or `App.init()`.

**Behavior on failure:** Logs a warning internally; subsequent SDK calls are safely ignored.

---

### `FeedbackWall.identify(userId:traits:)`

Associates the current user with surveys for targeting and analytics.

| Parameter | Type | Description |
|-----------|------|-------------|
| `userId` | `String` | A unique identifier for the user |
| `traits` | `[String: Any]?` | Optional dictionary of user properties (e.g., plan, role) |

**When to call:** After user login or when user identity is known.

**Behavior on failure:** Logs internally if called before `configure()`.

---

### `FeedbackWall.showIfAvailable(trigger:)`

Checks if a survey is available for the given trigger and presents it modally if so.

| Parameter | Type | Description |
|-----------|------|-------------|
| `trigger` | `String` | The trigger identifier (e.g., `"onboarding_completed"`) |

**When to call:** At key moments in your app flow—after onboarding, after a purchase, after using a feature.

**Behavior on failure:** Fails silently. If the backend is unreachable or no survey is available, nothing happens.

---

### `FeedbackWall.reset()`

Clears the current user session. Call this when the user logs out.

**When to call:** On user logout.

**Behavior on failure:** Completes safely.

## Requirements

| Requirement | Minimum Version |
|-------------|-----------------|
| iOS | 15.0+ |
| Swift | 5.9+ |
| Xcode | 15.0+ |

## License

MIT License – see [LICENSE](LICENSE) for details.
