-- Migration: Create rescue mode functionality tables (Simple Version)
-- This migration adds tables needed for the rescue mode feature in the PawsInUs app

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create rescuers table for rescue organizations and individuals
CREATE TABLE IF NOT EXISTS public.rescuers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    organization_name TEXT,
    registration_number TEXT,
    verification_status TEXT DEFAULT 'pending' CHECK (verification_status IN ('pending', 'verified', 'rejected')),
    specialties TEXT[] DEFAULT '{}', -- Array of animal types they rescue
    capacity INTEGER DEFAULT 0, -- Maximum animals they can care for
    current_count INTEGER DEFAULT 0, -- Current number of animals
    location TEXT,
    contact_phone TEXT,
    contact_email TEXT,
    bio TEXT,
    website_url TEXT,
    social_media JSONB DEFAULT '{}', -- Social media links
    earnings_total DECIMAL(10,2) DEFAULT 0.00,
    rating DECIMAL(3,2) DEFAULT 0.00,
    review_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Extend existing dogs table for rescue mode functionality
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS rescuer_id UUID REFERENCES public.rescuers(id) ON DELETE SET NULL;
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS rescue_date DATE;
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS rescue_location TEXT;
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS rescue_story TEXT;
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS medical_status TEXT DEFAULT 'healthy';
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS medical_notes TEXT;
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS is_spayed_neutered BOOLEAN DEFAULT false;
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS vaccinations JSONB DEFAULT '{}';
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS foster_family_id TEXT; -- Changed to TEXT to match profiles.id
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS document_urls TEXT[] DEFAULT '{}';
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS rescuer_notes TEXT;
ALTER TABLE public.dogs ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT false;

-- Add check constraint separately to avoid issues
DO $$ 
BEGIN
    BEGIN
        ALTER TABLE public.dogs ADD CONSTRAINT medical_status_check 
        CHECK (medical_status IN ('healthy', 'needs_treatment', 'recovering', 'special_needs'));
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
END $$;

-- Create visits table for scheduling appointments
CREATE TABLE IF NOT EXISTS public.visits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    rescuer_id UUID REFERENCES public.rescuers(id) ON DELETE CASCADE NOT NULL,
    adopter_id TEXT NOT NULL, -- Changed to TEXT to match profiles.id
    animal_id UUID REFERENCES public.dogs(id) ON DELETE CASCADE NOT NULL,
    
    -- Visit details
    visit_type TEXT DEFAULT 'meet_greet' CHECK (visit_type IN ('meet_greet', 'adoption_interview', 'home_visit', 'follow_up')),
    scheduled_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    location TEXT,
    
    -- Status and notes
    status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'confirmed', 'in_progress', 'completed', 'cancelled', 'no_show')),
    rescuer_notes TEXT,
    adopter_notes TEXT,
    outcome TEXT,
    
    -- Requirements and preparation
    requirements TEXT[] DEFAULT '{}',
    preparation_notes TEXT,
    
    -- Follow-up
    follow_up_required BOOLEAN DEFAULT false,
    follow_up_date DATE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create transactions table for financial tracking
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    rescuer_id UUID REFERENCES public.rescuers(id) ON DELETE CASCADE NOT NULL,
    visit_id UUID REFERENCES public.visits(id) ON DELETE SET NULL,
    animal_id UUID REFERENCES public.dogs(id) ON DELETE CASCADE,
    
    -- Transaction details
    amount DECIMAL(10,2) NOT NULL,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('adoption_fee', 'donation', 'medical_expense', 'food_expense', 'service_fee', 'other')),
    direction TEXT NOT NULL CHECK (direction IN ('income', 'expense')),
    
    -- Payment information
    payment_method TEXT CHECK (payment_method IN ('cash', 'card', 'bank_transfer', 'other')),
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    reference_number TEXT,
    
    -- Description and categorization
    description TEXT NOT NULL,
    category TEXT,
    
    -- Related party
    payer_adopter_id TEXT, -- Changed to TEXT to match profiles.id
    
    -- Metadata
    transaction_date DATE DEFAULT CURRENT_DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create messages table for communication (ensure TEXT columns for user IDs)
