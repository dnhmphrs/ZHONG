<script>
	import { page } from '$app/stores';
	import { screenType, darkMode } from '$lib/store/store';
	import { supabase } from '$lib/backend/supabase';
	import { goto } from '$app/navigation';

	export let data;
	export let initialized = false;
	
	$: userRole = data?.session?.role;
	$: viewPreference = data?.session?.viewPreference;
	$: isAuthenticated = !!data?.session?.user;
	$: showClinicalFeatures = isAuthenticated && userRole === 'clinician' && viewPreference === 'clinical';

	async function signOut() {
		try {
			// Clear any stored auth data first
			if (typeof window !== 'undefined') {
				localStorage.removeItem('sb-auth-token');
				localStorage.removeItem('viewPreference');
				document.cookie = 'sb-auth-token=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT';
			}

			const { error } = await supabase.auth.signOut();
			// Always redirect, even if there's an error
			window.location.href = '/login';
		} catch (e) {
			console.error('Sign out error:', e);
			// Force redirect even if there's an error
			window.location.href = '/login';
		}
	}

	function toggleDarkMode() {
		darkMode.update(current => !current);
	}
</script>

<header>
	<h2>IOTA</h2>
	<div class="nav">
		{#if initialized && isAuthenticated}
			{#if showClinicalFeatures}
				<a href="/clinician/patients">patients</a>
				<a href="/clinician/cohorts">cohorts</a>
				<a href="/clinician/analytics">analytics</a>
			{:else}
				<a href="/diary">my diary</a>
			{/if}
			<button class="icon-button" on:click={toggleDarkMode}>
				{#if $darkMode}
					☀️
				{:else}
					🌙
				{/if}
			</button>
			<button on:click={signOut}>sign out</button>
		{:else}
			<button class="icon-button" on:click={toggleDarkMode}>
				{#if $darkMode}
					☀️
				{:else}
					🌙
				{/if}
			</button>
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

	.icon-button {
		padding: 4px 8px;
		font-size: 14px;
		background: none;
		border: none;
		cursor: pointer;
	}

	.icon-button:hover {
		transform: scale(1.1);
	}
</style>
