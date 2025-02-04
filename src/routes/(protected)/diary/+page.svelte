<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/backend/supabase';
	import DaySelector from './DaySelector.svelte';
	import { diaryStore } from '$lib/store/diary';

	let selectedDate = new Date();
	let diaries = [];

	onMount(async () => {
		await diaryStore.loadAspects();
		await diaryStore.loadEntries(selectedDate);
	});

	function handleDateSelect(event) {
		selectedDate = event.detail.date;
		diaryStore.loadEntries(selectedDate);
	}

	// Computed metrics
	$: completionRate = $diaryStore.entries.length > 0 
		? Math.round(($diaryStore.entries.length / $diaryStore.aspects.length) * 100)
		: 0;

	$: averageMood = $diaryStore.entries
		.filter(e => e.aspect.name === 'Mood' && e.content_scale)
		.reduce((acc, e) => acc + e.content_scale, 0) / $diaryStore.entries.length || 0;

	$: streakDays = 24; // TODO: Calculate actual streak

	// onMount(async () => {
	// 	const { data: { user } } = await supabase.auth.getUser();
	// 	const { data, error } = await supabase
	// 		.from('diary')
	// 		.select('*')
	// 		.eq('patient_id', user.id);
	//
	// 	if (!error) {
	// 		diaries = data;
	// 	}
	// });
</script>

<div class="page-layout">
	<div class="left-panel">
		<h4>Select Date</h4>
		<DaySelector {selectedDate} on:dateSelect={handleDateSelect} />

		<div class="metrics-stack">
			<div class="metric-card accent">
				<div class="metric-value">{completionRate}%</div>
				<div class="metric-label">Today's completion</div>
			</div>
			<div class="metric-card">
				<div class="metric-value">{averageMood.toFixed(1)}</div>
				<div class="metric-label">Average mood</div>
			</div>
			<div class="metric-card">
				<div class="metric-value">{streakDays}</div>
				<div class="metric-label">Day streak</div>
			</div>
		</div>
	</div>

	<div class="content">
		<div class="entries-section">
			<h4>Daily Entries</h4>
			{#if $diaryStore.loading}
				<div class="loading">Loading entries...</div>
			{:else if $diaryStore.entries.length === 0}
				<div class="empty-state">No entries for this date</div>
			{:else}
				<div class="entries-list">
					{#each $diaryStore.aspects as aspect}
						{@const entry = $diaryStore.entries.find(e => e.aspect_id === aspect.id)}
						<div class="entry-card">
							<div class="entry-header">{aspect.name}</div>
							{#if entry}
								{#if aspect.data_type === 'scale'}
									<div class="entry-value">{entry.content_scale}/10</div>
									<div class="scale-bar">
										<div class="scale-fill" style="width: {entry.content_scale * 10}%"></div>
									</div>
								{:else}
									<div class="entry-text">{entry.content_text}</div>
								{/if}
							{:else}
								<button class="add-entry" on:click={() => diaryStore.createEntry(aspect)}>
									Add entry
								</button>
							{/if}
						</div>
					{/each}
				</div>
			{/if}
		</div>
	</div>
</div>

<style>
	.page-layout {
		display: flex;
		gap: 2rem;
		padding: 1rem;
		width: 100%;
		height: 100%;
	}

	.left-panel {
		width: 300px;
		display: flex;
		flex-direction: column;
		gap: 2rem;
	}

	.calendar-section {
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		padding: 1.5rem;
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.metrics-stack {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.metric-card {
		padding: 1rem;
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		text-align: center;
	}

	.metric-card.accent {
		background: var(--accent);
		border: none;
	}

	.metric-card.accent .metric-value,
	.metric-card.accent .metric-label {
		color: var(--background);
	}

	.metric-value {
		font-size: 2rem;
		font-weight: 500;
		color: var(--primary);
	}

	.metric-label {
		font-size: 0.875rem;
		color: var(--primary-50);
		margin-top: 0.5rem;
	}

	.content {
		flex: 1;
		min-width: 0;
		height: 100%;
	}

	.entries-section {
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		padding: 1.5rem;
		height: 100%;
		display: flex;
		flex-direction: column;
		gap: 1rem;
		overflow: hidden;
	}

	.entries-list {
		display: flex;
		flex-direction: column;
		overflow-y: auto;
		margin: 0 -1.5rem;
		padding: 0 1.5rem;
	}

	.entry-card {
		padding: 0.5rem 0;
		border-bottom: 1px solid var(--primary-50);
		transition: all 0.2s ease;
		opacity: 0.7;
		display: flex;
		align-items: baseline;
		gap: 1rem;
	}

	.entry-card:hover {
		opacity: 1;
	}

	.entry-header {
		font-size: 12px;
		color: var(--primary-50);
		text-transform: uppercase;
		letter-spacing: 0.05em;
		width: 100px;
		flex-shrink: 0;
		font-weight: 700;
	}

	.entry-value {
		font-size: 14px;
		font-weight: 400;
		color: var(--primary);
	}

	.entry-text {
		font-size: 12px;
		line-height: 1.4;
		color: var(--primary);
		opacity: 0.8;
		flex: 1;
		font-weight: 400;
	}

	.add-entry {
		font-size: 12px;
		color: var(--accent);
		background: none;
		border: none;
		padding: 0;
		cursor: pointer;
		opacity: 0.8;
	}

	.add-entry:hover {
		opacity: 1;
	}

	h4 {
		color: var(--primary-50);
		font-size: 12px;
		text-transform: uppercase;
		letter-spacing: 0.1em;
		margin: 0;
	}

	.loading, .empty-state {
		text-align: center;
		color: var(--primary-50);
		font-style: italic;
	}

	.scale-bar {
		flex: 1;
		height: 8px;
		background: var(--background);
		border-radius: 4px;
		overflow: hidden;
	}

	.scale-fill {
		height: 100%;
		background: var(--accent);
		border-radius: 4px;
		transition: width 0.3s ease;
	}
</style> 