DROP TABLE IF EXISTS public.messages CASCADE;
CREATE TABLE public.messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sender_id TEXT NOT NULL, -- Store as TEXT to match profiles.id
    recipient_id TEXT NOT NULL, -- Store as TEXT to match profiles.id  
    animal_id UUID REFERENCES public.dogs(id) ON DELETE CASCADE,
    visit_id UUID REFERENCES public.visits(id) ON DELETE SET NULL,
    
    -- Message content
    subject TEXT,
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'general' CHECK (message_type IN ('general', 'adoption_inquiry', 'visit_request', 'follow_up', 'urgent')),
    
    -- Status and metadata
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    
    -- Attachments
    attachment_urls TEXT[] DEFAULT '{}',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create indexes for better performance (with table existence verification)
DO $$ 
BEGIN
    -- Verify tables exist before creating indexes
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'rescuers') THEN
        CREATE INDEX IF NOT EXISTS idx_rescuers_user_id ON public.rescuers(user_id);
        CREATE INDEX IF NOT EXISTS idx_rescuers_verification_status ON public.rescuers(verification_status);
        CREATE INDEX IF NOT EXISTS idx_rescuers_location ON public.rescuers(location);
    END IF;

    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'dogs') THEN
        CREATE INDEX IF NOT EXISTS idx_dogs_rescuer_id ON public.dogs(rescuer_id);
        CREATE INDEX IF NOT EXISTS idx_dogs_featured ON public.dogs(is_featured);
        CREATE INDEX IF NOT EXISTS idx_dogs_medical_status ON public.dogs(medical_status);
    END IF;

    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'visits') THEN
        CREATE INDEX IF NOT EXISTS idx_visits_rescuer_id ON public.visits(rescuer_id);
        CREATE INDEX IF NOT EXISTS idx_visits_adopter_id ON public.visits(adopter_id);
        CREATE INDEX IF NOT EXISTS idx_visits_animal_id ON public.visits(animal_id);
        CREATE INDEX IF NOT EXISTS idx_visits_scheduled_date ON public.visits(scheduled_date);
        CREATE INDEX IF NOT EXISTS idx_visits_status ON public.visits(status);
    END IF;

    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'transactions') THEN
        CREATE INDEX IF NOT EXISTS idx_transactions_rescuer_id ON public.transactions(rescuer_id);
        CREATE INDEX IF NOT EXISTS idx_transactions_type ON public.transactions(transaction_type);
        CREATE INDEX IF NOT EXISTS idx_transactions_date ON public.transactions(transaction_date);
    END IF;

    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'messages') THEN
        -- Verify specific columns exist before creating indexes
        IF EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'messages' AND column_name = 'sender_id') THEN
            CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.messages(sender_id);
        END IF;
        
        IF EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'messages' AND column_name = 'recipient_id') THEN
            CREATE INDEX IF NOT EXISTS idx_messages_recipient_id ON public.messages(recipient_id);
        END IF;
        
        IF EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'messages' AND column_name = 'animal_id') THEN
            CREATE INDEX IF NOT EXISTS idx_messages_animal_id ON public.messages(animal_id);
        END IF;
        
        IF EXISTS (SELECT FROM information_schema.columns WHERE table_schema = 'public' AND table_name = 'messages' AND column_name = 'is_read') THEN
            CREATE INDEX IF NOT EXISTS idx_messages_is_read ON public.messages(is_read);
        END IF;
    END IF;
END $$;

