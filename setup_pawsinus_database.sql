-- PAWSINUS DATABASE SETUP SCRIPT
-- This script handles both fresh installations and existing databases

-- 1. Create extensions if they don't exist
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Create enum types (only if they don't exist)
DO $$ BEGIN
    CREATE TYPE dog_size AS ENUM ('small', 'medium', 'large', 'extraLarge');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE dog_gender AS ENUM ('male', 'female');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE energy_level AS ENUM ('low', 'medium', 'high', 'veryHigh');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE match_status AS ENUM ('matched', 'chatting', 'meetingScheduled', 'adopted', 'cancelled');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 3. Create tables if they don't exist
CREATE TABLE IF NOT EXISTS shelters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dogs (
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
    shelter_name TEXT,
    date_added TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS adopters (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    location TEXT,
    bio TEXT,
    profile_image_url TEXT,
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
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    adopter_id UUID REFERENCES adopters(id) ON DELETE CASCADE,
    dog_id UUID REFERENCES dogs(id) ON DELETE CASCADE,
    liked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(adopter_id, dog_id)
);

CREATE TABLE IF NOT EXISTS matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    dog_id UUID REFERENCES dogs(id) ON DELETE CASCADE,
    adopter_id UUID REFERENCES adopters(id) ON DELETE CASCADE,
    shelter_id UUID REFERENCES shelters(id) ON DELETE CASCADE,
    match_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status match_status DEFAULT 'matched',
    last_message_at TIMESTAMP WITH TIME ZONE,
    conversation JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(dog_id, adopter_id)
);

CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    content TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read BOOLEAN DEFAULT false
);

-- 4. Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_dogs_shelter_id ON dogs(shelter_id);
CREATE INDEX IF NOT EXISTS idx_dogs_available ON dogs(available);
CREATE INDEX IF NOT EXISTS idx_likes_adopter_id ON likes(adopter_id);
CREATE INDEX IF NOT EXISTS idx_likes_dog_id ON likes(dog_id);
CREATE INDEX IF NOT EXISTS idx_matches_adopter_id ON matches(adopter_id);
CREATE INDEX IF NOT EXISTS idx_matches_dog_id ON matches(dog_id);
CREATE INDEX IF NOT EXISTS idx_messages_match_id ON messages(match_id);

-- 5. Clear existing data
TRUNCATE TABLE messages, matches, likes, dogs, adopters, shelters CASCADE;

-- 6. Disable RLS for testing
ALTER TABLE adopters DISABLE ROW LEVEL SECURITY;
ALTER TABLE dogs DISABLE ROW LEVEL SECURITY;
ALTER TABLE shelters DISABLE ROW LEVEL SECURITY;
ALTER TABLE likes DISABLE ROW LEVEL SECURITY;
ALTER TABLE matches DISABLE ROW LEVEL SECURITY;
ALTER TABLE messages DISABLE ROW LEVEL SECURITY;

-- 7. Insert Korean shelters
INSERT INTO shelters (id, name, location, email, phone) VALUES
('550e8400-e29b-41d4-a716-446655440001', '서울동물복지지원센터 마포', '서울특별시 마포구 매봉산로 31', 'mapo.animal@seoul.go.kr', '02-2124-2839'),
('550e8400-e29b-41d4-a716-446655440002', '서울동물복지지원센터 구로', '서울특별시 구로구 경인로 472', 'guro.animal@seoul.go.kr', '02-2627-0661'),
('550e8400-e29b-41d4-a716-446655440003', '서울동물복지지원센터 동대문', '서울특별시 동대문구 무학로 201', 'dongdaemun.animal@seoul.go.kr', '02-921-2415');

