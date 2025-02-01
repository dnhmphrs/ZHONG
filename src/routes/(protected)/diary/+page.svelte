<script>
    import { onMount } from 'svelte';
    import { supabase } from '$lib/backend/supabase';

    let diaries = [];
    
    onMount(async () => {
        const { data: { user } } = await supabase.auth.getUser();
        const { data } = await supabase
            .from('diary')
            .select('*')
            .eq('user_id', user.id);
        
        diaries = data || [];
    });
</script>

<div class="diary-page">
    <h1>My Diaries</h1>
    
    {#if diaries.length === 0}
        <p>No diaries yet.</p>
    {:else}
        <ul>
            {#each diaries as diary}
                <li>
                    <h3>{diary.name}</h3>
                    <p>{diary.description}</p>
                </li>
            {/each}
        </ul>
    {/if}
</div>

<style>
    .diary-page {
        padding: 2rem;
    }
</style> 