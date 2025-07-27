# Complete URL Scheme Configuration Guide for PawsInUs

## Step 1: Configure URL Scheme in Xcode

### Method A: Using Xcode UI (Recommended)

1. **Open your project in Xcode**
   ```bash
   cd /Users/crave/GitHub/pawsinus
   open PawsInUs.xcodeproj
   ```

2. **Select your project file** (blue icon at the top of the file navigator)

3. **Select the "PawsInUs" target** (not the project)

4. **Go to the "Info" tab**

5. **Find "URL Types" section** (you might need to expand it)
   - If it exists with `io.pawsinus`, delete it by clicking the minus (-) button

6. **Add a new URL Type** by clicking the plus (+) button:
   - **Identifier**: `com.ricajincom.pawsinus`
   - **URL Schemes**: `pawsinus` (JUST `pawsinus`, not `io.pawsinus`)
   - **Role**: Editor (default)
   - **Icon**: (leave empty)

### Method B: Manual Info.plist Edit

If the UI method doesn't work, you can manually edit the Info.plist:

1. Find your Info.plist file in Xcode
2. Right-click and select "Open As" → "Source Code"
3. Add this before the closing `</dict>`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>pawsinus</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.ricajincom.pawsinus</string>
    </dict>
</array>
```

## Step 2: Clean and Rebuild

1. **Clean Build Folder**
   - Menu: Product → Clean Build Folder (⇧⌘K)
   
2. **Delete Derived Data** (if needed)
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/PawsInUs-*
   ```

3. **Build and Run** (⌘R)

## Step 3: Configure Supabase

1. **Go to Supabase Dashboard**
   - https://app.supabase.com

2. **Navigate to Authentication → URL Configuration**

3. **Add these Redirect URLs**:
   ```
   pawsinus://login-callback
   https://pawsnus.com/auth/callback
   ```

4. **Remove any localhost URLs**

5. **Save changes**

## Step 4: Test URL Scheme

### Test 1: Direct URL Test
1. With app installed on simulator/device
2. Open Safari on the simulator/device
3. Type in address bar: `pawsinus://test`
4. Press Enter
5. You should see "Open in PawsInUs?" prompt

### Test 2: Test with Parameters
1. In Safari, type: `pawsinus://login-callback?test=123`
2. The app should open

### Test 3: Terminal Test (Simulator only)
```bash
xcrun simctl openurl booted "pawsinus://login-callback?test=123"
```

## Step 5: Verify Configuration

Run this command to check if URL scheme is in the built app:
```bash
# Build first
xcodebuild -scheme PawsInUs -sdk iphonesimulator build

# Then check Info.plist in build
plutil -p ~/Library/Developer/Xcode/DerivedData/PawsInUs-*/Build/Products/Debug-iphonesimulator/PawsInUs.app/Info.plist | grep -A 5 CFBundleURLTypes
```

You should see:
```
"CFBundleURLTypes" => [
  {
    "CFBundleURLSchemes" => [
      "pawsinus"
    ]
  }
]
```

## Step 6: Troubleshooting

### Issue: "Safari cannot open the page"
- URL scheme not properly configured
- App not installed
- Wrong URL scheme (using `io.pawsinus` instead of `pawsinus`)

### Issue: App doesn't appear in "Open with" dialog
- Clean build folder and rebuild
- Restart simulator
- Make sure Info.plist changes are saved

### Issue: Still using io.pawsinus
Check project.pbxproj:
```bash
grep -n "io\.pawsinus" /Users/crave/GitHub/pawsinus/PawsInUs.xcodeproj/project.pbxproj
```

If found, you need to change it in Xcode UI, not by editing the file.

## Step 7: Test Authentication Flow

1. **Send magic link**
2. **Check email** - link should be:
   ```
   https://[supabase].supabase.co/auth/v1/verify?token=XXX&redirect_to=pawsinus://login-callback
   ```
3. **Click link**
4. **App should open** and complete authentication

## Common Mistakes to Avoid

1. ❌ Using `io.pawsinus://` instead of `pawsinus://`
2. ❌ Not cleaning build folder after changes
3. ❌ Having multiple URL types defined
4. ❌ Forgetting to save Supabase redirect URLs
5. ❌ Testing on device where app isn't installed

## Final Checklist

- [ ] URL Scheme is `pawsinus` (not `io.pawsinus`)
- [ ] Identifier is set (can be any unique string)
- [ ] Supabase has `pawsinus://login-callback` in redirect URLs
- [ ] App builds without errors
- [ ] `pawsinus://test` opens app from Safari
- [ ] Magic link redirects to `pawsinus://login-callback`