# Supabase Database Setup

## Quick Setup

1. Go to your Supabase project dashboard
2. Navigate to the SQL Editor
3. Run the migration files in order:
   - `001_create_profiles_table.sql`
   - `002_create_dogs_and_related_tables.sql`
   - `003_insert_sample_dogs.sql`

## Migration Files

### 1. Profiles Table (`001_create_profiles_table.sql`)
- Creates the `profiles` table for user profiles
- Sets up Row Level Security (RLS) policies
- Creates automatic profile creation trigger for new users

### 2. Dogs and Related Tables (`002_create_dogs_and_related_tables.sql`)
- Creates tables: `dogs`, `likes`, `dislikes`, `matches`
- Sets up appropriate RLS policies
- Ensures data integrity with foreign key constraints

### 3. Sample Data (`003_insert_sample_dogs.sql`)
- Inserts 8 sample dogs with Korean locations
- Includes various breeds, sizes, and personalities

## Manual Setup Steps

If you prefer to run the SQL manually:

1. Open Supabase SQL Editor
2. Copy and paste each migration file's content
3. Run them in order (001, 002, 003)

## Verify Setup

After running the migrations, verify:
1. Tables exist: `profiles`, `dogs`, `likes`, `dislikes`, `matches`
2. Sample dogs are visible in the `dogs` table
3. RLS is enabled on all tables

## Troubleshooting

If you get "relation already exists" errors:
- The tables might already exist
- You can drop and recreate them with: `DROP TABLE IF EXISTS table_name CASCADE;`

If authentication isn't working:
- Ensure your auth providers are configured in Supabase Authentication settings
- Check that the URL configuration matches your app's URL scheme