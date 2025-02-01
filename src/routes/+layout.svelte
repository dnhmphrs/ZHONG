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
	import { auth } from '$lib/store/auth';

	export let data;
	let Geometry;
	let authState;
	let fontsLoaded = false;

	auth.subscribe(state => {
		authState = state;
		// Handle localStorage in the component
		if (authState?.profile?.role === 'clinician' && typeof window !== 'undefined') {
			if (authState.viewPreference) {
				localStorage.setItem('viewPreference', authState.viewPreference);
			} else {
				const stored = localStorage.getItem('viewPreference');
				if (stored) {
					authState.viewPreference = stored;
				}
			}
		}
	});

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

	$: if (authState?.initialized) {
		const isProtectedRoute = $page.url.pathname.startsWith('/diary') || 
								$page.url.pathname.startsWith('/clinician');
		
		if (isProtectedRoute && !authState.session) {
			goto('/login');
		} else if (
			(authState.profile?.role === 'patient' || authState.viewPreference === 'personal') && 
			$page.url.pathname.startsWith('/clinician')
		) {
			goto('/diary');
		}
	}

	onMount(() => {
		auth.initializeAuth();

		// Check if fonts are loaded
		document.fonts.ready.then(() => {
			fontsLoaded = true;
		});

		// webgl - 
		// const module = await import('$lib/graphics/webgl.svelte');
		// Geometry = module.default;

		// Remove these lines since fetchLeaderboard is commented out
		// let leader = fetchLeaderboard();
		// console.log(leader);

		handleScreen();
		window.addEventListener('resize', () => handleScreen());

		return () => {
			window.removeEventListener('resize', () => handleScreen());
		};
	});
</script>

<svelte:head>
	<title>IOTA : DEMO</title>
	<meta name="description" content="demo site." />
	<meta name="keywords" content="" />
	<meta name="author" content="IOTA" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
	
	<!-- Preload fonts -->
	<link 
		rel="preload" 
		href="/fonts/NB-Architekt-Pro-Light.woff" 
		as="font" 
		type="font/woff" 
		crossorigin
	/>
	<link 
		rel="preload" 
		href="/fonts/NB-Architekt-Pro-Bold.woff" 
		as="font" 
		type="font/woff" 
		crossorigin
	/>
</svelte:head>

{#if !authState?.initialized || !fontsLoaded}
	<div class="loading">Loading...</div>
{:else}
	<div class="app">
		<Header 
			data={{ 
				session: authState.session ? {
					user: authState.session.user,
					role: authState.profile?.role,
					viewPreference: authState.viewPreference
				} : null
			}} 
			initialized={authState.initialized}
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
		opacity: 0;
		animation: fadeIn 0.3s ease-in forwards;
	}

	.loading {
		display: flex;
		justify-content: center;
		align-items: center;
		height: 100vh;
		width: 100vw;
		opacity: 0;
		animation: fadeIn 0.3s ease-in forwards;
	}

	@keyframes fadeIn {
		from { opacity: 0; }
		to { opacity: 1; }
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
