# Supabase Authentication Setup for PawsInUs iOS App

## Overview
This guide explains how to properly configure Supabase authentication for the PawsInUs iOS app, including deep linking setup.

## Step 1: Configure URL Scheme in Xcode

1. Open your project in Xcode
2. Select your app target (PawsInUs)
3. Go to the **Info** tab
4. Under **URL Types**, click the "+" button
5. Add the following:
   - **Identifier**: `io.pawsinus`
   - **URL Schemes**: `pawsinus` (without the `io.` prefix)
   - **Role**: Editor

## Step 2: Configure Supabase Dashboard

1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Navigate to **Authentication** → **URL Configuration**
3. Add the following to **Redirect URLs**:
   ```
   pawsinus://login-callback
   ```
4. Make sure to **Save** the changes

## Step 3: Update Email Templates (Optional)

If you want to customize the magic link email:

1. Go to **Authentication** → **Email Templates**
2. Select **Magic Link**
3. You can customize the template but ensure the link uses `{{ .ConfirmationURL }}`

## Step 4: How It Works

1. User enters email in the app
2. Supabase sends a magic link to: `https://jxhtbzipglekixpogclo.supabase.co/auth/v1/verify?token=...&redirect_to=pawsinus://login-callback`
3. User clicks the link in their email
4. Supabase verifies the token and redirects to: `pawsinus://login-callback?access_token=...`
5. iOS opens the app and completes authentication

## Current Implementation

The app includes a workaround for when URL schemes aren't configured:
- Users can copy the magic link URL from Safari
- Paste it in the app's text field
- The app extracts the token and completes authentication

## Troubleshooting

### "Safari cannot open the page"
This happens when:
1. The URL scheme isn't configured in Xcode
2. The redirect URL in Supabase doesn't match the URL scheme

### Magic link goes to localhost:3000
This means the redirect URL isn't properly configured in Supabase. Check the URL Configuration settings.

### App doesn't open after clicking link
Ensure:
1. URL scheme is exactly `pawsinus` (not `io.pawsinus`)
2. The app is installed on the device/simulator
3. You're testing on a real device or simulator (not just Xcode preview)

## Testing Tips

1. For simulator testing:
   - Send the magic link
   - Click it in the email
   - If Safari can't open it, copy the URL
   - Open Safari in the simulator
   - Paste the URL but change the domain part to just `pawsinus://login-callback?...`

2. For device testing:
   - URL schemes work more reliably on real devices
   - Make sure the app is installed before clicking the magic link