-- Pawsinus Database Setup Script
-- Run this in your Supabase SQL editor to set up the database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE dog_size AS ENUM ('small', 'medium', 'large', 'extraLarge');
CREATE TYPE dog_gender AS ENUM ('male', 'female');
CREATE TYPE energy_level AS ENUM ('low', 'medium', 'high', 'veryHigh');
CREATE TYPE match_status AS ENUM ('matched', 'chatting', 'meetingScheduled', 'adopted', 'cancelled');

-- Create shelters table
CREATE TABLE shelters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    website TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create dogs table
CREATE TABLE dogs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    breed TEXT NOT NULL,
    age INTEGER NOT NULL,
    size dog_size NOT NULL,
    gender dog_gender NOT NULL,
    image_urls TEXT[] DEFAULT '{}' NOT NULL,
    bio TEXT,
    shelter_id UUID REFERENCES shelters(id) ON DELETE CASCADE,
    shelter_name TEXT NOT NULL,
    location TEXT NOT NULL,
    traits TEXT[] DEFAULT '{}' NOT NULL,
    energy_level energy_level NOT NULL,
    good_with_kids BOOLEAN DEFAULT false,
    good_with_pets BOOLEAN DEFAULT false,
    date_added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create adopters table (linked to Supabase Auth)
CREATE TABLE adopters (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    location TEXT DEFAULT '',
    bio TEXT DEFAULT '',
    profile_image_url TEXT,
    preferences JSONB DEFAULT '{
        "preferredSizes": ["small", "medium", "large", "extraLarge"],
        "preferredAgeRange": {"min": 0, "max": 20},
        "preferredEnergyLevels": ["low", "medium", "high", "veryHigh"],
        "hasKids": false,
        "hasOtherPets": false,
        "maxDistance": 50.0
    }'::jsonb,
    liked_dog_ids TEXT[] DEFAULT '{}',
    disliked_dog_ids TEXT[] DEFAULT '{}',
    matched_dog_ids TEXT[] DEFAULT '{}',
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create matches table
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dog_id UUID REFERENCES dogs(id) ON DELETE CASCADE,
    adopter_id UUID REFERENCES adopters(id) ON DELETE CASCADE,
    shelter_id UUID REFERENCES shelters(id) ON DELETE CASCADE,
    match_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status match_status DEFAULT 'matched',
    conversation JSONB DEFAULT '{"messages": []}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(dog_id, adopter_id)
);

-- Create indexes for better performance
CREATE INDEX idx_dogs_shelter_id ON dogs(shelter_id);
CREATE INDEX idx_dogs_location ON dogs(location);
CREATE INDEX idx_adopters_email ON adopters(email);
CREATE INDEX idx_matches_adopter_id ON matches(adopter_id);
CREATE INDEX idx_matches_dog_id ON matches(dog_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_dogs_updated_at BEFORE UPDATE ON dogs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_adopters_updated_at BEFORE UPDATE ON adopters
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security
ALTER TABLE adopters ENABLE ROW LEVEL SECURITY;
ALTER TABLE dogs ENABLE ROW LEVEL SECURITY;
ALTER TABLE shelters ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- RLS Policies for adopters
CREATE POLICY "Users can view own profile" ON adopters
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON adopters
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON adopters
    FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for dogs (public read)
CREATE POLICY "Anyone can view dogs" ON dogs
    FOR SELECT USING (true);

-- RLS Policies for shelters (public read)
CREATE POLICY "Anyone can view shelters" ON shelters
    FOR SELECT USING (true);

-- RLS Policies for matches
CREATE POLICY "Users can view own matches" ON matches
    FOR SELECT USING (auth.uid() = adopter_id);

CREATE POLICY "Users can create matches" ON matches
    FOR INSERT WITH CHECK (auth.uid() = adopter_id);

CREATE POLICY "Users can update own matches" ON matches
    FOR UPDATE USING (auth.uid() = adopter_id);

-- Function to handle user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO adopters (id, email, name)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1))
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create adopter profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;