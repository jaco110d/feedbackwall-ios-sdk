//
//  FeedbackWallDemoAppApp.swift
//  FeedbackWallDemoApp
//
//  Demo app for the FeedbackWall iOS SDK
//

import SwiftUI
import FeedbackWall

@main
struct FeedbackWallDemoAppApp: App {
    
    init() {
        // Configure FeedbackWall SDK at app launch
        // Replace <REPLIT_BACKEND_URL> with your actual backend URL
        FeedbackWall.configure(
            apiKey: "FW_TEST_123",
            baseURL: URL(string: "https://<REPLIT_BACKEND_URL>")!
        )
        
        // Optionally identify the user (can be called later after login)
        FeedbackWall.identify(
            userId: "demo_user_123",
            traits: ["plan": "free", "demo": "true"]
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

