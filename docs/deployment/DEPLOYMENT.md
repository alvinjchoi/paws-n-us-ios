# Pawsinus Deployment Guide

## Prerequisites

- Apple Developer Account
- Xcode 15+
- Supabase Project
- iOS 18.0+ target device

## 1. Supabase Setup

1. Create a new Supabase project at https://supabase.com
2. Run the SQL script in `docs/sql/setup_database.sql`
3. Update `PawsInUs/DependencyInjection/SupabaseConfig.swift` with your project credentials:
   ```swift
   static let url = URL(string: "YOUR_SUPABASE_URL")!
   static let anonKey = "YOUR_ANON_KEY"
   ```

## 2. Configure Xcode Project

1. Open `PawsInUs.xcodeproj`
2. Select the PawsInUs target
3. Update Signing & Capabilities:
   - Team: Select your Apple Developer Team
   - Bundle Identifier: Update if needed (current: `com.ricainc.pawsinus`)
   - Add Push Notifications capability

## 3. TestFlight Deployment

### Build & Archive
1. Select "Any iOS Device (arm64)" as the destination
2. Product → Archive
3. Wait for the archive to complete

### Upload to App Store Connect
1. In the Organizer window, select your archive
2. Click "Distribute App"
3. Choose "App Store Connect" → Next
4. Select "Upload" → Next
5. Follow the prompts to upload

### Configure in App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Select your app
3. Go to TestFlight tab
4. Once processing is complete:
   - Add internal testers (App Store Connect Users)
   - Create external testing group
   - Add test information
   - Submit for Beta App Review (if using external testers)

## 4. Required Information

### App Information
- **Name**: Pawsinus
- **Category**: Social Networking
- **Age Rating**: 4+ (no objectionable content)

### Privacy URLs
Update these URLs in the project settings when you have them:
- Privacy Policy: https://pawsinus.com/privacy-policy
- Terms of Service: https://pawsinus.com/terms-of-service

### Test Information
Provide clear testing instructions for TestFlight reviewers:
- How to sign up/sign in
- Key features to test (swiping, liking, profile)
- Any known limitations in beta

## 5. Common Issues

### Build Errors
- Ensure all Swift packages are resolved: File → Packages → Resolve Package Versions
- Clean build folder: Product → Clean Build Folder (⇧⌘K)

### Supabase Connection
- Verify your Supabase URL and anon key are correct
- Check that RLS policies are properly set up
- Ensure the database schema matches the app models

### TestFlight Processing
- Processing usually takes 5-30 minutes
- Check email for any issues reported by App Store Connect
- Ensure all required app information is filled out

## 6. Post-Deployment

1. Monitor crash reports in App Store Connect
2. Gather feedback from TestFlight testers
3. Address any critical issues before public release
4. Plan for App Store submission after successful beta testing