<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/backend/supabase';

	export let selectedDate;
	$: console.log('DiaryEntry received new date:', selectedDate);
	
	let aspects = [];
	let entries = null;  // Start as null to track initialization
	let loading = true;  // Add loading state
	let diary = null;  // Add diary state

	// Load aspects for the diary
	async function loadAspects() {
		const { data: { user } } = await supabase.auth.getUser();
		if (!user) return;

		// First get the user's diary
		const { data: diaryData, error: diaryError } = await supabase
			.from('diary')
			.select('id')
			.eq('patient_id', user.id)
			.single();

		console.log('Diary data:', diaryData, 'Error:', diaryError);

		if (!diaryData) {
			loading = false;
			return;
		}

		diary = diaryData;

		const { data: aspectsData, error: aspectsError } = await supabase
			.from('aspect')
			.select('*')
			.eq('diary_id', diaryData.id)
			.order('display_order');
			
		console.log('Aspects data:', aspectsData, 'Error:', aspectsError);

		if (!aspectsError) {
			aspects = aspectsData || [];  // Ensure it's at least an empty array
		}
		loading = false;
	}

	// Load entries for selected date
	async function loadEntries(date) {
		if (!diary) return;  // Don't load entries if we don't have a diary
		
		const { data: { user } } = await supabase.auth.getUser();
		if (!user) return;

		console.log('Loading entries for:', date.toISOString().split('T')[0]);
		
		const { data: entriesData, error: entriesError } = await supabase
			.from('entry')
			.select('*')
			.eq('entry_date', date.toISOString().split('T')[0])
			.eq('patient_id', user.id);  // Only get entries for current user

		console.log('Entries received:', entriesData);
		console.log('Entries error:', entriesError);

		if (!entriesError) {
			entries = Object.fromEntries(
				aspects.map(aspect => [
					aspect.id, 
					entriesData?.find(e => e.aspect_id === aspect.id) || {
						content_scale: null,
						content_text: aspect.data_type === 'text' ? '' : null
					}
				])
			);
		}
		console.log('Processed entries:', entries);
	}

	onMount(() => {
		loadAspects();
	});

	$: {
		console.log('Date changed, loading entries for:', selectedDate);
		if (diary && !loading) {
			loadEntries(selectedDate);
		}
	}

	function updateRangeProgress(event) {
		const input = event.target;
		const value = input.value;
		const min = input.min || 0;
		const max = input.max || 100;
		const progress = ((value - min) / (max - min)) * 100;
		input.style.setProperty('--range-progress', `${progress}%`);
	}
</script>

<div class="diary-entry">
	<h2>{selectedDate.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}</h2>
	
	{#if loading}
		<div class="loading">Loading...</div>
	{:else if !diary}
		<div class="empty-state">
			<p>No diary found. Please contact support to set up your diary.</p>
		</div>
	{:else if aspects.length === 0}
		<div class="empty-state">
			<p>No diary aspects found. Please set up your diary first.</p>
		</div>
	{:else if !entries}
		<div class="loading">Loading entries...</div>
	{:else}
		<div class="aspects">
			{#each aspects as aspect}
				<div class="aspect">
					<h3>{aspect.name}</h3>
					{#if aspect.data_type === 'scale'}
						<div class="scale-input">
							{#if entries[aspect.id].content_scale === null}
								<div class="unset-scale">Not set</div>
								<button 
									class="set-scale" 
									on:click={() => entries[aspect.id].content_scale = 5}
								>
									Set value
								</button>
							{:else}
								<input 
									type="range" 
									min="1" 
									max="10" 
									bind:value={entries[aspect.id].content_scale}
									on:input={updateRangeProgress}
									style="--range-progress: {((entries[aspect.id].content_scale) - 1) / 9 * 100}%"
								/>
								<span class="scale-value">{entries[aspect.id].content_scale}</span>
							{/if}
						</div>
					{:else}
						<textarea
							bind:value={entries[aspect.id].content_text}
							placeholder="Write your thoughts..."
							rows="3"
						/>
					{/if}
				</div>
			{/each}
		</div>
	{/if}
</div>

<style>
	.diary-entry {
		flex: 1;
		padding: 1rem;
		height: 100%;
		overflow-y: auto;
	}

	.aspects {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
		margin-top: 2rem;
		padding-bottom: 2rem;
	}

	.aspect {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.scale-input {
		display: flex;
		align-items: center;
		gap: 1rem;
	}

	.scale-value {
		min-width: 2em;
	}

	textarea {
		min-height: 80px;
		padding: 0.5rem;
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		background: var(--background-light);
		color: var(--primary);
		resize: vertical;
	}

	input[type="range"] {
		flex: 1;
		max-width: 300px;
	}

	.loading,
	.empty-state {
		display: flex;
		justify-content: center;
		align-items: center;
		min-height: 200px;
		color: var(--primary-50);
	}

	.unset-scale {
		color: var(--primary-50);
		font-style: italic;
	}

	.set-scale {
		padding: 4px 8px;
		font-size: 12px;
		margin-left: 8px;
	}
</style> 