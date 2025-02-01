<script>
    import { onMount } from 'svelte';
    import { supabase } from '$lib/backend/supabase';

    let cohorts = [];
    
    onMount(async () => {
        const { data: { user } } = await supabase.auth.getUser();
        const { data } = await supabase
            .from('cohort')
            .select('*')
            .eq('owner_id', user.id);
        
        cohorts = data || [];
    });
</script>

<div class="clinician-page">
    <h1>My Cohorts</h1>
    
    {#if cohorts.length === 0}
        <p>No cohorts yet.</p>
    {:else}
        <ul>
            {#each cohorts as cohort}
                <li>
                    <h3>{cohort.name}</h3>
                    <p>{cohort.description}</p>
                </li>
            {/each}
        </ul>
    {/if}
</div>

<style>
    .clinician-page {
        padding: 2rem;
    }
</style> 