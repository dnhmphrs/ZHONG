<script>
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';
    import { supabase } from '$lib/backend/supabase';
    import { auth } from '$lib/store/auth';

    onMount(async () => {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session) {
            auth.signOut();
        }
    });
</script>

<slot /> 