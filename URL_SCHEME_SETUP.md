# URL Scheme Setup for PawsInUs

To enable magic link authentication, you need to configure the URL scheme in Xcode:

## Steps to Configure:

1. **Open your project in Xcode**

2. **Select your app target** → Go to the **Info** tab

3. **Add URL Type**:
   - Click the "+" button under "URL Types"
   - Set **Identifier**: `io.pawsinus`
   - Set **URL Schemes**: `io.pawsinus`
   - Leave **Role** as "Editor"

4. **Update Supabase Dashboard**:
   - Go to your Supabase project dashboard
   - Navigate to **Authentication** → **URL Configuration**
   - Add `io.pawsinus://login-callback` to the **Redirect URLs** list
   - Make sure to remove `localhost:3000` if it's there

5. **Important**: The redirect URL in your code (`io.pawsinus://login-callback`) must match exactly what's configured in both Xcode and Supabase.

## Testing:

1. When you receive the magic link email, it should redirect to `io.pawsinus://login-callback?token=...` instead of `localhost:3000`
2. Your app will automatically handle the callback and complete the authentication

## Troubleshooting:

- If the link still goes to localhost:3000, double-check the Supabase redirect URL configuration
- Make sure the URL scheme in Xcode matches exactly (case-sensitive)
- For simulator testing, you may need to copy the link and open it in Safari on the simulator