import { writable } from 'svelte/store';
import { auth } from './auth';
import { get } from 'svelte/store';
import { api } from './api';

function createDiaryStore() {
    const { subscribe, set, update } = writable({
        aspects: [],
        entries: [],
        loading: false
    });

    return {
        subscribe,
        loadAspects: async () => {
            update(s => ({ ...s, loading: true }));
            const aspects = await api.getPatientAspects(get(auth).session.user.id);
            update(s => ({ ...s, aspects, loading: false }));
        },
        loadEntries: async (date) => {
            console.log('Loading entries for date:', date);
            update(s => ({ ...s, loading: true }));
            try {
                const entries = await api.getPatientEntries(get(auth).session.user.id, date);
                console.log('Got entries:', entries);
                update(s => ({ ...s, entries, loading: false }));
            } catch (error) {
                console.error('Error loading entries:', error);
                update(s => ({ ...s, error, loading: false }));
            }
        },
        createEntry: async (aspect) => {
            // Implementation for creating new entries
            // This will be implemented when we work on the entry form
        }
    };
}

export const diaryStore = createDiaryStore(); 