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
		await clinicianStore.loadAllPatients();
		console.log('Store state:', $clinicianStore);
	});

	function handleDateSelect(event) {
		selectedDate = event.detail.date;
		if ($clinicianStore.selectedPatient) {
			clinicianStore.selectPatient($clinicianStore.selectedPatient);
		}
	}

	$: patients = $clinicianStore.allPatients;
	$: selectedPatient = $clinicianStore.selectedPatient;
	$: entries = $clinicianStore.entries;
	$: loading = $clinicianStore.loading;

	// Add computed stats
	$: completionRate = entries.length > 0 
		? Math.round((entries.length / selectedPatient?.aspects?.length || 1) * 100)
		: 0;
	
	$: averageMood = entries
		.filter(e => e.aspect.name === 'Mood' && e.content_scale)
		.reduce((acc, e) => acc + e.content_scale, 0) / entries.length || 0;

	// Add trend data computation
	$: moodTrend = entries
		.filter(e => e.aspect.name === 'Mood' && e.content_scale)
		.map(e => ({
			date: new Date(e.entry_date),
			value: e.content_scale
		}))
		.sort((a, b) => a.date - b.date);
		
	$: sleepTrend = entries
		.filter(e => e.aspect.name === 'Sleep Quality' && e.content_scale)
		.map(e => ({
			date: new Date(e.entry_date),
			value: e.content_scale
		}))
		.sort((a, b) => a.date - b.date);
</script>

<div class="page-layout">
	<div class="left-panel">
		<SelectList
			title="Patients"
			items={patients}
			{selectedPatient}
			getHeader={(patient) => patient.name}
			getDescription={(patient) => `${patient.email}\n${patient.cohorts.join(', ')}`}
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
						<span>Cohorts: {selectedPatient.cohorts.join(', ')}</span>
					</div>
				</div>
				<div class="metrics">
					<div class="metric-card">
						<div class="metric-value">{completionRate}%</div>
						<div class="metric-label">30-day completion</div>
					</div>
					<div class="metric-card">
						<div class="metric-value">{averageMood.toFixed(1)}</div>
						<div class="metric-label">Average mood</div>
					</div>
					<div class="metric-card">
						<div class="metric-value">24</div>
						<div class="metric-label">Days logged</div>
					</div>
				</div>
			</div>

			<div class="main-content">
				<div class="calendar-section">
					<h4>Select Date</h4>
					<DaySelector {selectedDate} on:dateSelect={handleDateSelect} />
				</div>

				<div class="entries-section">
					<h4>Daily Entries</h4>
					{#if loading}
						<div class="loading">Loading entries...</div>
					{:else if entries.length === 0}
						<div class="empty-state">No entries for this date</div>
					{:else}
						<div class="entries-list">
							{#each entries as entry}
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

				<div class="trends-section">
					<h4>30-Day Trends</h4>
					<div class="trends-grid">
						<div class="trend-card">
							<div class="trend-header">Mood</div>
							<TrendChart data={moodTrend} accentColor={true} />
						</div>
						<div class="trend-card">
							<div class="trend-header">Sleep Quality</div>
							<TrendChart data={sleepTrend} />
						</div>
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
		gap: 2rem;
	}

	.content-header {
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
	}

	.metrics {
		display: flex;
		gap: 2rem;
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
		justify-content: center;
		width: 100%;
		flex: 1;
		min-height: 0;
	}

	.calendar-section {
		width: calc((100% - 4rem) / 3);
		flex-shrink: 0;
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.entries-section {
		display: flex;
		flex-direction: column;
		gap: 1rem;
		width: calc((100% - 4rem) / 3);
		flex-shrink: 0;
		height: 100%;
		overflow: hidden;
	}

	.entries-list {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 0.75rem;
		overflow-y: auto;
		padding-right: 0.5rem;
		min-height: 0;
	}

	.entry-card {
		padding: 0.75rem;
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
	}

	.trends-section {
		width: calc((100% - 4rem) / 3);
		flex-shrink: 0;
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
		height: 100%;
		overflow: hidden;
	}

	.trends-grid {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 1.5rem;
		overflow-y: auto;
		padding-right: 0.5rem;
		min-height: 0;
	}

	.trend-card {
		padding: 1.5rem;
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		height: 180px;
		flex-shrink: 0;
	}

	.patient-info {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.patient-meta {
		display: flex;
		gap: 1rem;
		font-size: 12px;
		color: var(--primary-50);
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
</style> 