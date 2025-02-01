-- 8. Create Initial Test Users

-- First, ensure the extensions we need are enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Function to create a test user with auth and profile
CREATE OR REPLACE FUNCTION create_test_user(
    _email TEXT,
    _password TEXT,
    _name TEXT,
    _role TEXT
) RETURNS UUID AS $$
DECLARE
    _user_id UUID;
BEGIN
    -- Insert into auth.users
    INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        raw_user_meta_data,
        created_at,
        updated_at
    )
    VALUES (
        '00000000-0000-0000-0000-000000000000',
        uuid_generate_v4(),
        'authenticated',
        'authenticated',
        _email,
        crypt(_password, gen_salt('bf')),
        now(),
        jsonb_build_object(
            'name', _name,
            'role', _role
        ),
        now(),
        now()
    )
    RETURNING id INTO _user_id;
    
    RETURN _user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create profiles and related data
DO $$ 
DECLARE
    dan_id UUID;
    dr_smith_id UUID;
    patient1_id UUID;
    patient2_id UUID;
    patient3_id UUID;
    anxiety_cohort_id UUID;
    depression_cohort_id UUID;
    diary1_id UUID;
    diary2_id UUID;
    mood_aspect_id UUID;
    sleep_aspect_id UUID;
    anxiety_aspect_id UUID;
BEGIN
    -- Get Dan's auth user ID
    SELECT id INTO dan_id 
    FROM auth.users 
    WHERE email = 'dan@aufbau.io';

    IF dan_id IS NULL THEN
        RAISE EXCEPTION 'User with email dan@aufbau.io not found in auth.users';
    END IF;

    -- Create profile
    INSERT INTO profile (id, role, name, email) VALUES
        (dan_id, 'clinician', 'Dan', 'dan@aufbau.io');

    -- Create cohorts for Dan
    INSERT INTO cohort (name, description, clinician_id) VALUES
        ('Anxiety Study Group', 'Participants in the 2024 anxiety study', dan_id),
        ('Depression Study Group', 'Long-term depression study participants', dan_id),
        ('Control Group', 'Control group for comparative studies', dan_id);

    -- Get cohort IDs for later use
    SELECT id INTO anxiety_cohort_id FROM cohort WHERE name = 'Anxiety Study Group';
    SELECT id INTO depression_cohort_id FROM cohort WHERE name = 'Depression Study Group';

    -- Create test diary data (only after you've created the actual users through auth)
    -- Example structure for when you have the patient IDs:
    /*
    -- Add patients to cohorts
    INSERT INTO cohort_member (cohort_id, patient_id) VALUES
        (anxiety_cohort_id, patient1_id),
        (anxiety_cohort_id, patient2_id),
        (depression_cohort_id, patient3_id);

    -- Create diaries for patients
    INSERT INTO diary (patient_id, name, description, duration_days)
    VALUES 
        (patient1_id, 'Anxiety Journal', 'Daily anxiety tracking', 30)
    RETURNING id INTO diary1_id;
    */

END $$;

-- Clean up
DROP FUNCTION create_test_user;
