import { supabase } from '../supabase';

export async function getAllPatients() {
    const { data: patients, error } = await supabase
        .from('profile')
        .select(`
            id,
            name,
            email,
            diary (
                id,
                name
            ),
            cohort_member!patient_id (
                cohort:cohort_id (
                    name
                )
            )
        `)
        .eq('role', 'patient');

    if (error) {
        console.error('Error loading patients:', error);
        throw error;
    }

    // Transform the data to include cohorts array
    const patientsWithCohorts = patients?.map(patient => ({
        ...patient,
        cohorts: patient.cohort_member?.map(cm => cm.cohort.name) || []
    })) || [];

    console.log('API response:', patientsWithCohorts);
    return patientsWithCohorts;
}

export async function getCohorts() {
    const { data: cohorts, error } = await supabase
        .from('cohort')
        .select('*');

    if (error) {
        console.error('Error loading cohorts:', error);
        throw error;
    }

    return cohorts;
}

export async function getCohortPatients(cohortId) {
    const { data: patients, error } = await supabase
        .from('cohort_member')
        .select(`
            patient:profile (
                id,
                name,
                email,
                diary (
                    id,
                    name
                )
            )
        `)
        .eq('cohort_id', cohortId);

    if (error) {
        console.error('Error loading cohort patients:', error);
        throw error;
    }

    return patients.map(p => p.patient);
}

export async function getPatientEntries(patientId, startDate, endDate) {
    const { data, error } = await supabase
        .from('entry')
        .select(`
            *,
            aspect:aspect_id (
                name,
                data_type
            )
        `)
        .eq('patient_id', patientId)
        .gte('entry_date', startDate)
        .lte('entry_date', endDate)
        .order('entry_date', { ascending: false });
    
    if (error) throw error;
    return data;
} 