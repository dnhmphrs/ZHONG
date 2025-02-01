<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/backend/supabase';

	export let selectedDate;
	
	let aspects = [];
	let entries = {};

	$: loadEntries(selectedDate);

	async function loadEntries(date) {
		const { data: aspectsData, error: aspectsError } = await supabase
			.from('aspect')
			.select('*')
			.order('display_order');

		if (!aspectsError) {
			aspects = aspectsData;
		}

		const { data: entriesData, error: entriesError } = await supabase
			.from('entry')
			.select('*')
			.eq('entry_date', date.toISOString().split('T')[0]);

		if (!entriesError) {
			entries = Object.fromEntries(
				entriesData.map(entry => [entry.aspect_id, entry])
			);
		}
	}
</script>

<div class="diary-entry">
	<h2>{selectedDate.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}</h2>
	
	<div class="aspects">
		{#each aspects as aspect}
			<div class="aspect">
				<h3>{aspect.name}</h3>
				{#if aspect.data_type === 'scale'}
					<!-- Scale input -->
					<input 
						type="range" 
						min="1" 
						max="10" 
						value={entries[aspect.id]?.content_scale || 5}
					/>
				{:else}
					<!-- Text input -->
					<textarea
						value={entries[aspect.id]?.content_text || ''}
						placeholder="Write your thoughts..."
					/>
				{/if}
			</div>
		{/each}
	</div>
</div>

<style>
	.diary-entry {
		flex: 1;
		padding: 1rem;
	}

	.aspects {
		display: flex;
		flex-direction: column;
		gap: 2rem;
		margin-top: 2rem;
	}

	.aspect {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	textarea {
		min-height: 100px;
		padding: 0.5rem;
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		background: var(--background-light);
		color: var(--primary);
		resize: vertical;
	}

	input[type="range"] {
		width: 100%;
		max-width: 300px;
	}
</style> 