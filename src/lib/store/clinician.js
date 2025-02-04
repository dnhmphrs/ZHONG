import { writable } from 'svelte/store';
import { getCohorts, getCohortPatients, getPatientEntries, getAllPatients } from '../backend/api/clinician';

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
                update(s => ({ ...s, allPatients: patients, loading: false }));
            } catch (error) {
                update(s => ({ ...s, error, loading: false }));
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
            update(s => ({ ...s, loading: true, selectedPatient: patient }));
            try {
                const thirtyDaysAgo = new Date();
                thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
                
                const entries = await getPatientEntries(
                    patient.id,
                    thirtyDaysAgo.toISOString().split('T')[0],
                    new Date().toISOString().split('T')[0]
                );
                update(s => ({ ...s, entries, loading: false }));
            } catch (error) {
                update(s => ({ ...s, error, loading: false }));
            }
        }
    };
}

export const clinicianStore = createClinicianStore(); 