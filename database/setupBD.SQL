-- ------------------------------------------------------------
-- Comprehensive SQL Script for Supabase Database Setup
-- This script drops existing tables and types, then recreates
-- them with necessary constraints, triggers, RLS policies, and indexes.
-- ------------------------------------------------------------

-- 1. Drop Existing Tables and Types to Allow Re-running the Script Easily
DROP TABLE IF EXISTS entry CASCADE;
DROP TABLE IF EXISTS aspect CASCADE;
DROP TABLE IF EXISTS diary CASCADE;
DROP TABLE IF EXISTS cohort_clinician CASCADE;
DROP TABLE IF EXISTS cohort_user CASCADE;
DROP TABLE IF EXISTS cohort CASCADE;
DROP TABLE IF EXISTS clinician CASCADE;
DROP TABLE IF EXISTS "user" CASCADE;

DROP TYPE IF EXISTS aspect_data_type CASCADE;

-- 2. Create Enumerated Types
CREATE TYPE aspect_data_type AS ENUM ('text', 'scale');

-- 3. Create Tables with Constraints

-- User Table
CREATE TABLE "user" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Clinician Table
CREATE TABLE clinician (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Cohort Table
CREATE TABLE cohort (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    owner_id UUID NOT NULL REFERENCES clinician(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Cohort_User Table (Many-to-Many Relationship between Cohorts and Users)
CREATE TABLE cohort_user (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cohort_id UUID NOT NULL REFERENCES cohort(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (cohort_id, user_id)
);

-- Cohort_Clinician Table (Many-to-Many Relationship between Cohorts and Clinicians)
CREATE TABLE cohort_clinician (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cohort_id UUID NOT NULL REFERENCES cohort(id) ON DELETE CASCADE,
    clinician_id UUID NOT NULL REFERENCES clinician(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE (cohort_id, clinician_id)
);

-- Diary Table
CREATE TABLE diary (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    duration_days INT, -- NULL for personal diaries
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CHECK (duration_days > 0 OR duration_days IS NULL),
    UNIQUE (user_id, name)
);

-- Aspect Table
CREATE TABLE aspect (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    diary_id UUID NOT NULL REFERENCES diary(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    frequency_days INT NOT NULL,
    data_type aspect_data_type NOT NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CHECK (frequency_days > 0),
    UNIQUE (diary_id, name)
);

-- Entry Table
CREATE TABLE entry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    aspect_id UUID NOT NULL REFERENCES aspect(id) ON DELETE CASCADE,
    diary_id UUID NOT NULL REFERENCES diary(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    content_text TEXT, -- For 'text' type aspects
    content_scale INT CHECK (content_scale BETWEEN 1 AND 10), -- For 'scale' type aspects
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CHECK (
        (content_text IS NOT NULL AND content_scale IS NULL) OR
        (content_text IS NULL AND content_scale IS NOT NULL)
    )
);

-- 4. Create Trigger Functions and Triggers

-- Trigger Function to Ensure Cohort Owner is a Clinician
CREATE OR REPLACE FUNCTION verify_cohort_owner()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM clinician WHERE id = NEW.owner_id
    ) THEN
        RAISE EXCEPTION 'Cohort owner must be a valid clinician';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger on Cohort Table
CREATE TRIGGER check_cohort_owner
BEFORE INSERT OR UPDATE ON cohort
FOR EACH ROW
EXECUTE FUNCTION verify_cohort_owner();

-- Trigger Function to Ensure Entry Data Type Consistency
CREATE OR REPLACE FUNCTION verify_entry_data_type()
RETURNS TRIGGER AS $$
DECLARE
    aspect_type aspect_data_type;
BEGIN
    SELECT data_type INTO aspect_type FROM aspect WHERE id = NEW.aspect_id;
    
    IF aspect_type = 'text' THEN
        IF NEW.content_text IS NULL THEN
            RAISE EXCEPTION 'content_text must be provided for text aspects';
        END IF;
        IF NEW.content_scale IS NOT NULL THEN
            RAISE EXCEPTION 'content_scale must be NULL for text aspects';
        END IF;
    ELSIF aspect_type = 'scale' THEN
        IF NEW.content_scale IS NULL THEN
            RAISE EXCEPTION 'content_scale must be provided for scale aspects';
        END IF;
        IF NEW.content_text IS NOT NULL THEN
            RAISE EXCEPTION 'content_text must be NULL for scale aspects';
        END IF;
    ELSE
        RAISE EXCEPTION 'Unknown aspect data type';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger on Entry Table
CREATE TRIGGER check_entry_data_type
BEFORE INSERT OR UPDATE ON entry
FOR EACH ROW
EXECUTE FUNCTION verify_entry_data_type();

-- 5. Enable Row Level Security on All Relevant Tables
ALTER TABLE "user" ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinician ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohort ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohort_user ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohort_clinician ENABLE ROW LEVEL SECURITY;
ALTER TABLE diary ENABLE ROW LEVEL SECURITY;
ALTER TABLE aspect ENABLE ROW LEVEL SECURITY;
ALTER TABLE entry ENABLE ROW LEVEL SECURITY;

-- 6. Create Row Level Security (RLS) Policies

-- Users Table RLS Policies

-- Users can view their own records
CREATE POLICY "Users can view their own data"
    ON "user"
    FOR SELECT
    USING (id = auth.uid());

-- Users can update their own records
CREATE POLICY "Users can update their own data"
    ON "user"
    FOR UPDATE
    USING (id = auth.uid());

-- Clinicians can view users assigned to their cohorts
CREATE POLICY "Clinicians can view assigned users"
    ON "user"
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM cohort_user
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE cohort_user.user_id = "user".id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Clinician Table RLS Policies

-- Clinicians can view their own records
CREATE POLICY "Clinicians can view their own data"
    ON clinician
    FOR SELECT
    USING (id = auth.uid());

-- Clinicians can update their own records
CREATE POLICY "Clinicians can update their own data"
    ON clinician
    FOR UPDATE
    USING (id = auth.uid());

-- Prevent clinicians from viewing other clinicians' data
CREATE POLICY "Prevent clinicians from viewing others' data"
    ON clinician
    FOR SELECT
    USING (id = auth.uid());

-- Prevent clinicians from updating other clinicians' data
CREATE POLICY "Prevent clinicians from updating others' data"
    ON clinician
    FOR UPDATE
    USING (id = auth.uid());

-- Cohort Table RLS Policies

-- Only the cohort owner can manage the cohort
CREATE POLICY "Cohort owner can manage the cohort"
    ON cohort
    FOR ALL
    USING (owner_id = auth.uid());

-- Clinicians can view cohorts they own
CREATE POLICY "Clinicians can view cohorts they own"
    ON cohort
    FOR SELECT
    USING (owner_id = auth.uid());

-- Cohort_User Table RLS Policies

-- Cohort owners can manage their own cohort memberships
CREATE POLICY "Cohort owner can manage users in their cohort"
    ON cohort_user
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM cohort
            WHERE cohort.id = cohort_user.cohort_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Prevent regular users from accessing cohort memberships
CREATE POLICY "No access for users to cohort memberships"
    ON cohort_user
    FOR ALL
    USING (false);

-- Cohort_Clinician Table RLS Policies

-- Cohort owners can manage their own cohort's clinicians
CREATE POLICY "Cohort owner can manage clinicians in their cohort"
    ON cohort_clinician
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM cohort
            WHERE cohort.id = cohort_clinician.cohort_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Prevent regular users from accessing cohort clinician memberships
CREATE POLICY "No access for users to cohort clinician memberships"
    ON cohort_clinician
    FOR ALL
    USING (false);

-- Diary Table RLS Policies

-- Users can access their own diaries
CREATE POLICY "Users can access their own diaries"
    ON diary
    FOR SELECT
    USING (user_id = auth.uid());

-- Users can insert their own diaries
CREATE POLICY "Users can insert their own diaries"
    ON diary
    FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- Users can update their own diaries
CREATE POLICY "Users can update their own diaries"
    ON diary
    FOR UPDATE
    USING (user_id = auth.uid());

-- Clinicians can access diaries of users in their cohorts
CREATE POLICY "Clinicians can access diaries of users in their cohorts"
    ON diary
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM cohort_user
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE cohort_user.user_id = diary.user_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Clinicians can insert diaries for users in their cohorts
CREATE POLICY "Clinicians can insert diaries for users in their cohorts"
    ON diary
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM cohort_user
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE cohort_user.user_id = diary.user_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Clinicians can update diaries of users in their cohorts
CREATE POLICY "Clinicians can update diaries of users in their cohorts"
    ON diary
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM cohort_user
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE cohort_user.user_id = diary.user_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Aspect Table RLS Policies

-- Users can access aspects in their own diaries
CREATE POLICY "Users can access aspects in their own diaries"
    ON aspect
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM diary
            WHERE diary.id = aspect.diary_id
              AND diary.user_id = auth.uid()
        )
    );

-- Users can insert aspects in their own diaries
CREATE POLICY "Users can insert aspects in their own diaries"
    ON aspect
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM diary
            WHERE diary.id = aspect.diary_id
              AND diary.user_id = auth.uid()
        )
    );

-- Users can update aspects in their own diaries
CREATE POLICY "Users can update aspects in their own diaries"
    ON aspect
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM diary
            WHERE diary.id = aspect.diary_id
              AND diary.user_id = auth.uid()
        )
    );

