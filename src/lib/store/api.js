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

    async getPatientEntries(patientId, date, startDate = null) {
        // For patient's own view - gets entries through diary
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
        const formattedStartDate = startDate?.toISOString().split('T')[0];
        
        let query = supabase
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
            .eq('diary_id', diary.id);

        if (startDate) {
            // For trends, get all entries in date range
            query = query
                .gte('entry_date', formattedStartDate)
                .lte('entry_date', formattedDate)
                .order('entry_date', { ascending: false });
        } else {
            // For single day, get entries for just that day
            query = query
                .eq('entry_date', formattedDate)
                .eq('diary_id', diary.id);  // Ensure we only get entries for this diary
        }
        
        const { data: entries, error } = await query;
        
        if (error) {
            console.error('Error loading entries:', error);
            return [];
        }
        
        console.log(`API: Got ${entries.length} entries for ${startDate ? 'range' : 'single day'}:`, {
            date: formattedDate,
            startDate: formattedStartDate,
            entriesCount: entries.length
        });
        
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