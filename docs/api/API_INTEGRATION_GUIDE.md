# API Integration Guide for PawsInUs

## Overview
The PawsInUs iOS app is now configured to use your local backend API at `http://127.0.0.1:3000` for animal management operations.

## Setup

### 1. Start the Backend Server
```bash
cd /Users/crave/GitHub/paws-n-us-backend
npm run dev
```

The server will start at http://localhost:3000

### 2. Environment Variables
Make sure your backend has the following environment variables configured:
- `NEXT_PUBLIC_SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

## API Integration Features

### Animal Creation Flow
1. User fills out the animal registration form in the iOS app
2. When user taps "Publish", the app:
   - Converts images to base64
   - Sends POST request to `/api/animals`
   - Backend creates records in both Supabase and Sanity
   - Returns the created animal ID

### Data Flow
```
iOS App → Local API (port 3000) → Supabase Database
                                → Sanity CMS
```

## API Endpoints

### POST /api/animals
Creates a new rescue animal.

**Request Body:**
```json
{
  "name": "Dog Name",
  "species": "dog",
  "breed": "Mixed Breed",
  "age": 24,  // in months
  "gender": "male",
  "size": "medium",
  "bio": "Description",
  "traits": ["friendly", "playful"],
  "energy_level": "medium",
  "good_with_kids": true,
  "good_with_pets": true,
  "house_trained": false,
  "location": "Seoul",
  "special_needs": "Optional special needs",
  "is_spayed_neutered": false,
  "medical_status": "healthy",
  "medical_notes": "Optional medical notes",
  "vaccinations": "completed",
  "weight": 6.3,
  "adoption_fee": 50000,
  "rescue_date": "2025-07-28",
  "rescue_location": "Seoul",
  "rescue_story": "Found abandoned...",
  "image_data": ["base64_encoded_image_1", "base64_encoded_image_2"],
  "help_needed": ["transport", "grooming", "temporary_care"],
  "rescuer_id": "optional_rescuer_id"
}
```

**Response:**
```json
{
  "success": true,
  "animal": {
    "id": "generated-uuid",
    "name": "Dog Name",
    "species": "dog",
    "imageUrls": ["https://..."],
    "helpNeeded": ["transport", "grooming"],
    "message": "Animal successfully added to rescue database!"
  }
}
```

### GET /api/animals
Retrieves list of animals.

**Query Parameters:**
- `rescuer_id` (optional): Filter by rescuer
- `species` (optional): Filter by species
- `limit` (default: 20): Number of results
- `offset` (default: 0): Pagination offset

## iOS App Components

### LocalAPIClient
Located at: `/PawsInUs/Networking/LocalAPIClient.swift`

This is the main client for communicating with your backend API.

### APIIntegrationStatus
Located at: `/PawsInUs/UI/Components/APIIntegrationStatus.swift`

Shows real-time status of the API connection in the app.

## Verification

### Check Backend Status
The app displays an API status indicator in the Rescue Mode that shows:
- ✅ Green checkmark if backend is running
- ❌ Red X if backend is not accessible
- Last created animal ID

### Test Script
Run the test script to verify integration:
```bash
./Scripts/test_api_integration.sh
```

### Manual Testing
1. Open the iOS app
2. Switch to Rescue Mode
3. Tap "새 동물 등록" (Add New Animal)
4. Fill out the form with:
   - Basic info (name, species, age)
   - Upload at least one photo
   - Add bio/description
   - Set health status
   - Select location
   - Choose help types needed
5. Tap "Publish"
6. Check console logs for success message
7. Verify in Supabase dashboard

## Troubleshooting

### Backend Not Running
Error: "Backend server not running"
Solution: Start the backend server with `npm run dev`

### Unauthorized Error
Error: "Unauthorized"
Solution: The backend requires authentication. Make sure you're logged in through the app.

### Network Error
Error: "Could not connect to server"
Solution: 
1. Check backend is running on port 3000
2. For iOS Simulator, use 127.0.0.1 instead of localhost
3. For physical device, use your machine's IP address

### Image Upload Issues
- Images are converted to base64 before sending
- Maximum recommended image size: 2MB per image
- Supported formats: JPEG, PNG

## Database Schema
The animals are stored in the `dogs` table with the following key fields:
- `id`: UUID
- `name`: String
- `breed`: String
- `age`: Integer (months)
- `size`: String (small/medium/large)
- `gender`: String (male/female)
- `image_urls`: Array of URLs
- `medical_status`: String
- `weight`: Double (kg)
- `is_spayed_neutered`: Boolean
- `rescuer_id`: UUID (links to rescuer)
- `created_at`: Timestamp
- `updated_at`: Timestamp

## Health Information Display
The app displays health information in the format requested:
- 종합 백신 / 코로나 백신 접종 ✓
- 지알디아 음성 ✓
- 몸무게 X.Xkg(25년 7월 기준)
- 입소일 : 25년 7월 3일 기준(3개월령)

## Next Steps
1. Add authentication token handling for secured endpoints
2. Implement image optimization before upload
3. Add offline support with local caching
4. Implement real-time updates using Supabase subscriptions