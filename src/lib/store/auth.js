import { writable } from 'svelte/store';
import { supabase } from '$lib/backend/supabase';
import { goto } from '$app/navigation';

function createAuthStore() {
    const { subscribe, set, update } = writable({
        session: null,
        profile: null,
        viewPreference: null,
        initialized: false
    });

    let authListener;

    async function initializeAuth() {
        try {
            const { data: { session } } = await supabase.auth.getSession();
            
            if (!session) {
                set({ session: null, profile: null, viewPreference: null, initialized: true });
                return;
            }

            const { data: profile } = await supabase
                .from('profile')
                .select('role')
                .eq('id', session.user.id)
                .single();

            // Get stored view preference if clinician
            let viewPreference = null;
            if (profile.role === 'clinician') {
                viewPreference = typeof localStorage !== 'undefined' 
                    ? localStorage.getItem('viewPreference') || 'personal'
                    : 'personal';
            }

            set({
                session,
                profile,
                viewPreference,
                initialized: true
            });

            // Set up auth state change listener only once
            if (!authListener) {
                authListener = supabase.auth.onAuthStateChange(async (event, newSession) => {
                    if (event === 'SIGNED_OUT') {
                        set({ session: null, profile: null, viewPreference: null, initialized: true });
                        return;
                    }

                    if (newSession) {
                        const { data: newProfile } = await supabase
                            .from('profile')
                            .select('role')
                            .eq('id', newSession.user.id)
                            .single();

                        // Get stored view preference if clinician
                        let newViewPreference = null;
                        if (newProfile.role === 'clinician') {
                            newViewPreference = typeof localStorage !== 'undefined'
                                ? localStorage.getItem('viewPreference') || 'personal'
                                : 'personal';
                        }

                        set({
                            session: newSession,
                            profile: newProfile,
                            viewPreference: newViewPreference,
                            initialized: true
                        });
                    }
                });
            }
        } catch (error) {
            console.error('Auth initialization error:', error);
            set({ session: null, profile: null, viewPreference: null, initialized: true });
        }
    }

    async function signIn(email, password, clinicalView = false) {
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) throw error;

        const { data: profile } = await supabase
            .from('profile')
            .select('role')
            .eq('id', data.session.user.id)
            .single();

        const viewPreference = profile.role === 'clinician' 
            ? (clinicalView ? 'clinical' : 'personal')
            : null;

        set({
            session: data.session,
            profile,
            viewPreference,
            initialized: true
        });

        // Redirect based on role and view preference
        if (profile.role === 'clinician' && clinicalView) {
            goto('/clinician/patients');
        } else {
            goto('/diary');
        }
    }

    async function signOut() {
        const { error } = await supabase.auth.signOut();
        if (error) throw error;

        set({ session: null, profile: null, viewPreference: null, initialized: true });
        goto('/login');
    }

    return {
        subscribe,
        signIn,
        signOut,
        initializeAuth
    };
}

export const auth = createAuthStore(); 