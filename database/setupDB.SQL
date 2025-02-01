-- ------------------------------------------------------------
-- Comprehensive SQL Script for Supabase Database Setup
-- This script drops existing tables and types, then recreates
-- them with necessary constraints, triggers, RLS policies, and indexes.
-- ------------------------------------------------------------

-- Drop existing tables (in correct order)
DROP TABLE IF EXISTS entry CASCADE;
DROP TABLE IF EXISTS diary_aspect CASCADE;
DROP TABLE IF EXISTS aspect CASCADE;
DROP TABLE IF EXISTS diary CASCADE;
DROP TABLE IF EXISTS cohort_member CASCADE;
DROP TABLE IF EXISTS cohort CASCADE;
DROP TABLE IF EXISTS profile CASCADE;

-- Drop existing types
DROP TYPE IF EXISTS aspect_data_type CASCADE;

-- Enable UUID extension (this is fine as it's a general postgres extension)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create types
CREATE TYPE aspect_data_type AS ENUM ('text', 'scale');

-- Create tables
CREATE TABLE profile (
    id UUID PRIMARY KEY,
    role TEXT NOT NULL CHECK (role IN ('patient', 'clinician')),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Update Cohort Table
CREATE TABLE cohort (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    clinician_id UUID NOT NULL REFERENCES profile(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Replace cohort_user with cohort_member
CREATE TABLE cohort_member (
    cohort_id UUID REFERENCES cohort(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES profile(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    PRIMARY KEY (cohort_id, patient_id)
);

-- Update Diary Table
CREATE TABLE public.diary (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id UUID NOT NULL REFERENCES public.profile(id),
    name TEXT NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CHECK (end_date IS NULL OR end_date >= start_date)
);

-- Aspect Table
CREATE TABLE public.aspect (
    id SERIAL PRIMARY KEY,
    diary_id UUID NOT NULL REFERENCES public.diary(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    frequency_days INT NOT NULL,
    data_type public.aspect_data_type NOT NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CHECK (frequency_days > 0),
    UNIQUE (diary_id, name)
);

-- Entry Table
CREATE TABLE public.entry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    aspect_id INTEGER NOT NULL REFERENCES public.aspect(id) ON DELETE CASCADE,
    diary_id UUID NOT NULL REFERENCES public.diary(id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES public.profile(id) ON DELETE CASCADE,
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

-- Create diary_aspect join table
CREATE TABLE public.diary_aspect (
    diary_id UUID REFERENCES public.diary(id) ON DELETE CASCADE,
    aspect_id INTEGER REFERENCES public.aspect(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    PRIMARY KEY (diary_id, aspect_id)
);

-- 5. Enable Row Level Security on All Relevant Tables
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohort ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohort_member ENABLE ROW LEVEL SECURITY;
ALTER TABLE diary ENABLE ROW LEVEL SECURITY;
ALTER TABLE aspect ENABLE ROW LEVEL SECURITY;
ALTER TABLE entry ENABLE ROW LEVEL SECURITY;
ALTER TABLE diary_aspect ENABLE ROW LEVEL SECURITY;

-- 6. Create Row Level Security (RLS) Policies

-- Users can view their own records
CREATE POLICY "Users can view their own data"
    ON profile
    FOR SELECT
    USING (id = auth.uid());

-- Users can update their own records
CREATE POLICY "Users can update their own data"
    ON profile
    FOR UPDATE
    USING (id = auth.uid());

-- Clinicians can view users assigned to their cohorts
CREATE POLICY "Clinicians can view assigned users"
    ON profile
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM cohort_member cm
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE cm.patient_id = profile.id
              AND c.clinician_id = auth.uid()
        )
    );

-- Cohort Table RLS Policies

-- Only the cohort owner can manage the cohort
CREATE POLICY "Cohort owner can manage the cohort"
    ON cohort
    FOR ALL
    USING (clinician_id = auth.uid());

-- Clinicians can view cohorts they own
CREATE POLICY "Clinicians can view cohorts they own"
    ON cohort
    FOR SELECT
    USING (clinician_id = auth.uid());

-- Cohort_Member Table RLS Policies

-- Cohort owners can manage their own cohort memberships
CREATE POLICY "Cohort owner can manage users in their cohort"
    ON cohort_member
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM cohort
            WHERE cohort.id = cohort_member.cohort_id
              AND cohort.clinician_id = auth.uid()
        )
    );

-- Prevent regular users from accessing cohort memberships
CREATE POLICY "No access for users to cohort memberships"
    ON cohort_member
    FOR ALL
    USING (false);

-- Diary Table RLS Policies

-- Users can access their own diaries
CREATE POLICY "Users can access their own diaries"
    ON diary
    FOR SELECT
    USING (patient_id = auth.uid());

-- Users can insert their own diaries
CREATE POLICY "Users can insert their own diaries"
    ON diary
    FOR INSERT
    WITH CHECK (patient_id = auth.uid());

-- Users can update their own diaries
CREATE POLICY "Users can update their own diaries"
    ON diary
    FOR UPDATE
    USING (patient_id = auth.uid());

-- Clinicians can access diaries of users in their cohorts
CREATE POLICY "Clinicians can access diaries of users in their cohorts"
    ON diary
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM cohort_member cm
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE cm.patient_id = diary.patient_id
              AND c.clinician_id = auth.uid()
        )
    );

-- Clinicians can insert diaries for users in their cohorts
CREATE POLICY "Clinicians can insert diaries for users in their cohorts"
    ON diary
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM cohort_member cm
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE cm.patient_id = diary.patient_id
              AND c.clinician_id = auth.uid()
        )
    );

-- Clinicians can update diaries of users in their cohorts
CREATE POLICY "Clinicians can update diaries of users in their cohorts"
    ON diary
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM cohort_member cm
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE cm.patient_id = diary.patient_id
              AND c.clinician_id = auth.uid()
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
              AND diary.patient_id = auth.uid()
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
              AND diary.patient_id = auth.uid()
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
              AND diary.patient_id = auth.uid()
        )
    );

