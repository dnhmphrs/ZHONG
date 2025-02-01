// src/lib/backend/supabaseClient.js
import { createClient } from '@supabase/supabase-js';
import { browser } from '$app/environment';

export const supabase = createClient(
    import.meta.env.VITE_SUPABASE_URL,
    import.meta.env.VITE_SUPABASE_ANON_KEY,
    {
        auth: {
            persistSession: true,
            storage: browser ? window.localStorage : undefined
        }
    }
);

// Set up auth state change handler
if (browser) {
    supabase.auth.onAuthStateChange((event, session) => {
        if (session?.access_token) {
            document.cookie = `sb-auth-token=${session.access_token}; path=/; max-age=3600`;
        } else {
            document.cookie = 'sb-auth-token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
        }
    });
}
