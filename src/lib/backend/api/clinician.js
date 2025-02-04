import { supabase } from '../supabase';

export async function getCohorts() {
    const { data: cohorts, error } = await supabase
        .from('cohort')
        .select('*')
        .order('created_at', { ascending: false });
    
    if (error) throw error;
    return cohorts;
}

export async function getCohortPatients(cohortId) {
    const { data, error } = await supabase
        .from('cohort_member')
        .select(`
            patient:patient_id (
                id,
                name,
                email,
                role
            )
        `)
        .eq('cohort_id', cohortId);
    
    if (error) throw error;
    return data.map(d => d.patient);
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

export async function getAllPatients() {
    const { data, error } = await supabase
        .from('cohort_member')
        .select(`
            cohort:cohort_id (
                name,
                clinician_id
            ),
            patient:patient_id (
                id,
                name,
                email,
                role
            )
        `)
        .eq('cohort.clinician_id', (await supabase.auth.getUser()).data.user.id)
        .order('patient_id->name');
    
    if (error) throw error;
    console.log('Raw patient data:', data); // Debug log
    
    // Deduplicate patients and add their cohort info
    const patientsMap = new Map();
    data.forEach(({ cohort, patient }) => {
        if (!patientsMap.has(patient.id)) {
            patientsMap.set(patient.id, {
                ...patient,
                cohorts: [cohort.name]
            });
        } else {
            patientsMap.get(patient.id).cohorts.push(cohort.name);
        }
    });
    
    const patients = Array.from(patientsMap.values());
    console.log('Processed patients:', patients); // Debug log
    return patients;
} 