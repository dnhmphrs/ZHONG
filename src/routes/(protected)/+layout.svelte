<script>
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';
    import { supabase } from '$lib/backend/supabase';

    onMount(async () => {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session) {
            goto('/login');
        }
    });
</script>

<slot /> 