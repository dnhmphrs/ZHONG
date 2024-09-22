<script>
	import { page } from '$app/stores';
	import { screenType } from '$lib/store/store';
</script>

<header>

	<p>IOTA</p>
	<div class="nav">
		<p>patients</p>
		<p>data</p>
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
		background: #232323;
		border-bottom: 1px solid var(--primary-50);
		position: fixed;
		padding: 0 16px;

		top: 0;
		height: var(--header-height);
		width: 100%;

		box-shadow: var(--shadow);
	}

	p {
		font-size: 14px;
		padding: 2px;
		/* color:var(--background); */
	}

	.nav {
		display: flex;
		gap: 16px;
	}

	a:hover {
		text-underline-offset: 4px;
	}
</style>
