<script>
	import { createEventDispatcher } from 'svelte';
	
	export let selectedDate;
	
	const dispatch = createEventDispatcher();
	const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
	
	function generateDates(centerDate) {
		const dates = [];
		// Create a new date without mutating the original
		const startDate = new Date(centerDate.getFullYear(), centerDate.getMonth(), centerDate.getDate());
		
		// Go back 4 weeks and to the nearest Monday
		startDate.setDate(startDate.getDate() - 28);
		startDate.setDate(startDate.getDate() - startDate.getDay() + (startDate.getDay() === 0 ? -6 : 1));
		
		// Generate 8 weeks (4 before, current, 3 after)
		for (let i = 0; i < 56; i++) {
			const date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate() + i);
			dates.push({
				date,
				isToday: isSameDay(date, new Date()),
				isSelected: isSameDay(date, selectedDate),
				isCurrentMonth: date.getMonth() === selectedDate.getMonth()
			});
		}
		
		return dates;
	}

	function groupIntoWeeks(dates) {
		const weeks = [];
		for (let i = 0; i < dates.length; i += 7) {
			const week = dates.slice(i, i + 7);
			weeks.push(week);
		}
		return weeks;
	}
	
	// Force regeneration when selectedDate changes
	$: dates = generateDates(selectedDate);
	$: weeks = groupIntoWeeks(dates);
	
	function isSameDay(d1, d2) {
		return d1.getDate() === d2.getDate() &&
			d1.getMonth() === d2.getMonth() &&
			d1.getFullYear() === d2.getFullYear();
	}
	
	function selectDate(date) {
		console.log('Selecting date:', date);
		dispatch('dateSelect', { date });
	}

	const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
</script>

<div class="calendar">
	<div class="month-header">
		{monthNames[selectedDate.getMonth()]} {selectedDate.getFullYear()}
	</div>
	
	<div class="day-labels">
		{#each dayLabels as day}
			<div class="day-label">{day}</div>
		{/each}
	</div>

	{#each weeks as week}
		<div class="week">
			{#each week as { date, isSelected, isToday, isCurrentMonth }}
				<button
					class="date-button"
					class:selected={isSelected}
					class:today={isToday}
					class:current-month={isCurrentMonth}
					on:click={() => selectDate(date)}
				>
					{date.getDate()}
				</button>
			{/each}
		</div>
	{/each}
</div>

<style>
	.calendar {
		display: flex;
		flex-direction: column;
		width: 280px;
		min-width: 280px;
		padding: 1rem;
		border-right: 1px solid var(--primary-50);
		gap: 8px;
	}

	.month-header {
		text-align: center;
		font-size: 14px;
		margin-bottom: 8px;
	}

	.day-labels {
		display: flex;
		gap: 4px;
		margin-bottom: 4px;
	}

	.day-label {
		width: 28px;
		text-align: center;
		font-size: 10px;
		color: var(--primary-50);
	}

	.week {
		display: flex;
		gap: 4px;
	}

	.date-button {
		width: 28px;
		height: 28px;
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		background: var(--background-light);
		color: var(--primary-50);
		font-size: 12px;
		cursor: pointer;
		transition: all 0.2s ease;
		padding: 0;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.date-button.current-month {
		color: var(--primary);
	}

	.date-button.today {
		border-color: var(--primary);
	}

	.date-button:hover {
		background: var(--primary-50);
	}

	.date-button.selected {
		background: var(--primary);
		color: var(--background);
		border-color: var(--primary);
	}
</style> 