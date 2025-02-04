<script>
	import { onMount } from 'svelte';
	import SelectList from '$lib/components/SelectList.svelte';
	import { clinicianStore } from '$lib/store/clinician';

	onMount(async () => {
		await clinicianStore.loadCohorts();
	});

	$: cohorts = $clinicianStore.cohorts;
	$: selectedCohort = $clinicianStore.selectedCohort;
	$: patients = $clinicianStore.patients;
	$: loading = $clinicianStore.loading;
</script>

<div class="page-layout">
	<div class="left-panel">
		<SelectList
			title="Cohorts"
			items={cohorts}
			{selectedCohort}
			getHeader={(cohort) => cohort.name}
			getDescription={(cohort) => cohort.description}
			onSelect={(cohort) => clinicianStore.selectCohort(cohort)}
		/>
	</div>

	{#if selectedCohort}
		<div class="content">
			<div class="content-header">
				<h3>{selectedCohort.name}</h3>
				<button class="primary">Add Patient</button>
			</div>
			
			<div class="content-section">
				<h4>Patients</h4>
				<div class="patient-grid">
					{#if loading}
						<div class="loading">Loading patients...</div>
					{:else}
						{#each patients as patient}
							<div class="patient-card">
								<div class="patient-name">{patient.name}</div>
								<div class="patient-stats">
									<div>Email: {patient.email}</div>
								</div>
							</div>
						{/each}
					{/if}
				</div>
			</div>

			<div class="content-section">
				<h4>Analytics</h4>
				<div class="stats-grid">
					<div class="stat-card">
						<div class="stat-value">85%</div>
						<div class="stat-label">Average Completion</div>
					</div>
					<div class="stat-card">
						<div class="stat-value">24</div>
						<div class="stat-label">Active Patients</div>
					</div>
				</div>
			</div>
		</div>
	{:else}
		<div class="empty-state">
			Select a cohort to view details
		</div>
	{/if}
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
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		overflow: hidden;
	}

	.content {
		flex: 1;
		display: flex;
		flex-direction: column;
		gap: 2rem;
	}

	.content-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.content-section {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.patient-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
		gap: 1rem;
	}

	.patient-card {
		padding: 1rem;
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
	}

	.patient-name {
		font-weight: 500;
		margin-bottom: 0.5rem;
	}

	.patient-stats {
		font-size: 12px;
		color: var(--primary-50);
	}

	.stats-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
		gap: 1rem;
	}

	.stat-card {
		padding: 1rem;
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		text-align: center;
	}

	.stat-value {
		font-size: 24px;
		font-weight: 500;
	}

	.stat-label {
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
</style> 