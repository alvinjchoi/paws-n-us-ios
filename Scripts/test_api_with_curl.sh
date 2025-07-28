#!/bin/bash

echo "Testing Animal Creation API..."

# Create a small test image (1x1 pixel red PNG)
# This is a base64 encoded 1x1 red pixel PNG
TEST_IMAGE="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="

# Your auth token - you'll need to replace this with your actual token
# To get your token, you can add this to your iOS app:
# print("Auth token: \(try? await SupabaseConfig.client.auth.session.accessToken)")
AUTH_TOKEN="YOUR_AUTH_TOKEN_HERE"

# Create the request
curl -X POST http://127.0.0.1:3000/api/animals \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{
    "name": "Test Puppy",
    "species": "dog",
    "breed": "Golden Retriever",
    "age": 6,
    "gender": "female",
    "size": "medium",
    "bio": "A sweet test puppy created via API",
    "traits": ["friendly", "playful", "energetic"],
    "energy_level": "high",
    "good_with_kids": true,
    "good_with_pets": true,
    "house_trained": false,
    "location": "Seoul, Gangnam",
    "special_needs": "",
    "is_spayed_neutered": false,
    "medical_status": "healthy",
    "medical_notes": "All vaccinations up to date",
    "vaccinations": "DHPP, Rabies",
    "weight": 15.5,
    "adoption_fee": 100000,
    "rescue_date": "2025-01-20",
    "rescue_location": "Gangnam Park",
    "rescue_story": "Found alone in the park, very friendly",
    "image_data": ["'$TEST_IMAGE'"],
    "help_needed": ["Transport", "Temporary Care"],
    "rescuer_id": "9b1195b6-5eeb-43b2-8977-2e741bd9afed"
  }' | jq '.'

echo -e "\n\nNow checking if the animal was created..."
sleep 2

# Get the latest animal
curl -s http://127.0.0.1:3000/api/animals?limit=1 | jq '.'