-- 8. Insert Korean dogs with complete data
INSERT INTO dogs (id, name, breed, age, size, gender, image_urls, bio, shelter_id, location, traits, energy_level, good_with_kids, good_with_pets, available, shelter_name) VALUES
-- 서울동물복지지원센터 마포의 개들
('550e8400-e29b-41d4-a716-446655440201', '루나', '진돗개', 3, 'medium', 'female', 
 ARRAY['https://images.unsplash.com/photo-1596492784531-6e6eb5ea9993?w=800', 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=800'], 
 '루나는 충성심이 강한 진돗개입니다. 한 주인에게 헌신적이며 영리하고 깨끗한 성격을 가지고 있어요.', 
 '550e8400-e29b-41d4-a716-446655440001', '서울특별시 강남구', 
 ARRAY['충성심', '영리함', '깨끗함', '독립적'], 'medium', true, true, true, '서울동물복지지원센터 마포'),

('550e8400-e29b-41d4-a716-446655440204', '몽이', '시바견', 1, 'medium', 'male', 
 ARRAY['https://images.unsplash.com/photo-1568393691622-c7ba131d63b4?w=800', 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=800'], 
 '몽이는 어린 시바견으로 독립적이면서도 충실한 성격입니다. 산책을 좋아하고 훈련이 가능해요.', 
 '550e8400-e29b-41d4-a716-446655440001', '서울특별시 마포구', 
 ARRAY['독립적', '충실함', '활동적', '똑똑함'], 'high', true, true, true, '서울동물복지지원센터 마포'),

('550e8400-e29b-41d4-a716-446655440207', '해피', '비숑프리제', 2, 'small', 'male', 
 ARRAY['https://images.unsplash.com/photo-1585559700398-1385b3a8aeb6?w=800', 'https://images.unsplash.com/photo-1534628526458-a8de087b1123?w=800'], 
 '해피는 이름처럼 항상 밝고 명랑한 비숑입니다. 알레르기 유발이 적고 애교가 많아요.', 
 '550e8400-e29b-41d4-a716-446655440001', '서울특별시 송파구', 
 ARRAY['명랑함', '애교', '저자극성', '활발함'], 'medium', true, true, true, '서울동물복지지원센터 마포'),

('550e8400-e29b-41d4-a716-446655440210', '별이', '요크셔테리어', 6, 'small', 'female', 
 ARRAY['https://images.unsplash.com/photo-1593134257782-e89567b7718a?w=800', 'https://images.unsplash.com/photo-1586671267731-da2cf3ceeb80?w=800'], 
 '별이는 작지만 용감한 요크셔테리어입니다. 실내 생활에 적합하고 주인에게 매우 충실해요.', 
 '550e8400-e29b-41d4-a716-446655440001', '서울특별시 서초구', 
 ARRAY['용감함', '충실함', '실내견', '보호본능'], 'medium', true, true, true, '서울동물복지지원센터 마포'),

('550e8400-e29b-41d4-a716-446655440213', '두부', '불독', 3, 'medium', 'female', 
 ARRAY['https://images.unsplash.com/photo-1517849845537-4d257902454a?w=800', 'https://images.unsplash.com/photo-1583512603784-a8e3ea2b01a7?w=800'], 
 '두부는 느긋한 성격의 불독입니다. 실내 생활을 좋아하고 짧은 산책을 선호해요.', 
 '550e8400-e29b-41d4-a716-446655440001', '서울특별시 강서구', 
 ARRAY['느긋함', '실내견', '온순함', '게으름'], 'low', true, true, true, '서울동물복지지원센터 마포'),

-- 서울동물복지지원센터 구로의 개들
('550e8400-e29b-41d4-a716-446655440202', '코코', '말티즈', 2, 'small', 'male', 
 ARRAY['https://images.unsplash.com/photo-1519138270491-4c27fbdbe01f?w=800', 'https://images.unsplash.com/photo-1534361960057-19889db9621e?w=800'], 
 '코코는 사랑스러운 말티즈 남아입니다. 실내 생활에 적합하고 아이들과도 잘 지내는 온순한 성격이에요.', 
 '550e8400-e29b-41d4-a716-446655440002', '경기도 성남시', 
 ARRAY['온순함', '애교', '실내견', '사교적'], 'low', true, true, true, '서울동물복지지원센터 구로'),

('550e8400-e29b-41d4-a716-446655440205', '초코', '푸들', 3, 'medium', 'male', 
 ARRAY['https://images.unsplash.com/photo-1537151608828-ea2b11777ee8?w=800', 'https://images.unsplash.com/photo-1558788353-03f0e3d8b43b?w=800'], 
 '초코는 털이 안 빠지는 푸들로 알레르기가 있는 분들에게 적합해요. 영리하고 훈련이 잘 되어있습니다.', 
 '550e8400-e29b-41d4-a716-446655440002', '인천광역시 연수구', 
 ARRAY['저자극성', '영리함', '훈련됨', '사교적'], 'medium', true, true, true, '서울동물복지지원센터 구로'),

('550e8400-e29b-41d4-a716-446655440208', '구름이', '사모예드', 3, 'large', 'female', 
 ARRAY['https://images.unsplash.com/photo-1534361960057-19889db9621e?w=800', 'https://images.unsplash.com/photo-1529429617124-95b109e86bb8?w=800'], 
 '구름이는 하얀 털이 구름 같은 사모예드입니다. 온화하고 사람을 좋아하며 추운 날씨를 좋아해요.', 
 '550e8400-e29b-41d4-a716-446655440002', '경기도 용인시', 
 ARRAY['온화함', '사람친화', '추위적응', '활동적'], 'high', true, true, true, '서울동물복지지원센터 구로'),

('550e8400-e29b-41d4-a716-446655440211', '마루', '시츄', 7, 'small', 'male', 
 ARRAY['https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=800', 'https://images.unsplash.com/photo-1588943211346-0908a1fb0b01?w=800'], 
 '마루는 온순한 성격의 시츄 노령견입니다. 조용한 환경을 좋아하고 산책을 즐겨요.', 
 '550e8400-e29b-41d4-a716-446655440002', '대전광역시 유성구', 
 ARRAY['온순함', '조용함', '노령견', '순함'], 'low', true, true, true, '서울동물복지지원센터 구로'),

('550e8400-e29b-41d4-a716-446655440214', '쿠키', '비글', 1, 'medium', 'male', 
 ARRAY['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800', 'https://images.unsplash.com/photo-1595511890410-3b8dc237a537?w=800'], 
 '쿠키는 호기심 많은 어린 비글입니다. 냄새 맡는 것을 좋아하고 활동적이에요.', 
 '550e8400-e29b-41d4-a716-446655440002', '경기도 안양시', 
 ARRAY['호기심', '활동적', '후각발달', '어린강아지'], 'veryHigh', true, true, true, '서울동물복지지원센터 구로'),

-- 서울동물복지지원센터 동대문의 개들
('550e8400-e29b-41d4-a716-446655440203', '뽀미', '포메라니안', 4, 'small', 'female', 
 ARRAY['https://images.unsplash.com/photo-1582456891925-a53965520520?w=800', 'https://images.unsplash.com/photo-1584553421349-3557471bed79?w=800'], 
 '뽀미는 작지만 당찬 포메라니안입니다. 활발하고 호기심이 많으며 주인에게 애정이 많아요.', 
 '550e8400-e29b-41d4-a716-446655440003', '부산광역시 해운대구', 
 ARRAY['활발함', '호기심', '애정', '경계심'], 'high', true, true, true, '서울동물복지지원센터 동대문'),

('550e8400-e29b-41d4-a716-446655440206', '보리', '삽살개', 5, 'large', 'female', 
 ARRAY['https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=800', 'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=800'], 
 '보리는 전통 한국견 삽살개입니다. 온순하고 아이들을 좋아하며 가족을 보호하려는 본능이 있어요.', 
 '550e8400-e29b-41d4-a716-446655440003', '대구광역시 수성구', 
 ARRAY['온순함', '보호본능', '아이친화', '충성'], 'medium', true, true, true, '서울동물복지지원센터 동대문'),

('550e8400-e29b-41d4-a716-446655440209', '댕댕이', '웰시코기', 4, 'medium', 'male', 
 ARRAY['https://images.unsplash.com/photo-1546975490-e8b92a360b24?w=800', 'https://images.unsplash.com/photo-1519098901909-b1553a1190af?w=800'], 
 '댕댕이는 짧은 다리가 매력적인 코기입니다. 활발하고 영리하며 목축견의 본능이 있어요.', 
 '550e8400-e29b-41d4-a716-446655440003', '광주광역시 서구', 
 ARRAY['활발함', '영리함', '목축본능', '사교적'], 'high', true, true, true, '서울동물복지지원센터 동대문'),

('550e8400-e29b-41d4-a716-446655440212', '백구', '풍산개', 2, 'large', 'male', 
 ARRAY['https://images.unsplash.com/photo-1552053831-71594a27632d?w=800', 'https://images.unsplash.com/photo-1561037404-61cd46aa615b?w=800'], 
 '백구는 희귀한 풍산개입니다. 용맹하고 충성심이 강하며 가족을 잘 보호합니다.', 
 '550e8400-e29b-41d4-a716-446655440003', '강원도 춘천시', 
 ARRAY['용맹함', '충성심', '보호본능', '희귀견'], 'high', true, false, true, '서울동물복지지원센터 동대문'),

('550e8400-e29b-41d4-a716-446655440215', '하늘이', '허스키', 4, 'large', 'female', 
 ARRAY['https://images.unsplash.com/photo-1547407139-3c921a66005c?w=800', 'https://images.unsplash.com/photo-1605568427561-40dd23c2acea?w=800'], 
 '하늘이는 파란 눈이 매력적인 허스키입니다. 운동량이 많이 필요하고 추운 날씨를 좋아해요.', 
 '550e8400-e29b-41d4-a716-446655440003', '울산광역시 남구', 
 ARRAY['활동적', '독립적', '추위적응', '파란눈'], 'veryHigh', false, false, true, '서울동물복지지원센터 동대문');

-- 9. Insert test adopter
INSERT INTO adopters (id, name, email, location, bio, preferences) VALUES
('550e8400-e29b-41d4-a716-446655440100', 'Test User', 'test@example.com', '서울특별시', '반려견을 찾고 있는 예비 견주입니다!',
 '{
   "preferredSizes": ["small", "medium"],
   "preferredAgeRange": [0, 10],
   "preferredEnergyLevels": ["low", "medium"],
   "hasKids": false,
   "hasOtherPets": false,
   "maxDistance": 50
 }'::jsonb);

-- 10. Create additional test data for likes and matches
-- Test user likes several dogs
INSERT INTO likes (adopter_id, dog_id) VALUES
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440201'),
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440202'),
('550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440207');

-- Create a test match
INSERT INTO matches (dog_id, adopter_id, shelter_id, status) VALUES
('550e8400-e29b-41d4-a716-446655440202', '550e8400-e29b-41d4-a716-446655440100', '550e8400-e29b-41d4-a716-446655440002', 'matched');

-- 11. Verify the data
SELECT 'Data Import Summary:' as info;
SELECT 'Shelters: ' || COUNT(*) as count FROM shelters
UNION ALL
SELECT 'Dogs: ' || COUNT(*) FROM dogs
UNION ALL
SELECT 'Adopters: ' || COUNT(*) FROM adopters
UNION ALL
SELECT 'Likes: ' || COUNT(*) FROM likes
UNION ALL
SELECT 'Matches: ' || COUNT(*) FROM matches;

-- Show sample dogs
SELECT '
Sample Dogs:' as info;
SELECT id, name, breed, age, size, gender, shelter_name
FROM dogs 
ORDER BY date_added DESC
LIMIT 5;

-- Show dogs by shelter
SELECT '
Dogs by Shelter:' as info;
SELECT shelter_name, COUNT(*) as dog_count
FROM dogs
GROUP BY shelter_name
ORDER BY shelter_name;