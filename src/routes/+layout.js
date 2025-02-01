import { browser } from '$app/environment';
import { supabase } from '$lib/backend/supabase';

// since there's no dynamic data here, we can prerender
// it so that it gets served as a static asset in production
export const prerender = true;

export const load = async () => {
    return { 
        session: null, 
        initialized: false 
    };
};
