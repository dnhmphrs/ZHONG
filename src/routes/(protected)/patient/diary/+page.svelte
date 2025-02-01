<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/backend/supabase';
	import DaySelector from './DaySelector.svelte';
	import DiaryEntry from './DiaryEntry.svelte';

	let selectedDate = new Date();
	let diaries = [];

	function handleDateSelect(event) {
		selectedDate = event.detail.date;
	}

	onMount(async () => {
		const { data, error } = await supabase
			.from('diary')
			.select('*')
			.eq('patient_id', supabase.auth.user().id);

		if (!error) {
			diaries = data;
		}
	});
</script>

<div class="diary-page">
	<DaySelector {selectedDate} on:dateSelect={handleDateSelect} />
	<DiaryEntry {selectedDate} />
</div>

<style>
	.diary-page {
		display: flex;
		gap: 2rem;
		height: 100%;
		padding: 2rem;
	}
</style> 