-- Create triggers for updated_at (only if function doesn't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
        CREATE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $trigger$
        BEGIN
            NEW.updated_at = TIMEZONE('utc'::text, NOW());
            RETURN NEW;
        END;
        $trigger$ language 'plpgsql';
    END IF;
END $$;

-- Create triggers for the new tables
DO $$
BEGIN
    BEGIN
        CREATE TRIGGER update_rescuers_updated_at BEFORE UPDATE ON public.rescuers
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    BEGIN
        CREATE TRIGGER update_visits_updated_at BEFORE UPDATE ON public.visits
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    BEGIN
        CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON public.transactions
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    BEGIN
        CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON public.messages
            FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
END $$;

-- Enable Row Level Security (RLS)
ALTER TABLE public.rescuers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (with proper error handling)
DO $$ 
BEGIN
    -- Rescuers policies
    BEGIN
        CREATE POLICY "Users can view their own rescuer profile" ON public.rescuers
            FOR SELECT USING (auth.uid() = user_id);
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    BEGIN
        CREATE POLICY "Users can insert their own rescuer profile" ON public.rescuers
            FOR INSERT WITH CHECK (auth.uid() = user_id);
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    BEGIN
        CREATE POLICY "Users can update their own rescuer profile" ON public.rescuers
            FOR UPDATE USING (auth.uid() = user_id);
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    BEGIN
        CREATE POLICY "Public can view verified rescuers" ON public.rescuers
            FOR SELECT USING (verification_status = 'verified' AND is_active = true);
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    -- Dogs/rescue animals policies
    BEGIN
        CREATE POLICY "Rescuers can manage their rescue animals" ON public.dogs
            FOR ALL USING (
                rescuer_id IS NOT NULL AND EXISTS (
                    SELECT 1 FROM public.rescuers 
                    WHERE rescuers.id = dogs.rescuer_id 
                    AND rescuers.user_id = auth.uid()
                )
            );
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    -- Visits policies
    BEGIN
        CREATE POLICY "Rescuers can manage visits for their animals" ON public.visits
            FOR ALL USING (
                EXISTS (
                    SELECT 1 FROM public.rescuers 
                    WHERE rescuers.id = visits.rescuer_id 
                    AND rescuers.user_id = auth.uid()
                )
            );
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    BEGIN
        CREATE POLICY "Adopters can view their own visits" ON public.visits
            FOR SELECT USING (adopter_id = CAST(auth.uid() AS text));
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    -- Transactions policies
    BEGIN
        CREATE POLICY "Rescuers can manage their own transactions" ON public.transactions
            FOR ALL USING (
                EXISTS (
                    SELECT 1 FROM public.rescuers 
                    WHERE rescuers.id = transactions.rescuer_id 
                    AND rescuers.user_id = auth.uid()
                )
            );
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    -- Messages policies
    BEGIN
        CREATE POLICY "Users can view messages they sent or received" ON public.messages
            FOR SELECT USING (
                sender_id = CAST(auth.uid() AS text) OR
                recipient_id = CAST(auth.uid() AS text)
            );
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    BEGIN
        CREATE POLICY "Users can send messages" ON public.messages
            FOR INSERT WITH CHECK (
                sender_id = CAST(auth.uid() AS text)
            );
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;

    BEGIN
        CREATE POLICY "Users can update messages they sent" ON public.messages
            FOR UPDATE USING (
                sender_id = CAST(auth.uid() AS text)
            );
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
END $$;

-- Add trigger to update rescuer stats when dogs are added/removed
CREATE OR REPLACE FUNCTION update_rescuer_animal_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Update current count for the rescuer (only if rescuer_id is set)
    IF (TG_OP = 'DELETE' AND OLD.rescuer_id IS NOT NULL) OR 
       (TG_OP != 'DELETE' AND NEW.rescuer_id IS NOT NULL) THEN
        
        UPDATE public.rescuers 
        SET current_count = (
            SELECT COUNT(*) 
            FROM public.dogs 
            WHERE rescuer_id = 
                CASE 
                    WHEN TG_OP = 'DELETE' THEN OLD.rescuer_id
                    ELSE NEW.rescuer_id
                END
            AND available = true
        )
        WHERE id = 
            CASE 
                WHEN TG_OP = 'DELETE' THEN OLD.rescuer_id
                ELSE NEW.rescuer_id
            END;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Create trigger for dog changes
DO $$
BEGIN
    BEGIN
        CREATE TRIGGER update_rescuer_count_on_dog_change
            AFTER INSERT OR UPDATE OR DELETE ON public.dogs
            FOR EACH ROW EXECUTE FUNCTION update_rescuer_animal_count();
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
END $$;

-- Add trigger to update rescuer earnings when transactions are added
CREATE OR REPLACE FUNCTION update_rescuer_earnings()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total earnings for the rescuer
    UPDATE public.rescuers 
    SET earnings_total = (
        SELECT COALESCE(SUM(
            CASE 
                WHEN direction = 'income' THEN amount
                WHEN direction = 'expense' THEN -amount
                ELSE 0
            END
        ), 0)
        FROM public.transactions 
        WHERE rescuer_id = 
            CASE 
                WHEN TG_OP = 'DELETE' THEN OLD.rescuer_id
                ELSE NEW.rescuer_id
            END
        AND payment_status = 'completed'
    )
    WHERE id = 
        CASE 
            WHEN TG_OP = 'DELETE' THEN OLD.rescuer_id
            ELSE NEW.rescuer_id
        END;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Create trigger for transaction changes
DO $$
BEGIN
    BEGIN
        CREATE TRIGGER update_rescuer_earnings_on_transaction_change
            AFTER INSERT OR UPDATE OR DELETE ON public.transactions
            FOR EACH ROW EXECUTE FUNCTION update_rescuer_earnings();
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
END $$;