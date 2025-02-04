-- Clean up existing data in correct order
DELETE FROM entry;
DELETE FROM diary_aspect;
DELETE FROM diary;
DELETE FROM aspect;
DELETE FROM cohort_member;
DELETE FROM cohort;
DELETE FROM profile;

-- Create profile for Dan
INSERT INTO profile (id, role, name, email)
SELECT 
    id,
    'clinician',
    'Dan',
    email
FROM auth.users 
WHERE email = 'dan@aufbau.io';

-- Create dummy patients
INSERT INTO profile (id, role, name, email) VALUES
    ('10000000-0000-0000-0000-000000000001', 'patient', 'Sarah Johnson', 'sarah.j@example.com'),
    ('20000000-0000-0000-0000-000000000002', 'patient', 'Michael Chen', 'michael.c@example.com'),
    ('30000000-0000-0000-0000-000000000003', 'patient', 'Emma Wilson', 'emma.w@example.com'),
    ('40000000-0000-0000-0000-000000000004', 'patient', 'James Brown', 'james.b@example.com'),
    ('50000000-0000-0000-0000-000000000005', 'patient', 'Olivia Davis', 'olivia.d@example.com');

-- Create a cohort owned by Dan
-- Create cohorts with Dan as clinician
INSERT INTO cohort (id, name, description, clinician_id) VALUES
    ('11000000-0000-0000-0000-000000000001', 'Depression Study Group A', 'Primary intervention group for depression study', (SELECT id FROM profile WHERE email = 'dan@aufbau.io')),
    ('22000000-0000-0000-0000-000000000002', 'Anxiety Management', 'CBT-focused anxiety management group', (SELECT id FROM profile WHERE email = 'dan@aufbau.io'));

-- Add patients to cohorts
INSERT INTO cohort_member (cohort_id, patient_id) VALUES
    ('11000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001'),
    ('11000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002'),
    ('11000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003'),
    ('22000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000004'),
    ('22000000-0000-0000-0000-000000000002', '50000000-0000-0000-0000-000000000005'),
    ('22000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002');  -- Michael is in both groups

-- Create a diary for dan
INSERT INTO diary (id, patient_id, name, description, start_date, end_date) VALUES
    ('d0000000-0000-0000-0000-000000000000', (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), 'Daily Check-in', 'Track your daily mood and activities', CURRENT_DATE, NULL);

-- Create diaries for patients
INSERT INTO diary (id, patient_id, name, description, start_date, end_date) VALUES
    ('11110000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Depression Management', 'Daily mood and activity tracking', CURRENT_DATE - 30, NULL),
    ('22220000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', 'Depression Management', 'Daily mood and activity tracking', CURRENT_DATE - 25, NULL),
    ('33330000-0000-0000-0000-000000000003', '30000000-0000-0000-0000-000000000003', 'Depression Management', 'Daily mood and activity tracking', CURRENT_DATE - 20, NULL),
    ('44440000-0000-0000-0000-000000000004', '40000000-0000-0000-0000-000000000004', 'Anxiety Management', 'Daily anxiety and trigger tracking', CURRENT_DATE - 15, NULL),
    ('55550000-0000-0000-0000-000000000005', '50000000-0000-0000-0000-000000000005', 'Anxiety Management', 'Daily anxiety and trigger tracking', CURRENT_DATE - 10, NULL);

