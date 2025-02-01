<script>
	import { page } from '$app/stores';
	import { screenType } from '$lib/store/store';
	import { supabase } from '$lib/backend/supabase';
	import { goto } from '$app/navigation';

	export let data;
	export let initialized = false;
	
	$: {
		console.log('Header data:', data);
		console.log('Header initialized:', initialized);
		console.log('Header userRole:', data?.session?.role);
		console.log('Header isAuthenticated:', !!data?.session?.user);
	}

	$: userRole = data?.session?.role;
	$: isAuthenticated = !!data?.session?.user;

	async function signOut() {
		const { error } = await supabase.auth.signOut();
		if (!error) {
			window.location.href = '/login';  // Force a full page reload
		}
	}
</script>

<header>
	<h2>IOTA</h2>
	<div class="nav">
		{#if initialized && isAuthenticated}
			<!-- Show clinician features if user is a clinician -->
			{#if userRole === 'clinician'}
				<a href="/clinician/patients">patients</a>
				<a href="/clinician/cohorts">cohorts</a>
				<a href="/clinician/analytics">analytics</a>
			{/if}
			<!-- Show patient features for all users -->
			<a href="/diary">my diary</a>
			<button on:click={signOut}>sign out</button>
		{/if}
	</div>
	<!-- {#if $screenType==3}
	<h1 style="padding-right:10px;">PRESS SPACEBAR</h1>
	{/if} -->
	
	<!-- {#if $page.url.pathname == '/'}
	<a href='/about'><h1 style="padding-left:10px;">ABOUT // CONTACT</h1></a>
	{:else }
	<a href='/'><h1 style="padding-left:10px;min-width: 200px;">HOME<span style="font-size: 20px; margin-left: 100px;">↝</span></h1></a>
	{/if} -->

</header>

<style>
	header {
		user-select: none;
		color: var(--primary);
		display: flex;
		justify-content: space-between;
		align-items: center;
		background: var(--background-light);
		border-bottom: 1px solid var(--primary-50);
		position: fixed;
		padding: 0 16px;

		top: 0;
		height: var(--header-height);
		width: 100%;

		box-shadow: var(--shadow);
	}

	h2 {
		font-size: 16px;
	}

	.nav {
		display: flex;
		gap: 16px;
		align-items: center;
	}

	.nav a {
		font-size: 12px;
		padding: 2px;
		text-decoration: none;
		color: var(--primary);
	}

	.nav a:hover {
		text-decoration: underline;
		text-underline-offset: 4px;
	}

	button {
		font-size: 12px;
		padding: 4px 8px;
		background: none;
		border: 1px solid var(--primary-50);
		border-radius: 4px;
		color: var(--primary);
		cursor: pointer;
	}

	button:hover {
		background: var(--primary-50);
	}
</style>
