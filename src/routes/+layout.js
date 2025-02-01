import { browser } from '$app/environment';
import { supabase } from '$lib/backend/supabase';

export const prerender = false;  // Explicitly disable prerendering

export const load = async () => {
    return { 
        session: null, 
        initialized: false 
    };
};
