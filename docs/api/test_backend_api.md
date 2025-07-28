# Testing Backend API

## The Problem
Your backend API at `http://127.0.0.1:3000/api/animals` requires authentication via Bearer token in the Authorization header.

## How the iOS App Works
When you use the iOS app to create an animal:

1. You're logged in (user ID: c4d8853e-9384-4f61-9c3a-220c9e0f0d9e)
2. The app gets your auth token from Supabase session
3. The app sends the request with: `Authorization: Bearer YOUR_TOKEN`
4. Your backend verifies the token and creates the animal

## To Test the Full Flow

### Option 1: Use the iOS App (Recommended)
1. Open the app
2. Go to Rescue Mode
3. Tap "새 동물 등록" (Add New Animal)
4. Fill out the form
5. Tap "Publish"
6. The app will call your backend API with proper authentication

### Option 2: Get Your Auth Token
If you want to test with curl, you need your auth token. In the iOS app, you can add this debug code to print your token:

```swift
if let token = try? await SupabaseConfig.client.auth.session.accessToken {
    print("Your auth token: \(token)")
}
```

Then use it in curl:
```bash
curl -X POST http://127.0.0.1:3000/api/animals \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{...}'
```

## What Happens in Your Backend

Your backend (`/api/animals/route.ts`):
1. Receives the request
2. Validates the auth token with Supabase
3. Creates the animal in Supabase
4. Uploads images to Supabase Storage
5. Creates a Sanity document
6. Returns success response

The backend is the only place that should interact with Supabase directly!