-- Create base aspects
INSERT INTO aspect (id, diary_id, name, frequency_days, data_type, display_order) VALUES
    (1, 'd0000000-0000-0000-0000-000000000000', 'Sleep Quality', 1, 'scale', 1),
    (2, 'd0000000-0000-0000-0000-000000000000', 'Mood', 1, 'scale', 2),
    (3, 'd0000000-0000-0000-0000-000000000000', 'Energy Level', 1, 'scale', 3),
    (4, 'd0000000-0000-0000-0000-000000000000', 'Anxiety Level', 1, 'scale', 4),
    (5, 'd0000000-0000-0000-0000-000000000000', 'Physical Activity', 1, 'scale', 5),
    (6, 'd0000000-0000-0000-0000-000000000000', 'Social Interaction', 1, 'scale', 6),
    (7, 'd0000000-0000-0000-0000-000000000000', 'Notes', 1, 'text', 7),
    (8, 'd0000000-0000-0000-0000-000000000000', 'Medication Adherence', 1, 'scale', 8),
    (9, 'd0000000-0000-0000-0000-000000000000', 'Side Effects', 1, 'text', 9),
    (10, 'd0000000-0000-0000-0000-000000000000', 'Goals', 1, 'text', 10);

-- Associate aspects with the diary
INSERT INTO diary_aspect (diary_id, aspect_id) VALUES
    ('d0000000-0000-0000-0000-000000000000', 1),
    ('d0000000-0000-0000-0000-000000000000', 2),
    ('d0000000-0000-0000-0000-000000000000', 3),
    ('d0000000-0000-0000-0000-000000000000', 4),
    ('d0000000-0000-0000-0000-000000000000', 5),
    ('d0000000-0000-0000-0000-000000000000', 6),
    ('d0000000-0000-0000-0000-000000000000', 7),
    ('d0000000-0000-0000-0000-000000000000', 8),
    ('d0000000-0000-0000-0000-000000000000', 9),
    ('d0000000-0000-0000-0000-000000000000', 10);

-- Insert diary entries
INSERT INTO entry (diary_id, aspect_id, patient_id, entry_date, content_scale, content_text) VALUES
    ('d0000000-0000-0000-0000-000000000000', 1, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, 7, NULL),
    ('d0000000-0000-0000-0000-000000000000', 2, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, 8, NULL),
    ('d0000000-0000-0000-0000-000000000000', 3, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, 6, NULL),
    ('d0000000-0000-0000-0000-000000000000', 4, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, 3, NULL),
    ('d0000000-0000-0000-0000-000000000000', 5, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, 7, NULL),
    ('d0000000-0000-0000-0000-000000000000', 6, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, 8, NULL),
    ('d0000000-0000-0000-0000-000000000000', 7, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, NULL, 'Feeling pretty good today, got a lot done.'),
    ('d0000000-0000-0000-0000-000000000000', 8, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, 9, NULL),
    ('d0000000-0000-0000-0000-000000000000', 9, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, NULL, 'No significant side effects'),
    ('d0000000-0000-0000-0000-000000000000', 10, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE, NULL, 'Complete project milestones');

-- Add entries for yesterday
INSERT INTO entry (diary_id, aspect_id, patient_id, entry_date, content_scale, content_text) VALUES
    ('d0000000-0000-0000-0000-000000000000', 1, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE - 1, 6, NULL),
    ('d0000000-0000-0000-0000-000000000000', 2, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE - 1, 7, NULL),
    ('d0000000-0000-0000-0000-000000000000', 3, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE - 1, 7, NULL),
    ('d0000000-0000-0000-0000-000000000000', 4, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE - 1, 4, NULL),
    ('d0000000-0000-0000-0000-000000000000', 7, (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), CURRENT_DATE - 1, NULL, 'Productive day at work');

-- Add example entries for patients
-- Sarah Johnson (Depression Study) - High compliance
INSERT INTO entry (diary_id, aspect_id, patient_id, entry_date, content_scale, content_text) VALUES
    ('11110000-0000-0000-0000-000000000001', 1, '10000000-0000-0000-0000-000000000001', CURRENT_DATE - 1, 7, NULL),
    ('11110000-0000-0000-0000-000000000001', 2, '10000000-0000-0000-0000-000000000001', CURRENT_DATE - 1, 6, NULL),
    ('11110000-0000-0000-0000-000000000001', 3, '10000000-0000-0000-0000-000000000001', CURRENT_DATE - 1, 7, NULL),
    ('11110000-0000-0000-0000-000000000001', 7, '10000000-0000-0000-0000-000000000001', CURRENT_DATE - 1, NULL, 'Feeling more positive today, therapy techniques are helping'),
    ('11110000-0000-0000-0000-000000000001', 1, '10000000-0000-0000-0000-000000000001', CURRENT_DATE - 2, 6, NULL),
    ('11110000-0000-0000-0000-000000000001', 2, '10000000-0000-0000-0000-000000000001', CURRENT_DATE - 2, 5, NULL),
    ('11110000-0000-0000-0000-000000000001', 3, '10000000-0000-0000-0000-000000000001', CURRENT_DATE - 2, 6, NULL);

