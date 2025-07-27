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
    image_urls TEXT[] DEFAULT '{}',
    bio TEXT,
    shelter_id UUID REFERENCES shelters(id) ON DELETE CASCADE,
    location TEXT NOT NULL,
    traits TEXT[] DEFAULT '{}',
    energy_level energy_level NOT NULL,
    good_with_kids BOOLEAN DEFAULT false,
    good_with_pets BOOLEAN DEFAULT false,
    house_trained BOOLEAN DEFAULT false,
    special_needs TEXT,
    adoption_fee DECIMAL(10, 2),
    available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create adopters table
CREATE TABLE adopters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    location TEXT,
    bio TEXT,
    preferences JSONB DEFAULT '{
        "preferredSizes": [],
        "preferredAgeRange": [0, 20],
        "preferredEnergyLevels": [],
        "hasKids": false,
        "hasOtherPets": false,
        "maxDistance": 50
    }',
    liked_dog_ids UUID[] DEFAULT '{}',
    disliked_dog_ids UUID[] DEFAULT '{}',
    matched_dog_ids UUID[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create likes table
CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    adopter_id UUID REFERENCES adopters(id) ON DELETE CASCADE,
    dog_id UUID REFERENCES dogs(id) ON DELETE CASCADE,
    liked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(adopter_id, dog_id)
);

-- Create matches table
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dog_id UUID REFERENCES dogs(id) ON DELETE CASCADE,
    adopter_id UUID REFERENCES adopters(id) ON DELETE CASCADE,
    shelter_id UUID REFERENCES shelters(id) ON DELETE CASCADE,
    match_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status match_status DEFAULT 'matched',
    last_message_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(dog_id, adopter_id)
);

-- Create messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read BOOLEAN DEFAULT false
);

-- Create indexes for better performance
CREATE INDEX idx_dogs_shelter_id ON dogs(shelter_id);
CREATE INDEX idx_dogs_available ON dogs(available);
CREATE INDEX idx_likes_adopter_id ON likes(adopter_id);
CREATE INDEX idx_likes_dog_id ON likes(dog_id);
CREATE INDEX idx_matches_adopter_id ON matches(adopter_id);
CREATE INDEX idx_matches_dog_id ON matches(dog_id);
CREATE INDEX idx_messages_match_id ON messages(match_id);

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
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for adopters
CREATE POLICY "Adopters can view their own profile" ON adopters
    FOR SELECT USING (auth.uid()::uuid = id);

CREATE POLICY "Adopters can update their own profile" ON adopters
    FOR UPDATE USING (auth.uid()::uuid = id);

-- Create RLS policies for dogs (public read)
CREATE POLICY "Dogs are viewable by everyone" ON dogs
    FOR SELECT USING (true);

-- Create RLS policies for likes
CREATE POLICY "Users can view their own likes" ON likes
    FOR SELECT USING (auth.uid()::uuid = adopter_id);

CREATE POLICY "Users can create their own likes" ON likes
    FOR INSERT WITH CHECK (auth.uid()::uuid = adopter_id);

-- Create RLS policies for matches
CREATE POLICY "Users can view their own matches" ON matches
    FOR SELECT USING (auth.uid()::uuid = adopter_id);

CREATE POLICY "Users can update their own matches" ON matches
    FOR UPDATE USING (auth.uid()::uuid = adopter_id);

-- Create RLS policies for messages
CREATE POLICY "Users can view messages from their matches" ON messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM matches
            WHERE matches.id = messages.match_id
            AND matches.adopter_id = auth.uid()::uuid
        )
    );

CREATE POLICY "Users can send messages to their matches" ON messages
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM matches
            WHERE matches.id = match_id
            AND matches.adopter_id = auth.uid()::uuid
        )
    );