<script>
    import { auth } from '$lib/store/auth';
    import { diaryStore } from '$lib/store/diary';
    import TrendChart from '$lib/components/TrendChart.svelte';
    import { onMount } from 'svelte';

    let selectedDate = new Date();
    
    // Get last 30 days of entries for trends
    onMount(async () => {
        await diaryStore.loadAspects();
        await diaryStore.loadEntries(selectedDate);
    });

    // Compute trends similar to clinician view
    $: moodTrend = $diaryStore.entries
        .filter(e => e.aspect?.name === 'Mood' && e.content_scale)
        .map(e => ({
            date: new Date(e.entry_date),
            value: e.content_scale
        }))
        .sort((a, b) => a.date - b.date);
        
    $: sleepTrend = $diaryStore.entries
        .filter(e => e.aspect?.name === 'Sleep Quality' && e.content_scale)
        .map(e => ({
            date: new Date(e.entry_date),
            value: e.content_scale
        }))
        .sort((a, b) => a.date - b.date);

    $: hasTrendData = moodTrend.length > 1 || sleepTrend.length > 1;

    // Compute stats
    $: completionRate = (() => {
        // Debug logging for all state
        console.log('=== Completion Rate Debug ===');
        console.log('Selected Date:', selectedDate);
        console.log('Today Entries:', $diaryStore.todayEntries.map(e => ({
            date: e.entry_date,
            aspect: e.aspect?.name,
            id: e.id
        })));
        console.log('All Aspects:', $diaryStore.aspects.map(a => ({
            id: a.id,
            name: a.name
        })));
        
        // Get unique aspects for today
        const uniqueAspectIds = new Set();
        $diaryStore.todayEntries.forEach(entry => {
            if (entry.aspect?.id) {
                uniqueAspectIds.add(entry.aspect.id);
            }
        });
        
        // Calculate completion
        const uniqueCount = uniqueAspectIds.size;
        const totalAspects = $diaryStore.aspects.length;
        const percentage = (uniqueCount / (totalAspects || 1)) * 100;
        
        console.log('Completion Calculation:', {
            uniqueAspectIds: Array.from(uniqueAspectIds),
            uniqueCount,
            totalAspects,
            percentage
        });
        
        return Math.round(percentage);
    })();

    $: daysLogged = (() => {
        // Count days with at least one entry
        const uniqueDays = new Set($diaryStore.entries.map(e => e.entry_date));
        return uniqueDays.size;
    })();

    $: averageMood = (() => {
        if (!$diaryStore.entries.length) return null;
        
        const moodEntries = $diaryStore.entries.filter(e => e.aspect?.name === 'Mood' && e.content_scale);
        const totalMood = moodEntries.reduce((total, e) => total + e.content_scale, 0);
        return totalMood / moodEntries.length;
    })();

    $: streak = (() => {
        if (!$diaryStore.entries.length) return 0;
        
        let maxStreak = 0;
        let currentStreak = 0;
        let lastDate = null;

        $diaryStore.entries.forEach(e => {
            if (e.entry_date === lastDate) {
                currentStreak++;
            } else {
                currentStreak = 1;
            }
            if (currentStreak > maxStreak) {
                maxStreak = currentStreak;
            }
            lastDate = e.entry_date;
        });

        return maxStreak;
    })();
</script>