-- Michael Chen (In both groups) - Medium compliance
INSERT INTO entry (diary_id, aspect_id, patient_id, entry_date, content_scale, content_text) VALUES
    ('22220000-0000-0000-0000-000000000002', 1, '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 1, 5, NULL),
    ('22220000-0000-0000-0000-000000000002', 2, '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 1, 4, NULL),
    ('22220000-0000-0000-0000-000000000002', 7, '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 1, NULL, 'Struggling with work stress'),
    ('22220000-0000-0000-0000-000000000002', 1, '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 3, 6, NULL),
    ('22220000-0000-0000-0000-000000000002', 2, '20000000-0000-0000-0000-000000000002', CURRENT_DATE - 3, 5, NULL);

-- Emma Wilson (Depression Study) - Recent starter, good compliance
INSERT INTO entry (diary_id, aspect_id, patient_id, entry_date, content_scale, content_text) VALUES
    ('33330000-0000-0000-0000-000000000003', 1, '30000000-0000-0000-0000-000000000003', CURRENT_DATE - 1, 8, NULL),
    ('33330000-0000-0000-0000-000000000003', 2, '30000000-0000-0000-0000-000000000003', CURRENT_DATE - 1, 7, NULL),
    ('33330000-0000-0000-0000-000000000003', 3, '30000000-0000-0000-0000-000000000003', CURRENT_DATE - 1, 8, NULL),
    ('33330000-0000-0000-0000-000000000003', 7, '30000000-0000-0000-0000-000000000003', CURRENT_DATE - 1, NULL, 'Started new exercise routine, feeling better');

-- James Brown (Anxiety Management) - Sporadic compliance
INSERT INTO entry (diary_id, aspect_id, patient_id, entry_date, content_scale, content_text) VALUES
    ('44440000-0000-0000-0000-000000000004', 1, '40000000-0000-0000-0000-000000000004', CURRENT_DATE - 1, 4, NULL),
    ('44440000-0000-0000-0000-000000000004', 2, '40000000-0000-0000-0000-000000000004', CURRENT_DATE - 1, 3, NULL),
    ('44440000-0000-0000-0000-000000000004', 7, '40000000-0000-0000-0000-000000000004', CURRENT_DATE - 1, NULL, 'High anxiety day, used breathing exercises'),
    ('44440000-0000-0000-0000-000000000004', 1, '40000000-0000-0000-0000-000000000004', CURRENT_DATE - 5, 6, NULL),
    ('44440000-0000-0000-0000-000000000004', 2, '40000000-0000-0000-0000-000000000004', CURRENT_DATE - 5, 5, NULL);

-- Olivia Davis (Anxiety Management) - New starter
INSERT INTO entry (diary_id, aspect_id, patient_id, entry_date, content_scale, content_text) VALUES
    ('55550000-0000-0000-0000-000000000005', 1, '50000000-0000-0000-0000-000000000005', CURRENT_DATE - 1, 5, NULL),
    ('55550000-0000-0000-0000-000000000005', 2, '50000000-0000-0000-0000-000000000005', CURRENT_DATE - 1, 4, NULL),
    ('55550000-0000-0000-0000-000000000005', 7, '50000000-0000-0000-0000-000000000005', CURRENT_DATE - 1, NULL, 'First week of tracking, getting used to the routine');