-- Clinicians can access aspects of users in their cohorts' diaries
CREATE POLICY "Clinicians can access aspects of users in their cohorts' diaries"
    ON aspect
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_user ON cohort_user.user_id = diary.user_id
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE diary.id = aspect.diary_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Clinicians can insert aspects in users' cohorts' diaries
CREATE POLICY "Clinicians can insert aspects in users' cohorts' diaries"
    ON aspect
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_user ON cohort_user.user_id = diary.user_id
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE diary.id = aspect.diary_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Clinicians can update aspects in users' cohorts' diaries
CREATE POLICY "Clinicians can update aspects in users' cohorts' diaries"
    ON aspect
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_user ON cohort_user.user_id = diary.user_id
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE diary.id = aspect.diary_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Entry Table RLS Policies

-- Users can access their own entries
CREATE POLICY "Users can access their own entries"
    ON entry
    FOR SELECT
    USING (user_id = auth.uid());

-- Users can insert their own entries
CREATE POLICY "Users can insert their own entries"
    ON entry
    FOR INSERT
    WITH CHECK (user_id = auth.uid());

-- Users can update their own entries
CREATE POLICY "Users can update their own entries"
    ON entry
    FOR UPDATE
    USING (user_id = auth.uid());

-- Users can delete their own entries
CREATE POLICY "Users can delete their own entries"
    ON entry
    FOR DELETE
    USING (user_id = auth.uid());

