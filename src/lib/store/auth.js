import { writable } from 'svelte/store';
import { supabase } from '$lib/backend/supabase';

function createAuthStore() {
    const { subscribe, set: setStore } = writable({ session: null, profile: null });

    return {
        subscribe,
        set: (value) => setStore(value),
        initialize: async () => {
            const { data: { session } } = await supabase.auth.getSession();
            if (session) {
                const { data: profile } = await supabase
                    .from('profile')
                    .select('role')
                    .eq('id', session.user.id)
                    .single();
                    
                setStore({ session, profile });
            }
        }
    };
}

export const auth = createAuthStore(); 