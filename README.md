# FeedbackWall iOS SDK

A lightweight, non-intrusive iOS SDK for displaying in-app surveys at key moments in your app.

## Features

- 🚀 **Non-blocking** - All network calls are asynchronous and never block the main thread
- 🛡️ **Fail-silent** - SDK never crashes your app, even if the backend is down
- 🎯 **Trigger-based** - Show surveys at specific points in your app flow
- 🎨 **Themeable** - Customize colors and styling via backend configuration
- 📱 **iOS 15+** - Built with modern Swift and UIKit

## Installation

### Swift Package Manager

Add FeedbackWall to your project using Swift Package Manager:

#### Using Xcode

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Enter the repository URL:
   ```
   https://github.com/your-org/feedbackwall-ios-sdk.git
   ```
4. Select the version rule (e.g., "Up to Next Major Version")
5. Click **Add Package**

#### Using Package.swift

Add the following to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/feedbackwall-ios-sdk.git", from: "1.0.0")
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

Call `configure` once at app launch (e.g., in `AppDelegate` or `@main App`):

```swift
import FeedbackWall

// In AppDelegate.swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    FeedbackWall.configure(
        apiKey: "YOUR_API_KEY",
        baseURL: URL(string: "https://your-backend.com")!
    )
    
    return true
}
```

Or in SwiftUI:

```swift
import SwiftUI
import FeedbackWall

@main
struct YourApp: App {
    init() {
        FeedbackWall.configure(
            apiKey: "YOUR_API_KEY",
            baseURL: URL(string: "https://your-backend.com")!
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Identify Users (Optional)

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

Configures the SDK. Must be called before any other methods.

| Parameter | Type | Description |
|-----------|------|-------------|
| `apiKey` | `String` | Your FeedbackWall API key |
| `baseURL` | `URL` | The base URL of your FeedbackWall backend |

### `FeedbackWall.identify(userId:traits:)`

Identifies the current user for targeted surveys.

| Parameter | Type | Description |
|-----------|------|-------------|
| `userId` | `String` | Unique user identifier |
| `traits` | `[String: Any]?` | Optional user properties |

### `FeedbackWall.showIfAvailable(trigger:)`

Checks if a survey should be shown for the given trigger.

| Parameter | Type | Description |
|-----------|------|-------------|
| `trigger` | `String` | The trigger identifier |

### `FeedbackWall.reset()`

Clears user identification. Call on logout.

## Safety Guarantees

The FeedbackWall SDK is designed with your app's stability as the top priority:

- ✅ **Never crashes** - All errors are caught and logged internally
- ✅ **Never blocks** - Network calls have 2-second timeouts
- ✅ **Opt-in only** - SDK only acts when you explicitly call methods
- ✅ **No swizzling** - No method swizzling or runtime magic
- ✅ **No background timers** - No persistent background processes

If the FeedbackWall backend is unavailable, your app behaves exactly as if the SDK wasn't integrated.

## Requirements

- iOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## License

MIT License - see [LICENSE](LICENSE) for details.

