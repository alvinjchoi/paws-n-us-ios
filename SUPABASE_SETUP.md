# Supabase Setup Guide

## Overview
This project is now configured to use Supabase as the backend database. Follow these steps to complete the setup.

## Prerequisites
- A Supabase account (create one at https://supabase.com)
- Xcode with the project open

## Setup Steps

### 1. Create a Supabase Project
1. Go to https://supabase.com and sign in
2. Create a new project
3. Note down your project URL and anon key

### 2. Configure the Database Schema
1. In your Supabase dashboard, go to the SQL Editor
2. Copy the entire contents of `supabase_schema.sql` 
3. Paste and run it in the SQL Editor
4. This will create all necessary tables, indexes, and security policies

### 3. Update Configuration
1. Open `CountriesSwiftUI/DependencyInjection/SupabaseConfig.swift`
2. Replace the placeholder values:
   - `YOUR_SUPABASE_PROJECT_URL` with your project URL
   - `YOUR_SUPABASE_ANON_KEY` with your anon key

### 4. Enable Authentication
1. In Supabase dashboard, go to Authentication > Providers
2. Enable Email authentication
3. Configure any additional auth providers as needed

### 5. Test the Setup
1. Build and run the project
2. Try creating a new account through the app
3. Verify data is being stored in Supabase

## Database Schema

The database includes the following tables:

- **adopters**: User profiles with preferences
- **dogs**: Available dogs for adoption
- **shelters**: Animal shelters
- **likes**: User likes/swipes on dogs
- **matches**: Successful matches between adopters and dogs
- **messages**: Chat messages within matches

## Security

Row Level Security (RLS) is enabled on all tables with appropriate policies:
- Users can only view/edit their own data
- Dogs are publicly viewable
- Messages are restricted to match participants

## Troubleshooting

### Authentication Errors
- Verify your Supabase URL and anon key are correct
- Check that email authentication is enabled in Supabase

### Database Errors
- Ensure all tables were created successfully
- Check the Supabase logs for any SQL errors
- Verify RLS policies aren't blocking operations

### Build Errors
- Clean build folder (Cmd+Shift+K)
- Reset package caches: File > Packages > Reset Package Caches
- Ensure Swift Package Manager has downloaded all dependencies