<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/backend/supabase';

	export let selectedDate;
	
	let aspects = [];
	let entries = {};
	let loading = true;  // Add loading state

	// Load aspects for the diary
	async function loadAspects() {
		const { data: aspectsData, error: aspectsError } = await supabase
			.from('aspect')
			.select('*')
			.order('display_order');
			
		if (!aspectsError) {
			aspects = aspectsData || [];  // Ensure it's at least an empty array
		}
	}

	// Load entries for selected date
	async function loadEntries(date) {
		loading = true;
		const { data: entriesData, error: entriesError } = await supabase
			.from('entry')
			.select('*')
			.eq('entry_date', date.toISOString().split('T')[0]);

		if (!entriesError) {
			entries = Object.fromEntries(
				aspects.map(aspect => [
					aspect.id, 
					entriesData?.find(e => e.aspect_id === aspect.id) || {
						content_scale: aspect.data_type === 'scale' ? 5 : null,
						content_text: aspect.data_type === 'text' ? '' : null
					}
				])
			);
		}
		loading = false;
	}

	onMount(() => {
		loadAspects();
	});

	$: loadEntries(selectedDate);

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
	{:else if aspects.length === 0}
		<div class="empty-state">
			<p>No diary aspects found. Please set up your diary first.</p>
		</div>
	{:else}
		<div class="aspects">
			{#each aspects as aspect}
				<div class="aspect">
					<h3>{aspect.name}</h3>
					{#if aspect.data_type === 'scale'}
						<div class="scale-input">
							<input 
								type="range" 
								min="1" 
								max="10" 
								bind:value={entries[aspect.id].content_scale}
								on:input={updateRangeProgress}
								style="--range-progress: {((entries[aspect.id].content_scale) - 1) / 9 * 100}%"
							/>
							<span class="scale-value">{entries[aspect.id].content_scale}</span>
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
</style> 