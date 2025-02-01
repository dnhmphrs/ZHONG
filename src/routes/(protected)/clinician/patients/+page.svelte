<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/backend/supabase';

	let patients = [];

	onMount(async () => {
		const { data, error } = await supabase
			.from('cohort_member')
			.select(`
				patient:patient_id (
					id,
					name,
					email
				)
			`)
			.distinct();

		if (!error) {
			patients = data.map(d => d.patient);
		}
	});
</script>

<div class="container">
	<h1>Patients</h1>
	<div class="patient-list">
		{#each patients as patient}
			<div class="patient-card">
				<h3>{patient.name}</h3>
				<p>{patient.email}</p>
			</div>
		{/each}
	</div>
</div>

<style>
	.container {
		padding: 2rem;
	}

	.patient-list {
		margin-top: 2rem;
		display: grid;
		gap: 1rem;
		grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
	}

	.patient-card {
		padding: 1rem;
		border: 1px solid var(--primary-50);
		border-radius: 4px;
	}
</style> 