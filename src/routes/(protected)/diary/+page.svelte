<script>
	import { onMount } from 'svelte';
	import { supabase } from '$lib/backend/supabase';
	import DaySelector from './DaySelector.svelte';
	import DiaryEntry from './DiaryEntry.svelte';

	// Ensure we have a clean date object at midnight
	let selectedDate = new Date(new Date().setHours(0, 0, 0, 0));
	let diaries = [];

	function handleDateSelect(event) {
		console.log('Date selected:', event.detail.date);
		// Create a new Date object to ensure reactivity
		selectedDate = new Date(event.detail.date.setHours(0, 0, 0, 0));
		console.log('Updated selectedDate:', selectedDate);
	}

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

<div class="diary-page">
	<DaySelector {selectedDate} on:dateSelect={handleDateSelect} />
	<DiaryEntry {selectedDate} />
</div>

<style>
	.diary-page {
		display: flex;
		gap: 2rem;
		height: 100%;
		width: 100%;
		max-width: 100%;  /* Ensure no overflow */
		box-sizing: border-box;  /* Include padding in width */
		padding: 2rem;
	}
</style> 