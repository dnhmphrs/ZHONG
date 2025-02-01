import { supabase } from './supabase';

// Authentication & User Management
export async function signInUser(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password
    });
    return { data, error };
}

export async function signUpUser(name, email, password) {
    // First create the auth user
    const { data: authData, error: authError } = await supabase.auth.signUp({
        email,
        password
    });
    
    if (authError) return { error: authError };

    // Then create the user profile
    const { data, error } = await supabase
        .from('user')
        .insert([{ id: authData.user.id, name, email, password }]);

    return { data, error };
}

export async function signInClinician(email, password) {
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email,
        password
    });
    
    if (authError) return { error: authError };

    // Verify the user is actually a clinician
    const { data, error } = await supabase
        .from('clinician')
        .select('*')
        .eq('id', authData.user.id)
        .single();

    return { data, error };
}

export async function signOut() {
    const { error } = await supabase.auth.signOut();
    return { error };
}

// Cohort Management
export async function createCohort(name, description) {
    const { data, error } = await supabase
        .from('cohort')
        .insert([{ name, description }]);
    return { data, error };
}

export async function getCohorts() {
    const { data, error } = await supabase
        .from('cohort')
        .select('*');
    return { data, error };
}

export async function addUserToCohort(cohortId, userId) {
    const { data, error } = await supabase
        .from('cohort_user')
        .insert([{ cohort_id: cohortId, user_id: userId }]);
    return { data, error };
}

export async function addClinicianToCohort(cohortId, clinicianId) {
    const { data, error } = await supabase
        .from('cohort_clinician')
        .insert([{ cohort_id: cohortId, clinician_id: clinicianId }]);
    return { data, error };
}

// Diary Management
export async function createDiary(userId, name, description, durationDays = null) {
    const { data, error } = await supabase
        .from('diary')
        .insert([{ 
            user_id: userId,
            name,
            description,
            duration_days: durationDays
        }]);
    return { data, error };
}

export async function getDiaries(userId) {
    const { data, error } = await supabase
        .from('diary')
        .select('*')
        .eq('user_id', userId);
    return { data, error };
}

// Aspect Management
export async function createAspect(diaryId, name, frequencyDays, dataType, displayOrder = 0) {
    const { data, error } = await supabase
        .from('aspect')
        .insert([{
            diary_id: diaryId,
            name,
            frequency_days: frequencyDays,
            data_type: dataType,
            display_order: displayOrder
        }]);
    return { data, error };
}

export async function getAspects(diaryId) {
    const { data, error } = await supabase
        .from('aspect')
        .select('*')
        .eq('diary_id', diaryId)
        .order('display_order');
    return { data, error };
}

// Entry Management
export async function createEntry(aspectId, diaryId, userId, entryDate, content) {
    const { data: aspectData, error: aspectError } = await supabase
        .from('aspect')
        .select('data_type')
        .eq('id', aspectId)
        .single();

    if (aspectError) return { error: aspectError };

    const entryData = {
        aspect_id: aspectId,
        diary_id: diaryId,
        user_id: userId,
        entry_date: entryDate,
        content_text: aspectData.data_type === 'text' ? content : null,
        content_scale: aspectData.data_type === 'scale' ? content : null
    };

    const { data, error } = await supabase
        .from('entry')
        .insert([entryData]);

    return { data, error };
}

export async function getEntries(diaryId, userId, startDate, endDate) {
    const query = supabase
        .from('entry')
        .select(`
            *,
            aspect:aspect_id (
                name,
                data_type,
                frequency_days
            )
        `)
        .eq('diary_id', diaryId)
        .eq('user_id', userId);

    if (startDate) query.gte('entry_date', startDate);
    if (endDate) query.lte('entry_date', endDate);

    const { data, error } = await query;
    return { data, error };
}

export async function updateEntry(entryId, content) {
    const { data: entryData, error: fetchError } = await supabase
        .from('entry')
        .select('aspect:aspect_id(data_type)')
        .eq('id', entryId)
        .single();

    if (fetchError) return { error: fetchError };

    const updateData = {
        content_text: entryData.aspect.data_type === 'text' ? content : null,
        content_scale: entryData.aspect.data_type === 'scale' ? content : null,
        updated_at: new Date().toISOString()
    };

    const { data, error } = await supabase
        .from('entry')
        .update(updateData)
        .eq('id', entryId);

    return { data, error };
}

export async function deleteEntry(entryId) {
    const { data, error } = await supabase
        .from('entry')
        .delete()
        .eq('id', entryId);
    return { data, error };
}