<div class="page-layout">
    <div class="welcome-section">
        <div class="welcome-content">
            <h2>Welcome back{$auth.session?.user?.name ? `, ${$auth.session.user.name}` : ''}! 👋</h2>
            <p class="subtitle">Here's your wellness journey at a glance</p>
        </div>
        <div class="quick-action">
            <a href="/diary" class="action-button">
                Add Today's Entry
                <span class="arrow">→</span>
            </a>
        </div>
    </div>

    <div class="overview-grid">
        <div class="stats-card">
            <h3>This Month's Progress</h3>
            <div class="stats-grid">
                <div class="stat-item">
                    <div class="stat-value">{completionRate}%</div>
                    <div class="stat-label">Completion Rate</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value">{daysLogged}</div>
                    <div class="stat-label">Days Logged</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value">{averageMood?.toFixed(1) || '-'}</div>
                    <div class="stat-label">Avg Mood</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value">{streak}</div>
                    <div class="stat-label">Day Streak</div>
                </div>
            </div>
        </div>

        <div class="cohorts-card">
            <h3>Your Care Programs</h3>
            <div class="cohort-list">
                <div class="cohort-item">
                    <div class="cohort-header">
                        <span class="cohort-name">Depression Study Group A</span>
                        <span class="cohort-badge active">Active</span>
                    </div>
                    <span class="cohort-meta">Week 3 of 8 • Dr. Smith</span>
                </div>
                <div class="cohort-item">
                    <div class="cohort-header">
                        <span class="cohort-name">Anxiety Management</span>
                        <span class="cohort-badge upcoming">Starting Soon</span>
                    </div>
                    <span class="cohort-meta">Starts Feb 15 • Dr. Johnson</span>
                </div>
            </div>
        </div>
    </div>

    <div class="trends-section">
        <h3>30-Day Wellness Trends</h3>
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
            <div class="empty-state">
                <p>No trend data available yet</p>
                <p class="empty-subtitle">Start logging daily entries to see your progress over time</p>
            </div>
        {/if}
    </div>
</div>

<style>
    .page-layout {
        padding: 2rem;
        max-width: 1200px;
        margin: 0 auto;
        display: flex;
        flex-direction: column;
        gap: 2rem;
    }

    .welcome-section {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 2rem;
    }

    .welcome-content {
        flex: 1;
    }

    .subtitle {
        color: var(--primary-50);
        margin-top: 0.5rem;
    }

    .overview-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 2rem;
    }

    .stats-card, .cohorts-card {
        background: var(--background-light);
        border: 1px solid var(--primary-50);
        border-radius: 8px;
        padding: 1.5rem;
    }

    .stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 1.5rem;
        margin-top: 1rem;
    }

    .stat-item {
        text-align: center;
    }

    .stat-value {
        font-size: 2rem;
        font-weight: 500;
        color: var(--primary);
    }

    .stat-label {
        color: var(--primary-50);
        font-size: 0.875rem;
        margin-top: 0.25rem;
    }

    .cohort-list {
        margin-top: 1rem;
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .cohort-item {
        padding: 1rem;
        background: var(--background);
        border-radius: 4px;
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
    }

    .cohort-name {
        font-weight: 500;
    }

    .cohort-meta {
        font-size: 0.875rem;
        color: var(--primary-50);
    }

    .trends-section {
        margin-top: 1rem;
    }

    .trends-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 2rem;
        margin-top: 1rem;
    }

    .trend-card {
        background: var(--background-light);
        border: 1px solid var(--primary-50);
        border-radius: 8px;
        padding: 1.5rem;
    }

    .trend-header {
        font-size: 0.875rem;
        font-weight: 500;
        margin-bottom: 1rem;
    }

    .empty-state {
        text-align: center;
        color: var(--primary-50);
        font-style: italic;
        padding: 2rem;
        background: var(--background-light);
        border: 1px solid var(--primary-50);
        border-radius: 8px;
    }

    h2, h3 {
        margin: 0;
    }

    h3 {
        color: var(--primary-50);
        font-size: 0.875rem;
        text-transform: uppercase;
        letter-spacing: 0.1em;
    }

    .quick-action {
        display: flex;
        align-items: center;
    }

    .action-button {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        padding: 0.75rem 1.5rem;
        background: var(--accent);
        color: var(--background);
        border-radius: 8px;
        text-decoration: none;
        font-weight: 500;
        transition: transform 0.2s;
    }

    .action-button:hover {
        transform: translateX(4px);
    }

    .arrow {
        font-size: 1.2em;
    }

    .cohort-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 1rem;
    }

    .cohort-badge {
        font-size: 0.75rem;
        padding: 0.25rem 0.5rem;
        border-radius: 12px;
        font-weight: 500;
    }

    .cohort-badge.active {
        background: var(--accent);
        color: var(--background);
    }

    .cohort-badge.upcoming {
        background: var(--primary-50);
        color: var(--background);
    }

    .empty-subtitle {
        font-size: 0.875rem;
        margin-top: 0.5rem;
    }
</style> 