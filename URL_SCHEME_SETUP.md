# URL Scheme Setup for PawsInUs

To enable magic link authentication, you need to configure the URL scheme in Xcode.

## Current Issue
The magic link redirects to `io.pawsinus://login-callback` which Safari cannot open directly from a web page due to security restrictions.

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

## Workaround for Safari Redirect Issue:

Since Safari blocks custom URL scheme redirects from web pages, the app now includes a manual option:

1. Click the magic link in your email
2. When Safari shows "Safari cannot open the page", copy the entire URL from the address bar
3. Go back to the app
4. Paste the URL in the text field that appears after sending the email
5. Click "로그인" to complete authentication

## Alternative Solutions:

1. **Use Universal Links**: Configure your domain to support Universal Links (requires a web server)
2. **Use a Web Redirect Page**: Host a simple web page that redirects to your app
3. **Copy Just the Token**: Extract the token parameter from the URL and implement token-based verification

## Testing:

1. When you receive the magic link email, copy the entire URL
2. Paste it in the app's magic link URL field
3. The app will extract the token and complete authentication