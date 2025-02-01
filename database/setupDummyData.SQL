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

-- Create a diary for dan
INSERT INTO diary (id, patient_id, name, description, start_date, end_date) VALUES
    ('d0000000-0000-0000-0000-000000000000', (SELECT id FROM auth.users WHERE email = 'dan@aufbau.io'), 'Daily Journal', 'Personal wellness tracking', CURRENT_DATE - 30, NULL);

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
