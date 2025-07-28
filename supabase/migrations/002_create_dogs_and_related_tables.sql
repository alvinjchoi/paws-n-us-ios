-- Create dogs table
CREATE TABLE IF NOT EXISTS public.dogs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    age INTEGER NOT NULL,
    breed TEXT NOT NULL,
    size TEXT NOT NULL CHECK (size IN ('small', 'medium', 'large')),
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female')),
    location TEXT NOT NULL,
    bio TEXT NOT NULL,
    shelter_name TEXT NOT NULL,
    shelter_id UUID,
    personality TEXT,
    health_status TEXT,
    is_good_with_kids BOOLEAN DEFAULT false,
    is_good_with_pets BOOLEAN DEFAULT false,
    energy_level TEXT CHECK (energy_level IN ('low', 'medium', 'high')),
    image_urls TEXT[] DEFAULT '{}',
    traits TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create likes table
CREATE TABLE IF NOT EXISTS public.likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    dog_id UUID NOT NULL REFERENCES public.dogs(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, dog_id)
);

-- Create dislikes table
CREATE TABLE IF NOT EXISTS public.dislikes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    dog_id UUID NOT NULL REFERENCES public.dogs(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, dog_id)
);

-- Create matches table
CREATE TABLE IF NOT EXISTS public.matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    dog_id UUID NOT NULL REFERENCES public.dogs(id) ON DELETE CASCADE,
    matched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
    UNIQUE(user_id, dog_id)
);

-- Enable RLS
ALTER TABLE public.dogs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dislikes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;

-- Dogs policies (public read, admin write)
CREATE POLICY "Dogs are viewable by everyone" ON public.dogs
    FOR SELECT USING (true);

-- Likes policies
CREATE POLICY "Users can view own likes" ON public.likes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own likes" ON public.likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own likes" ON public.likes
    FOR DELETE USING (auth.uid() = user_id);

-- Dislikes policies
CREATE POLICY "Users can view own dislikes" ON public.dislikes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own dislikes" ON public.dislikes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Matches policies
CREATE POLICY "Users can view own matches" ON public.matches
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own matches" ON public.matches
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Add updated_at trigger to dogs table
CREATE TRIGGER dogs_updated_at
    BEFORE UPDATE ON public.dogs
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();