-- Clinicians can access entries of users in their cohorts' diaries
CREATE POLICY "Clinicians can access entries of users in their cohorts' diaries"
    ON entry
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_user ON cohort_user.user_id = diary.user_id
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE diary.id = entry.diary_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Clinicians can insert entries for users in their cohorts' diaries
CREATE POLICY "Clinicians can insert entries for users in their cohorts' diaries"
    ON entry
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_user ON cohort_user.user_id = diary.user_id
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE diary.id = entry.diary_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Clinicians can update entries of users in their cohorts' diaries
CREATE POLICY "Clinicians can update entries of users in their cohorts' diaries"
    ON entry
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_user ON cohort_user.user_id = diary.user_id
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE diary.id = entry.diary_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- Clinicians can delete entries of users in their cohorts' diaries
CREATE POLICY "Clinicians can delete entries of users in their cohorts' diaries"
    ON entry
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_user ON cohort_user.user_id = diary.user_id
            JOIN cohort ON cohort_user.cohort_id = cohort.id
            WHERE diary.id = entry.diary_id
              AND cohort.owner_id = auth.uid()
        )
    );

-- 7. Create Indexes for Performance Optimization

-- Indexes for cohort_user
CREATE INDEX IF NOT EXISTS idx_cohort_user_cohort_id ON cohort_user(cohort_id);
CREATE INDEX IF NOT EXISTS idx_cohort_user_user_id ON cohort_user(user_id);

-- Indexes for cohort_clinician
CREATE INDEX IF NOT EXISTS idx_cohort_clinician_cohort_id ON cohort_clinician(cohort_id);
CREATE INDEX IF NOT EXISTS idx_cohort_clinician_clinician_id ON cohort_clinician(clinician_id);

-- Index for diary
CREATE INDEX IF NOT EXISTS idx_diary_user_id ON diary(user_id);

-- Index for aspect
CREATE INDEX IF NOT EXISTS idx_aspect_diary_id ON aspect(diary_id);

-- Index for entry
CREATE INDEX IF NOT EXISTS idx_entry_aspect_id ON entry(aspect_id);
CREATE INDEX IF NOT EXISTS idx_entry_diary_id ON entry(diary_id);
CREATE INDEX IF NOT EXISTS idx_entry_user_id ON entry(user_id);
