<script>
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { supabase } from '$lib/backend/supabase';
	import UserProfile from '$lib/components/user/userProfile.svelte';
	import UserList from '$lib/components/user/userList.svelte';
	import UserPage from '$lib/components/user/userPage.svelte';

	onMount(async () => {
		const { data: { session } } = await supabase.auth.getSession();
		
		if (!session) {
			goto('/login');
			return;
		}

		// Check if user is clinician
		const { data: clinicianData } = await supabase
			.from('clinician')
			.select('id')
			.eq('id', session.user.id)
			.single();

		if (clinicianData) {
			goto('/clinician');
		} else {
			goto('/diary');
		}
	});
</script>

<div class="container">
	<h1>Welcome to Diary Study</h1>
	<p>Redirecting to appropriate dashboard...</p>
</div>

<style>
	.container {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		height: 100vh;
	}
</style>
