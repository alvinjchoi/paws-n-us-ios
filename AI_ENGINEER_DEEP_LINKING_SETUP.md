# Deep Linking Setup Instructions for PawsInUs

## Overview
This document provides comprehensive instructions for setting up deep linking and authentication callbacks for the PawsInUs iOS app using the `pawsnus-backend` repository.

## Prerequisites
- Access to `pawsinus` (iOS app) repository
- Access to `pawsnus-backend` repository
- Xcode 14+ installed
- Vercel account
- Access to Supabase dashboard
- Domain: pawsnus.com

## Architecture Overview
```
User clicks magic link → Supabase verifies → Redirects to pawsnus.com → Backend redirects to app → App handles auth
```

## Step 1: Backend Setup (pawsnus-backend repo)

### 1.1 Clone and Setup Backend
```bash
git clone git@github.com:YOUR_ORG/pawsnus-backend.git
cd pawsnus-backend
npm install
```

### 1.2 Verify Auth Callback Handler
Check that `pages/auth/callback.tsx` exists and contains:
- Logic to extract auth tokens from URL hash
- Redirect to `pawsinus://login-callback#access_token=...`
- Fallback UI for manual copying

### 1.3 Verify Apple App Site Association
Ensure these files exist:
- `public/.well-known/apple-app-site-association`
- `pages/api/apple-app-site-association.ts`

Both should contain:
```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appID": "9DWYL25EC4.com.ricajincom.pawsinus",
      "paths": ["/auth/*", "/auth/callback"]
    }]
  }
}
```

### 1.4 Deploy to Vercel
```bash
vercel --prod
```

### 1.5 Configure Domain
1. In Vercel dashboard → Settings → Domains
2. Add custom domain: `pawsnus.com`
3. Follow DNS configuration instructions
4. Verify domain is active

## Step 2: iOS App Setup (pawsinus repo)

### 2.1 URL Scheme Configuration
1. Open `PawsInUs.xcodeproj` in Xcode
2. Select project → PawsInUs target → Info tab
3. Under URL Types, add:
   - Identifier: `com.ricajincom.pawsinus`
   - URL Schemes: `pawsinus`
   - Role: Editor

### 2.2 Associated Domains (Universal Links)
1. Select project → PawsInUs target → Signing & Capabilities
2. Click "+ Capability" → Add "Associated Domains"
3. Add domain: `applinks:pawsnus.com`

### 2.3 Verify Deep Link Handler
Check `PawsInUs/Core/App.swift` contains:
```swift
.onOpenURL { url in
    Task {
        do {
            try await SupabaseConfig.client.auth.session(from: url)
        } catch {
            print("Error handling deep link: \(error)")
        }
    }
}
```

### 2.4 Update Auth Redirect URL
In `PawsInUs/Interactors/AuthInteractor.swift`, ensure:
```swift
func signInWithOTP(email: String) async throws {
    try await supabaseClient.auth.signInWithOTP(
        email: email,
        redirectTo: URL(string: "https://pawsnus.com/auth/callback")
    )
}
```

## Step 3: Supabase Configuration

### 3.1 Update Redirect URLs
1. Go to Supabase Dashboard
2. Navigate to Authentication → URL Configuration
3. Add to Redirect URLs:
   ```
   https://pawsnus.com/auth/callback
   ```
4. Remove any localhost URLs
5. Save changes

### 3.2 Verify Email Templates
1. Go to Authentication → Email Templates
2. Ensure Magic Link template uses `{{ .ConfirmationURL }}`

## Step 4: Testing Deep Links

### 4.1 Test URL Scheme
```bash
# In simulator or device with app installed
xcrun simctl openurl booted "pawsinus://login-callback#access_token=test"
```

### 4.2 Test Universal Links
1. Deploy backend changes
2. Wait 5-10 minutes for Apple CDN to update
3. Send test magic link email
4. Verify flow:
   - Email link → Opens Safari
   - Safari → Redirects to pawsnus.com
   - pawsnus.com → Opens app

### 4.3 Debug Universal Links
```bash
# On device, check if AASA file is accessible
curl https://pawsnus.com/.well-known/apple-app-site-association

# Check if app recognizes the domain
# Install app on device and check console logs
```

## Step 5: Troubleshooting

### Issue: "Safari cannot open the page"
**Solution**: URL scheme not configured properly in Xcode. Re-check Step 2.1

### Issue: Opens in Safari instead of app
**Solutions**:
1. Associated Domains not configured (Step 2.2)
2. AASA file not accessible (check Vercel deployment)
3. Bundle ID mismatch in AASA file
4. Need to reinstall app after configuration

### Issue: Magic link goes to localhost
**Solution**: Update Supabase redirect URLs (Step 3.1)

### Issue: App opens but auth fails
**Solutions**:
1. Check `onOpenURL` implementation
2. Verify Supabase client configuration
3. Check for auth state handling in AppView

## Step 6: Alternative Implementation (Direct Token)

If deep linking issues persist, implement manual token entry:

### 6.1 In AuthView.swift
- Add text field for pasting magic link URL
- Extract token from URL
- Process with `supabaseClient.auth.session(from: url)`

### 6.2 User Flow
1. User copies magic link from email
2. Pastes in app
3. App extracts token and authenticates

## Maintenance Notes

### Regular Checks
- Verify AASA file accessibility monthly
- Check for iOS/Xcode updates affecting deep links
- Monitor auth success rates

### Updates Required When
- Changing bundle identifier
- Updating team ID
- Changing domain name
- Major iOS updates

## Security Considerations
- Never expose Supabase service keys in frontend
- Validate all incoming URLs
- Implement rate limiting on backend
- Use HTTPS for all redirects

## Contact for Issues
- iOS: Check `pawsinus` repo issues
- Backend: Check `pawsnus-backend` repo issues
- Domain/SSL: Vercel support
- Auth: Supabase support