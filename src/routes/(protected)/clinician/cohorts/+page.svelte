<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/backend/supabase';

	let cohorts = [];

	onMount(async () => {
		const { data, error } = await supabase
			.from('cohort')
			.select('*');

		if (!error) {
			cohorts = data;
		}
	});
</script>

<div class="container">
	<h1>Cohorts</h1>
	<div class="cohort-list">
		{#each cohorts as cohort}
			<div class="cohort-card">
				<h3>{cohort.name}</h3>
				<p>{cohort.description}</p>
			</div>
		{/each}
	</div>
</div>

<style>
	.container {
		padding: 2rem;
	}

	.cohort-list {
		margin-top: 2rem;
		display: grid;
		gap: 1rem;
		grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
	}

	.cohort-card {
		padding: 1rem;
		border: 1px solid var(--primary-50);
		border-radius: 4px;
	}
</style> 