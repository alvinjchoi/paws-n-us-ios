# Supabase Deep Linking Fix for PawsInUs

## The Issue
Supabase is sending an authorization code (`?code=xxx`) to the callback URL, but the current implementation expects access tokens in the hash fragment (`#access_token=xxx`).

## The Solution (Based on Supabase Docs)

### 1. Update Backend Callback Page

The callback page at `pawsnus.com/auth/callback` needs to handle the authorization code and redirect properly:

```typescript
// pages/auth/callback.tsx
import { useEffect } from 'react';

export default function AuthCallback() {
  useEffect(() => {
    // Get the code from query parameters
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get('code');
    const error = urlParams.get('error');
    
    if (error) {
      // Handle error
      console.error('Auth error:', error);
      return;
    }
    
    if (code) {
      // Redirect to app with the code
      const redirectUrl = `pawsinus://login-callback?code=${code}`;
      window.location.href = redirectUrl;
      
      // Fallback for when app doesn't open
      setTimeout(() => {
        document.getElementById('manual-redirect')?.classList.remove('hidden');
      }, 1000);
    }
  }, []);
  
  return (
    <div>
      <h1>Redirecting to PawsInUs...</h1>
      <div id="manual-redirect" className="hidden">
        <p>App didn't open?</p>
        <button onClick={() => {
          const code = new URLSearchParams(window.location.search).get('code');
          if (code) {
            window.location.href = `pawsinus://login-callback?code=${code}`;
          }
        }}>
          Open App
        </button>
      </div>
    </div>
  );
}
```

### 2. Update iOS App URL Handler

According to Supabase docs, the iOS app needs to handle the code exchange:

```swift
// In App.swift
.onOpenURL { url in
    Task {
        do {
            // Supabase SDK handles the code exchange automatically
            try await SupabaseConfig.client.auth.session(from: url)
        } catch {
            print("Error handling deep link: \(error)")
        }
    }
}
```

### 3. Configure URL Scheme Correctly

Make sure the URL scheme in Xcode is configured as:
- **URL Schemes**: `pawsinus` (not `io.pawsinus`)
- **Identifier**: `com.ricajincom.pawsinus`

### 4. Supabase Configuration

In Supabase Dashboard:
1. Go to Authentication → URL Configuration
2. Add redirect URL: `https://pawsnus.com/auth/callback`
3. Make sure "Implicit flow" is DISABLED (we want the code flow)

## Key Points from Supabase Docs:

1. **PKCE Flow is Default**: Supabase uses PKCE (authorization code) flow by default for security
2. **Code Exchange**: The SDK handles exchanging the code for tokens automatically
3. **Deep Link Format**: Should be `scheme://host?code=xxx` not `scheme://host#access_token=xxx`

## Testing the Flow:

1. Request magic link
2. Click link → Goes to `https://pawsnus.com/auth/callback?code=xxx`
3. Backend redirects to `pawsinus://login-callback?code=xxx`
4. App opens and Supabase SDK exchanges code for session

## Important Notes:

- The `session(from:)` method in Supabase Swift SDK knows how to handle both:
  - Authorization codes (`?code=xxx`)
  - Access tokens (`#access_token=xxx`)
- PKCE flow is more secure than implicit flow
- The backend just needs to pass the code to the app, not process it