<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/backend/supabase';
	import SelectList from '$lib/components/SelectList.svelte';
	import DaySelector from '../../diary/DaySelector.svelte';
	import { clinicianStore } from '$lib/store/clinician';
	import TrendChart from '$lib/components/TrendChart.svelte';

	let selectedDate = new Date();

	onMount(async () => {
		console.log('Loading patients...');
		try {
			await clinicianStore.loadAllPatients();
			console.log('Store state after load:', $clinicianStore);
		} catch (error) {
			console.error('Error loading patients:', error);
		}
	});

	function handleDateSelect(event) {
		console.log('Date selected:', event.detail.date);
		selectedDate = event.detail.date;
	}

	$: patients = $clinicianStore.allPatients || [];
	$: selectedPatient = $clinicianStore.selectedPatient;
	$: entries = $clinicianStore.entries || [];
	$: console.log('Raw entries:', entries);
	$: currentDateEntries = entries.filter(e => e.entry_date === selectedDate.toISOString().split('T')[0]);
	$: console.log('Date comparison:', {
		selectedDate: selectedDate.toISOString().split('T')[0],
		entryDates: entries.map(e => e.entry_date),
		matchingEntries: currentDateEntries
	});
	$: loading = $clinicianStore.loading;

	// Add computed stats with null checks
	$: completionRate = entries.length > 0 
		? Math.round((entries.filter(e => e.entry_date === selectedDate.toISOString().split('T')[0]).length / 4) * 100)
		: 0;
	
	$: averageMood = entries
		.filter(e => e.aspect?.name === 'Mood' && e.content_scale)
		.reduce((acc, e, i, arr) => acc + e.content_scale, 0) / 
		(entries.filter(e => e.aspect?.name === 'Mood' && e.content_scale).length || 1);

	// Add trend data computation
	$: moodTrend = entries
		.filter(e => {
			console.log('Mood entry check:', {
				name: e.aspect?.name,
				scale: e.content_scale,
				aspect: e.aspect,
				entry: e
			});
			return e.aspect?.name === 'Mood' && e.content_scale != null;
		})
		.map(e => ({
			date: new Date(e.entry_date),
			value: e.content_scale
		}))
		.sort((a, b) => a.date - b.date);
		
	$: sleepTrend = entries
		.filter(e => {
			console.log('Filtering sleep entry:', e);
			return e.aspect?.name === 'Sleep Quality' && e.content_scale != null;
		})
		.map(e => ({
			date: new Date(e.entry_date),
			value: e.content_scale
		}))
		.sort((a, b) => a.date - b.date);

	$: hasTrendData = moodTrend.length > 1 || sleepTrend.length > 1;
	$: console.log('Trend data:', { moodTrend, sleepTrend, entries });
</script>