-- Clinicians can access aspects of users in their cohorts' diaries
CREATE POLICY "Clinicians can access aspects of users in their cohorts' diaries"
    ON aspect
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_member cm ON cm.patient_id = diary.patient_id
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE diary.id = aspect.diary_id
              AND c.clinician_id = auth.uid()
        )
    );

-- Clinicians can insert aspects in users' cohorts' diaries
CREATE POLICY "Clinicians can insert aspects in users' cohorts' diaries"
    ON aspect
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_member cm ON cm.patient_id = diary.patient_id
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE diary.id = aspect.diary_id
              AND c.clinician_id = auth.uid()
        )
    );

-- Clinicians can update aspects in users' cohorts' diaries
CREATE POLICY "Clinicians can update aspects in users' cohorts' diaries"
    ON aspect
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_member cm ON cm.patient_id = diary.patient_id
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE diary.id = aspect.diary_id
              AND c.clinician_id = auth.uid()
        )
    );

-- Entry Table RLS Policies

-- Users can access their own entries
CREATE POLICY "Users can access their own entries"
    ON entry
    FOR SELECT
    USING (patient_id = auth.uid());

-- Users can insert their own entries
CREATE POLICY "Users can insert their own entries"
    ON entry
    FOR INSERT
    WITH CHECK (patient_id = auth.uid());

-- Users can update their own entries
CREATE POLICY "Users can update their own entries"
    ON entry
    FOR UPDATE
    USING (patient_id = auth.uid());

-- Users can delete their own entries
CREATE POLICY "Users can delete their own entries"
    ON entry
    FOR DELETE
    USING (patient_id = auth.uid());

-- Clinicians can access entries of users in their cohorts' diaries
CREATE POLICY "Clinicians can access entries of users in their cohorts' diaries"
    ON entry
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_member cm ON cm.patient_id = diary.patient_id
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE diary.id = entry.diary_id
              AND c.clinician_id = auth.uid()
        )
    );

-- Clinicians can insert entries for users in their cohorts' diaries
CREATE POLICY "Clinicians can insert entries for users in their cohorts' diaries"
    ON entry
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_member cm ON cm.patient_id = diary.patient_id
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE diary.id = entry.diary_id
              AND c.clinician_id = auth.uid()
        )
    );

-- Clinicians can update entries of users in their cohorts' diaries
CREATE POLICY "Clinicians can update entries of users in their cohorts' diaries"
    ON entry
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_member cm ON cm.patient_id = diary.patient_id
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE diary.id = entry.diary_id
              AND c.clinician_id = auth.uid()
        )
    );

-- Clinicians can delete entries of users in their cohorts' diaries
CREATE POLICY "Clinicians can delete entries of users in their cohorts' diaries"
    ON entry
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM diary
            JOIN cohort_member cm ON cm.patient_id = diary.patient_id
            JOIN cohort c ON cm.cohort_id = c.id
            WHERE diary.id = entry.diary_id
              AND c.clinician_id = auth.uid()
        )
    );

-- 7. Create Indexes for Performance Optimization

-- Indexes for cohort_member
CREATE INDEX IF NOT EXISTS idx_cohort_member_cohort_id ON cohort_member(cohort_id);
CREATE INDEX IF NOT EXISTS idx_cohort_member_patient_id ON cohort_member(patient_id);

-- Index for diary
CREATE INDEX IF NOT EXISTS idx_diary_patient_id ON diary(patient_id);

-- Index for aspect
CREATE INDEX IF NOT EXISTS idx_aspect_diary_id ON aspect(diary_id);

-- Index for entry
CREATE INDEX IF NOT EXISTS idx_entry_aspect_id ON entry(aspect_id);
CREATE INDEX IF NOT EXISTS idx_entry_diary_id ON entry(diary_id);
CREATE INDEX IF NOT EXISTS idx_entry_patient_id ON entry(patient_id);

-- Only grant permissions for public schema
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;