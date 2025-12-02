//
//  ContentView.swift
//  FeedbackWallDemoApp
//
//  Demo app for the FeedbackWall iOS SDK
//

import SwiftUI
import FeedbackWall

struct ContentView: View {
    @State private var triggerCount = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // Logo / Header
                VStack(spacing: 8) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    
                    Text("FeedbackWall Demo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Test the SDK triggers below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Trigger Buttons
                VStack(spacing: 16) {
                    TriggerButton(
                        title: "Onboarding Completed",
                        subtitle: "Trigger: onboarding_completed",
                        color: .blue
                    ) {
                        FeedbackWall.showIfAvailable(trigger: "onboarding_completed")
                        triggerCount += 1
                    }
                    
                    TriggerButton(
                        title: "Feature Used",
                        subtitle: "Trigger: feature_used",
                        color: .green
                    ) {
                        FeedbackWall.showIfAvailable(trigger: "feature_used")
                        triggerCount += 1
                    }
                    
                    TriggerButton(
                        title: "Purchase Completed",
                        subtitle: "Trigger: purchase_completed",
                        color: .orange
                    ) {
                        FeedbackWall.showIfAvailable(trigger: "purchase_completed")
                        triggerCount += 1
                    }
                    
                    TriggerButton(
                        title: "App Rating",
                        subtitle: "Trigger: app_rating_prompt",
                        color: .purple
                    ) {
                        FeedbackWall.showIfAvailable(trigger: "app_rating_prompt")
                        triggerCount += 1
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Footer info
                VStack(spacing: 4) {
                    Text("Triggers fired: \(triggerCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("SDK Configured: \(FeedbackWall.isConfigured ? "✅" : "❌")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Trigger Button Component

struct TriggerButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(color)
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

