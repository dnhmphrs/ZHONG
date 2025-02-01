import { browser } from '$app/environment';
import { supabase } from '$lib/backend/supabase';
import { auth } from '$lib/store/auth';

export const prerender = false;  // Explicitly disable prerendering

export const load = async () => {
    if (browser) {
        await auth.initializeAuth();
    }
    return { 
        session: null, 
        initialized: false 
    };
};
