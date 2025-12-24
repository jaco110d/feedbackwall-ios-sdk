# FeedbackWall iOS SDK - Test Guide

## Running Tests

Due to UIKit dependencies, tests must be run in Xcode or on an iOS Simulator.

### Option 1: Xcode (Recommended)

1. Open the package in Xcode:
   ```bash
   open Package.swift
   ```

2. Select an iOS Simulator destination (e.g., iPhone 15 Pro)

3. Press `Cmd + U` to run all tests

### Option 2: Command Line (with workaround)

If you have Xcode 16.3 issues, try:
```bash
# Create a test host project or use xcodebuild with an existing project
```

## Test Coverage

The test suite covers:

### 1. JSON Parsing Tests
- Survey decoding (minimal and full)
- Theme decoding (all fields, partial, empty)
- Question types (multiple_choice, rating, text)
- TriggerCheckResponse parsing

### 2. Theme Color Tests
- Hex color conversion (6-digit, 8-digit)
- Invalid hex handling
- Color resolver fallbacks

### 3. Font Family Tests
- System, rounded, serif, mono, casual
- Unknown font fallback
- Font size validation

### 4. Layout Resolver Tests
- Popup vs fullscreen layout
- Content padding
- Text alignment

### 5. Corner Radius Tests
- Card corner radius (with fullscreen override)
- Button corner radius
- Clamping to valid ranges

### 6. Display Settings Tests
- Delay seconds
- Close button visibility
- Entrance animations
- Animation speeds

### 7. Integration Tests
- Ping endpoint
- Trigger check with valid/invalid triggers
- User identification
- Network error handling

### 8. Edge Cases
- Nil theme defaults
- Empty questions array
- Negative/zero font sizes
- Invalid values

## Manual API Testing

You can manually test the API endpoints (replace `YOUR_API_KEY` with your actual key):

```bash
# Test Ping
curl -X POST https://feedbackwall.io/api/sdk/ping \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"platform": "iOS 17.0", "appVersion": "1.0.0", "deviceLocale": "da_DK", "sdkVersion": "1.0.0"}'

# Test Trigger Check
curl -X POST https://feedbackwall.io/api/sdk/triggers/check \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"trigger": "onboarding_completed", "userId": "user_123", "appVersion": "1.0.0", "platform": "iOS", "deviceLocale": "da_DK"}'
```
