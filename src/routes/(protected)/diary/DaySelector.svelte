<script>
	import { createEventDispatcher } from 'svelte';
	
	export let selectedDate;
	
	const dispatch = createEventDispatcher();
	const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
	
	$: currentMonth = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1);
	
	function generateDates(monthDate) {
		const dates = [];
		const year = monthDate.getFullYear();
		const month = monthDate.getMonth();
		
		// Get first day of month and how many days to pad from previous month
		const firstDay = new Date(year, month, 1);
		const startPadding = firstDay.getDay() || 7; // Convert Sunday (0) to 7
		
		// Add padding days from previous month
		const prevMonth = new Date(year, month, 0);
		for (let i = startPadding - 1; i >= 0; i--) {
			dates.push({
				date: new Date(year, month - 1, prevMonth.getDate() - i),
				isCurrentMonth: false,
				isToday: false,
				isSelected: false
			});
		}
		
		// Add days of current month
		const daysInMonth = new Date(year, month + 1, 0).getDate();
		const today = new Date();
		for (let i = 1; i <= daysInMonth; i++) {
			const date = new Date(year, month, i);
			dates.push({
				date,
				isCurrentMonth: true,
				isToday: isSameDay(date, today),
				isSelected: isSameDay(date, selectedDate)
			});
		}
		
		// Add padding days from next month to complete the grid
		const remainingDays = 42 - dates.length; // Always show 6 weeks
		for (let i = 1; i <= remainingDays; i++) {
			dates.push({
				date: new Date(year, month + 1, i),
				isCurrentMonth: false,
				isToday: false,
				isSelected: false
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
	
	function handleDateClick(date) {
		dispatch('dateSelect', { date });
	}

	function changeMonth(delta) {
		currentMonth = new Date(currentMonth.getFullYear(), currentMonth.getMonth() + delta, 1);
	}
	
	$: dates = generateDates(currentMonth);
	$: weeks = groupIntoWeeks(dates);
</script>

<div class="calendar">
	<div class="header">
		<button class="nav-button" on:click={() => changeMonth(-1)}>←</button>
		<h3>{monthNames[currentMonth.getMonth()]} {currentMonth.getFullYear()}</h3>
		<button class="nav-button" on:click={() => changeMonth(1)}>→</button>
	</div>
	
	<div class="weekdays">
		<div>Mon</div>
		<div>Tue</div>
		<div>Wed</div>
		<div>Thu</div>
		<div>Fri</div>
		<div>Sat</div>
		<div>Sun</div>
	</div>
	
	<div class="month">
		{#each weeks as week}
			<div class="week">
				{#each week as { date, isCurrentMonth, isToday, isSelected }}
					<button 
						class="date-button" 
						class:current-month={isCurrentMonth}
						class:today={isToday}
						class:selected={isSelected}
						on:click={() => handleDateClick(date)}
					>
						{date.getDate()}
					</button>
				{/each}
			</div>
		{/each}
	</div>
</div>

<style>
	.calendar {
		display: flex;
		flex-direction: column;
		gap: 8px;
		padding: 16px;
		background: var(--background-light);
		border: 1px solid var(--primary-50);
		border-radius: 8px;
	}

	.header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0 8px;
	}

	.nav-button {
		padding: 4px 8px;
		background: none;
		border: none;
		color: var(--primary);
		cursor: pointer;
		font-size: 16px;
	}

	.nav-button:hover {
		color: var(--accent);
	}

	.weekdays {
		display: grid;
		grid-template-columns: repeat(7, 1fr);
		text-align: center;
		font-size: 12px;
		color: var(--primary-50);
		padding: 8px 0;
	}

	.month {
		display: flex;
		flex-direction: column;
		gap: 4px;
	}

	.week {
		display: grid;
		grid-template-columns: repeat(7, 1fr);
		gap: 4px;
	}

	.date-button {
		width: 32px;
		height: 32px;
		border: 1px solid var(--primary-50);
		border-radius: 8px;
		background: var(--background-light);
		color: var(--primary-50);
		font-size: 12px;
		cursor: pointer;
		padding: 0;
		display: flex;
		align-items: center;
		justify-content: center;
		transition: all 0.2s ease;
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

	h3 {
		font-size: 14px;
		margin: 0;
		min-width: 160px;
		text-align: center;
	}
</style> 