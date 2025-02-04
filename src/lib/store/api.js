import { supabase } from '$lib/backend/supabase';

export const api = {
    async getPatientAspects(patientId) {
        // First get the patient's diary
        const { data: diary, error: diaryError } = await supabase
            .from('diary')
            .select('id')
            .eq('patient_id', patientId)
            .single();

        if (diaryError) {
            console.error('Error loading diary:', diaryError);
            return [];
        }

        const { data: aspects, error } = await supabase
            .from('aspect')
            .select(`
                id,
                name,
                data_type
            `)
            .eq('diary_id', diary.id)
            .order('name');
        
        if (error) {
            console.error('Error loading aspects:', error);
            return [];
        }
        
        return aspects;
    },

    async getPatientEntries(patientId, date) {
        // For patient's own view - gets entries through diary
        // First get the diary id
        const { data: diary, error: diaryError } = await supabase
            .from('diary')
            .select('id')
            .eq('patient_id', patientId)
            .single();

        if (diaryError) {
            console.error('Error loading diary:', diaryError);
            return [];
        }

        const formattedDate = date.toISOString().split('T')[0];
        
        const { data: entries, error } = await supabase
            .from('entry')
            .select(`
                id,
                entry_date,
                content_text,
                content_scale,
                aspect:aspect (
                    id,
                    name,
                    data_type
                )
            `)
            .eq('diary_id', diary.id)
            .eq('entry_date', formattedDate);
        
        if (error) {
            console.error('Error loading entries:', error);
            return [];
        }
        
        return entries;
    },

    async getClinicianPatientEntries(patientId, date) {
        console.log('API: Getting entries for patient:', patientId);
        const formattedDate = date.toISOString().split('T')[0];
        const thirtyDaysAgo = new Date(date);
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const formattedThirtyDaysAgo = thirtyDaysAgo.toISOString().split('T')[0];
        
        console.log('API: Fetching date range:', {
            from: formattedThirtyDaysAgo,
            to: formattedDate
        });

        const { data: entries, error } = await supabase
            .from('entry')
            .select(`
                id,
                diary_id,
                patient_id,
                entry_date,
                content_text,
                content_scale,
                aspect:aspect (
                    name,
                    data_type
                )
            `)
            .eq('patient_id', patientId)
            .gte('entry_date', formattedThirtyDaysAgo)
            .lte('entry_date', formattedDate)
            .order('entry_date', { ascending: false });

        console.log('API response:', { 
            entries: entries?.map(e => ({
                date: e.entry_date,
                aspect: e.aspect?.name,
                scale: e.content_scale
            })),
            error 
        });

        if (error) {
            console.error('API: Error fetching entries:', error);
            throw error;
        }

        return entries;
    }
}; 