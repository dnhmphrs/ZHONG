import { writable } from 'svelte/store';
import { getCohorts, getCohortPatients, getAllPatients } from '../backend/api/clinician';
import { supabase } from '$lib/backend/supabase';
import { api } from './api';

function createClinicianStore() {
    const { subscribe, set, update } = writable({
        cohorts: [],
        selectedCohort: null,
        patients: [],
        selectedPatient: null,
        entries: [],
        allPatients: [],
        loading: false,
        error: null
    });

    return {
        subscribe,
        loadAllPatients: async () => {
            update(s => ({ ...s, loading: true }));
            try {
                const patients = await getAllPatients();
                console.log('Loaded patients:', patients);
                update(s => ({ ...s, allPatients: patients || [], loading: false }));
            } catch (error) {
                console.error('Error loading patients:', error);
                update(s => ({ ...s, error, loading: false, allPatients: [] }));
            }
        },
        loadCohorts: async () => {
            update(s => ({ ...s, loading: true }));
            try {
                const cohorts = await getCohorts();
                update(s => ({ ...s, cohorts, loading: false }));
            } catch (error) {
                update(s => ({ ...s, error, loading: false }));
            }
        },
        selectCohort: async (cohort) => {
            update(s => ({ ...s, loading: true, selectedCohort: cohort }));
            try {
                const patients = await getCohortPatients(cohort.id);
                update(s => ({ ...s, patients, loading: false }));
            } catch (error) {
                update(s => ({ ...s, error, loading: false }));
            }
        },
        selectPatient: async (patient) => {
            console.log('Selecting patient:', patient);
            update(s => ({ ...s, loading: true, selectedPatient: patient }));
            try {
                // Get the most recent date that has entries
                const { data: latestEntry } = await supabase
                    .from('entry')
                    .select('entry_date')
                    .eq('patient_id', patient.id)
                    .order('entry_date', { ascending: false })
                    .limit(1);
                
                const selectedDate = latestEntry?.[0]?.entry_date 
                    ? new Date(latestEntry[0].entry_date)
                    : new Date();

                console.log('Date being queried:', {
                    full: selectedDate,
                    formatted: selectedDate.toISOString().split('T')[0],
                    latestEntry
                });

                const entries = await api.getClinicianPatientEntries(patient.id, selectedDate);
                console.log('Got entries:', entries);
                update(s => ({ ...s, entries, loading: false }));
            } catch (error) {
                console.error('Error in selectPatient:', error);
                update(s => ({ ...s, error, loading: false }));
            }
        }
    };
}

export const clinicianStore = createClinicianStore(); 