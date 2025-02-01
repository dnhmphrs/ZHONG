<script>
	import { createEventDispatcher } from 'svelte';
	
	export let selectedDate;
	
	const dispatch = createEventDispatcher();
	const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
	
	// Generate dates for display (current date +/- 3 weeks)
	$: dates = generateDates(selectedDate);
	$: weeks = groupIntoWeeks(dates);
	
	function generateDates(centerDate) {
		const dates = [];
		const startDate = new Date(centerDate);
		startDate.setDate(startDate.getDate() - 21); // 3 weeks back
		
		for (let i = 0; i < 42; i++) { // 6 weeks total
			const date = new Date(startDate);
			date.setDate(date.getDate() + i);
			dates.push({
				date,
				isNewMonth: date.getDate() === 1 || i === 0,
				isSelected: isSameDay(date, selectedDate)
			});
		}
		
		return dates;
	}

	function groupIntoWeeks(dates) {
		const weeks = [];
		for (let i = 0; i < dates.length; i += 7) {
			weeks.push(dates.slice(i, i + 7));
		}
		return weeks;
	}
	
	function isSameDay(d1, d2) {
		return d1.getDate() === d2.getDate() &&
			d1.getMonth() === d2.getMonth() &&
			d1.getFullYear() === d2.getFullYear();
	}
	
	function selectDate(date) {
		dispatch('dateSelect', { date });
	}
</script>

<div class="calendar">
	{#each weeks as week}
		<div class="week">
			<div class="month-column">
				{#if week[0].isNewMonth}
					<div class="month">
						{monthNames[week[0].date.getMonth()]}
					</div>
				{:else}
					<div class="month-spacer" />
				{/if}
			</div>
			<div class="days-row">
				{#each week as { date, isSelected }}
					<button
						class="date-button"
						class:selected={isSelected}
						on:click={() => selectDate(date)}
					>
						{date.getDate()}
					</button>
				{/each}
			</div>
		</div>
	{/each}
</div>

<style>
	.calendar {
		display: flex;
		flex-direction: column;
		gap: 8px;
		min-width: 320px;
		padding: 1rem;
		border-right: 1px solid var(--primary-50);
	}

	.week {
		display: flex;
		align-items: center;
		gap: 12px;
	}

	.month-column {
		width: 40px;
	}

	.month {
		font-size: 12px;
		color: var(--primary);
		text-align: right;
	}

	.month-spacer {
		height: 16px;
	}

	.days-row {
		display: flex;
		gap: 4px;
	}

	.date-button {
		width: 32px;
		height: 32px;
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		background: var(--background-light);
		color: var(--primary);
		font-size: 12px;
		cursor: pointer;
		transition: all 0.2s ease;
	}

	.date-button:hover {
		background: var(--primary-50);
	}

	.date-button.selected {
		background: var(--primary);
		color: var(--background);
	}
</style> 