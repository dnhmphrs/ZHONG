<script>
	import './styles.css';

	// temp
	// import { fetchLeaderboard, setNewPlayerID } from '$lib/backend/api';

	import Header from '$lib/components/header/header.svelte';

	import { browser } from '$app/environment';
	import { page } from '$app/stores';
	import { webVitals } from '$lib/vitals';

	import { onMount } from 'svelte';
	import { screenType, isIframe, screenSize } from '$lib/store/store';
	import { getDeviceType, getScreenSize } from '$lib/functions/utils';
	import { supabase } from '$lib/backend/supabase';
	import { invalidate, goto } from '$app/navigation';
	import { writable } from 'svelte/store';

	export let data;
	let Geometry;
	let initialized = false;
	let session = null;
	let profile = null;

	// Create a store for auth state that's accessible to child routes
	export const authStore = writable({ session: null, profile: null });

	$: if (browser && data?.analyticsId) {
		webVitals({
			path: $page.url.pathname,
			params: $page.params,
			analyticsId: data.analyticsId
		});
	}

	function handleScreen() {
		// screen size
		screenSize.set(getScreenSize());

		// device type
		screenType.set(getDeviceType());
		isIframe.set(window.location !== window.parent.location);
	}

	async function initializeAuth() {
		const { data: { session: authSession } } = await supabase.auth.getSession();
		console.log('initializeAuth session:', authSession);
		if (authSession) {
			const { data: profileData } = await supabase
				.from('profile')
				.select('role')
				.eq('id', authSession.user.id)
				.single();
			
			console.log('initializeAuth profile:', profileData);
			session = authSession;
			profile = profileData;
			authStore.set({ 
				session: {
					user: authSession.user,
					role: profileData.role
				}, 
				profile: profileData 
			});
		}
		initialized = true;
	}

	// Only check protected routes after initialization AND when we have definitive auth state
	$: if (initialized) {
		const isProtectedRoute = $page.url.pathname.startsWith('/diary') || 
								$page.url.pathname.startsWith('/clinician');
		
		if (isProtectedRoute && !session) {
			goto('/login');
		} else if (profile?.role === 'patient' && $page.url.pathname.startsWith('/clinician')) {
			goto('/diary');
		}
	}

	onMount(async () => {
		await initializeAuth();

		// Listen for auth changes
		const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, newSession) => {
			// Reset initialized state for sign out
			if (event === 'SIGNED_OUT') {
				session = null;
				profile = null;
				authStore.set({ session: null, profile: null });
				goto('/login');
				return;
			}

			session = newSession;
			if (session) {
				const { data: profileData } = await supabase
					.from('profile')
					.select('role')
					.eq('id', session.user.id)
					.single();
				profile = profileData;
				authStore.set({ session, profile });
			} else {
				profile = null;
				authStore.set({ session: null, profile: null });
			}
		});

		// webgl
		const module = await import('$lib/graphics/webgl.svelte');
		Geometry = module.default;

		// Remove these lines since fetchLeaderboard is commented out
		// let leader = fetchLeaderboard();
		// console.log(leader);

		handleScreen();
		window.addEventListener('resize', () => handleScreen());

		return () => {
			window.removeEventListener('resize', () => handleScreen());
			subscription.unsubscribe();
		};
	});
</script>

<svelte:head>
	<title>IOTA : DEMO</title>
	<meta name="description" content="demo site." />
	<meta name="keywords" content="" />
	<meta name="author" content="IOTA" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
</svelte:head>

{#if !initialized}
	<div class="loading">Loading...</div>
{:else}
	<div class="app">
		<Header 
			data={{ 
				session: session ? {
					user: session.user,
					role: profile?.role
				} : null
			}} 
			{initialized}
		/>
		<main>
			<slot />
		</main>
	</div>
{/if}

<style>
	.app {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		height: 100dvh;
		max-height: 100vh;
		width: 100%;
		overflow: hidden;
		background: var(--background);
	}

	.loading {
		display: flex;
		justify-content: center;
		align-items: center;
		height: 100vh;
		width: 100vw;
	}

	main {
		flex: 1;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		padding: 1rem;
		width: 100%;
		height: calc(100dvh - var(--header-height));
		bottom: 0;
		position: absolute;
	}
</style>
