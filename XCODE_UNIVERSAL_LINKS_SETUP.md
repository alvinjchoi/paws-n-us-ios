# Setting Up Universal Links in Xcode

## Steps to Configure Universal Links for pawsnus.com

### 1. Add Associated Domains Capability

1. Open your project in Xcode
2. Select your project file → Select "PawsInUs" target
3. Go to **Signing & Capabilities** tab
4. Click **"+ Capability"** button
5. Search for and add **"Associated Domains"**

### 2. Configure Associated Domains

1. In the Associated Domains section, click **"+"** to add a domain
2. Add: `applinks:pawsnus.com`
3. Make sure there are no spaces or extra characters

### 3. Update Info.plist (if needed)

The Associated Domains capability should automatically update your entitlements, but verify:

1. Look for `PawsInUs.entitlements` file in your project
2. It should contain:
```xml
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:pawsnus.com</string>
</array>
```

### 4. Verify Bundle Identifier

Make sure your bundle identifier matches what's in the apple-app-site-association file:
- Bundle ID: `com.ricajincom.pawsinus`
- Team ID: `9DWYL25EC4`

### 5. Test Universal Links

1. Deploy the Vercel app first
2. Send a magic link email
3. The link should be: `https://pawsnus.com/auth/callback#access_token=...`
4. When clicked, it should open your iOS app directly

### Troubleshooting

- **App doesn't open**: Check that the app is installed on the device
- **Opens in Safari**: Make sure Associated Domains is properly configured
- **"Cannot open" error**: Verify the domain is correctly spelled in Xcode

### Important Notes

- Universal Links only work on real devices or simulator with proper setup
- The app must be installed before clicking the link
- First-time setup may take a few minutes for Apple to recognize the association