# Security Configuration Setup

This document explains how to properly configure API keys and sensitive values for the PawsInUs iOS app.

## Overview

To improve security and avoid hardcoding sensitive information in source code, this app uses Info.plist configuration for API keys and other sensitive values.

## Setup Instructions

### 1. Create Your Configuration File

1. Copy the example configuration file:
   ```bash
   cp PawsInUs/Resources/Config-Example.plist PawsInUs/Resources/Config.plist
   ```

2. Edit `PawsInUs/Resources/Config.plist` with your actual values:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>SUPABASE_URL</key>
       <string>https://your-project.supabase.co</string>
       <key>SUPABASE_ANON_KEY</key>
       <string>your-supabase-anon-key</string>
       <key>SANITY_PROJECT_ID</key>
       <string>your-sanity-project-id</string>
       <key>SANITY_DATASET</key>
       <string>production</string>
   </dict>
   </plist>
   ```

### 2. Add Configuration to Xcode Project

1. Open `PawsInUs.xcodeproj` in Xcode
2. Right-click on the `PawsInUs/Resources` group
3. Select "Add Files to 'PawsInUs'"
4. Navigate to and select your `Config.plist` file
5. Make sure "Add to target: PawsInUs" is checked

### 3. Update Info.plist (Alternative Method)

Alternatively, you can add the configuration values directly to your main `Info.plist`:

1. Open `Info.plist` in Xcode
2. Add the following keys and values:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anonymous key
   - `SANITY_PROJECT_ID`: Your Sanity project ID
   - `SANITY_DATASET`: Your Sanity dataset (usually "production")

## Configuration Keys

| Key | Description | Required |
|-----|-------------|----------|
| `SUPABASE_URL` | Your Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous/public key | Yes |
| `SANITY_PROJECT_ID` | Your Sanity.io project ID | Yes |
| `SANITY_DATASET` | Your Sanity dataset name | Yes |

## Development Fallbacks

For development convenience, the app includes fallback values when configuration is missing. These fallbacks:

- Only work in DEBUG builds
- Print warnings to the console
- Use hardcoded values as a last resort

**Important**: These fallbacks will cause the app to crash in RELEASE builds if configuration is missing.

## Security Best Practices

### DO:
✅ Keep `Config.plist` in `.gitignore`  
✅ Use environment-specific configuration files  
✅ Share configuration securely with team members  
✅ Rotate API keys regularly  

### DON'T:
❌ Commit actual API keys to version control  
❌ Share keys in chat or email  
❌ Use production keys in development  
❌ Hardcode sensitive values in source code  

## CI/CD Configuration

For automated builds, you can inject configuration values at build time:

### Xcode Cloud / GitHub Actions
```yaml
- name: Create Config
  run: |
    cat > PawsInUs/Resources/Config.plist << EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>SUPABASE_URL</key>
        <string>\${{ secrets.SUPABASE_URL }}</string>
        <key>SUPABASE_ANON_KEY</key>
        <string>\${{ secrets.SUPABASE_ANON_KEY }}</string>
        <key>SANITY_PROJECT_ID</key>
        <string>\${{ secrets.SANITY_PROJECT_ID }}</string>
        <key>SANITY_DATASET</key>
        <string>\${{ secrets.SANITY_DATASET }}</string>
    </dict>
    </plist>
    EOF
```

## Troubleshooting

### App crashes with "Missing [KEY] in Info.plist"
- Ensure you've created and added the `Config.plist` file to your Xcode project
- Verify all required keys are present in your configuration
- Check that the file is included in your app target

### Configuration not loading
- Verify the plist file is properly formatted XML
- Ensure the file is added to the Xcode project target
- Check console output for configuration warnings

### Values not updating
- Clean build folder (⌘+Shift+K)
- Delete derived data
- Restart Xcode

## Getting Your API Keys

### Supabase
1. Go to [supabase.com](https://supabase.com)
2. Open your project dashboard
3. Go to Settings → API
4. Copy the "Project URL" and "anon public" key

### Sanity
1. Go to [sanity.io](https://sanity.io)
2. Open your project dashboard
3. Go to Settings → API
4. Find your Project ID and Dataset name