<div class="page-layout">
	<div class="left-panel">
		<SelectList
			title="Patients"
			items={patients}
			{selectedPatient}
			getHeader={(patient) => patient?.name || ''}
			getDescription={(patient) => patient?.email || ''}
			onSelect={(patient) => clinicianStore.selectPatient(patient)}
		/>
	</div>

	<div class="content">
		{#if selectedPatient}
			<div class="content-header">
				<div class="patient-info">
					<h3>{selectedPatient.name}</h3>
					<div class="patient-meta">
						<span>{selectedPatient.email}</span>
						<span>•</span>
						<span>Cohorts: {selectedPatient.cohorts?.join(', ') || 'None'}</span>
					</div>
				</div>
			</div>

			<div class="main-content">
				<!-- Left side: Calendar and Metrics -->
				<div class="left-content">
					<div class="calendar-section">
						<h4>Select Date</h4>
						<DaySelector {selectedDate} on:dateSelect={handleDateSelect} />
					</div>

					<div class="metrics-stack">
						<div class="metric-card accent">
							<div class="metric-value">{completionRate}%</div>
							<div class="metric-label">30-day completion</div>
						</div>
						<div class="metric-card">
							<div class="metric-value">{averageMood.toFixed(1)}</div>
							<div class="metric-label">Average mood</div>
						</div>
						<div class="metric-card">
							<div class="metric-value">
								{new Set(entries.map(e => e.entry_date)).size}
							</div>
							<div class="metric-label">Days logged</div>
						</div>
					</div>
				</div>

				<!-- Right side: Trends and Daily Entries -->
				<div class="right-content">
					<div class="trends-section">
						<h4>30-Day Trends</h4>
						{#if hasTrendData}
							<div class="trends-grid">
								<div class="trend-card">
									<div class="trend-header">Mood</div>
									<TrendChart data={moodTrend} height={120} />
								</div>
								<div class="trend-card">
									<div class="trend-header">Sleep Quality</div>
									<TrendChart data={sleepTrend} height={120} />
								</div>
							</div>
						{:else}
							<div class="empty-state">Not enough data to show trends yet</div>
						{/if}
					</div>

					<div class="entries-section">
						<h4>Daily Entries</h4>
						{#if loading}
							<div class="loading">Loading entries...</div>
						{:else if !entries.filter(e => e.entry_date === selectedDate.toISOString().split('T')[0]).length}
							<div class="empty-state">No entries for this date</div>
						{:else}
							<div class="entries-list">
								{#each entries.filter(e => e.entry_date === selectedDate.toISOString().split('T')[0]) as entry}
									<div class="entry-card">
										<div class="entry-header">{entry.aspect.name}</div>
										{#if entry.aspect.data_type === 'scale'}
											<div class="entry-value">{entry.content_scale}/10</div>
										{:else}
											<div class="entry-text">{entry.content_text}</div>
										{/if}
									</div>
								{/each}
							</div>
						{/if}
					</div>
				</div>
			</div>
		{:else}
			<div class="empty-state">
				Select a patient to view their diary
			</div>
		{/if}
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
		height: 100%;
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		overflow: hidden;
	}

	.content {
		flex: 1;
		width: 0;
		height: 100%;
		display: flex;
		flex-direction: column;
		overflow: hidden;
	}

	.content-header {
		margin-bottom: 0.75rem;
	}

	.patient-info {
		display: flex;
		flex-direction: column;
		gap: 0.25rem;
	}

	.metrics-stack {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.metric-card {
		flex: 1;
		padding: 1rem;
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		text-align: center;
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

	.main-content {
		display: flex;
		gap: 2rem;
		flex: 1;
		min-height: 0;
		align-items: flex-start;
		overflow: hidden;
	}

	.left-content {
		width: 300px;
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
		min-height: 0;
	}

	.right-content {
		flex: 1;
		min-height: 0;
		display: flex;
		flex-direction: column;
		gap: 2rem;
		overflow: hidden;
	}

	.calendar-section {
		width: 100%;
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.entries-section {
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		padding: 1.5rem;
		flex: 1;
		overflow: hidden;
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.entries-list {
		display: flex;
		flex-direction: column;
		overflow-y: auto;
		max-height: calc(100vh - 400px);
		margin: 0 -1.5rem;
		padding: 0 1.5rem;
	}

	.entry-card {
		padding: 0.5rem 0;
		border-bottom: 1px solid var(--primary-50);
		transition: background-color 0.2s ease;
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

	.trends-section {
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
	}

	.trends-grid {
		display: flex;
		flex-direction: row;
		gap: 1.5rem;
	}

	.trend-card {
		flex: 1;
		padding: 1.5rem;
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		height: 150px;
		flex-shrink: 0;
	}

	.patient-meta {
		display: flex;
		gap: 0.5rem;
		font-size: 12px;
		color: var(--primary-50);
		align-items: center;
	}

	.empty-state {
		flex: 1;
		display: flex;
		align-items: center;
		justify-content: center;
		color: var(--primary-50);
		font-style: italic;
	}

	h3, h4 {
		margin: 0;
	}

	h4 {
		color: var(--primary-50);
		font-size: 12px;
		text-transform: uppercase;
		letter-spacing: 0.1em;
	}

	.loading {
		text-align: center;
		color: var(--primary-50);
		font-style: italic;
	}

	.metric-card.accent {
		background: var(--accent);
		border: none;
	}

	.metric-card.accent .metric-value,
	.metric-card.accent .metric-label {
		color: var(--background);
	}
</style> 