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
            // Get current session first
            let { data: { session }, error: sessionError } = await supabase.auth.getSession();
            
            // If there's a session error, clear everything
            if (sessionError) {
                console.error('Session error:', sessionError);
                set({ session: null, profile: null, viewPreference: null, initialized: true });
                return;
            }
            
            if (!session) {
                set({ session: null, profile: null, viewPreference: null, initialized: true });
                return;
            }

            const { data: profile } = await supabase
                .from('profile')
                .select('role')
                .eq('id', session.user.id)
                .single();

            // If we can't get the profile, something's wrong with the session
            if (!profile) {
                console.error('No profile found for user');
                set({ session: null, profile: null, viewPreference: null, initialized: true });
                return;
            }

            // Get stored view preference if clinician
            let viewPreference = null;
            if (profile?.role === 'clinician') {
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

                        let newViewPreference = null;
                        if (newProfile?.role === 'clinician') {
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

        const { data: profile, error: profileError } = await supabase
            .from('profile')
            .select('role')
            .eq('id', data.session.user.id)
            .single();

        // If no profile exists, create one
        if (profileError) {
            const { data: newProfile, error: insertError } = await supabase
                .from('profile')
                .insert([{
                    id: data.session.user.id,
                    role: 'patient',  // default role
                    name: email.split('@')[0],  // temporary name
                    email: email
                }])
                .select()
                .single();
            
            if (insertError) throw insertError;
            profile = newProfile;
        }

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
        try {
            const { error } = await supabase.auth.signOut();
            if (error) throw error;
    
            set({ session: null, profile: null, viewPreference: null, initialized: true });
            // Clear any stored auth data
            if (typeof window !== 'undefined') {
                localStorage.removeItem('sb-auth-token');
                document.cookie = 'sb-auth-token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
            }
            goto('/login');
        } catch (error) {
            console.error('Sign out error:', error);
            // Force redirect to login even if there's an error
            goto('/login');
        }
    }

    return {
        subscribe,
        signIn,
        signOut,
        initializeAuth
    };
}

export const auth = createAuthStore();

const protectedPaths = [
    '/clinician',
    '/clinician/patients',
    '/clinician/cohorts',
    '/clinician/analytics',
    '/diary'
]; 