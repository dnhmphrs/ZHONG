<script>
  import UserProfile from '$lib/components/user/UserProfile.svelte';
  import UserList from '$lib/components/user/UserList.svelte';
  import UserPage from '$lib/components/user/UserPage.svelte';
</script>

<div class="page">
<div class="sidebar">
  <div class="profile">
    <UserProfile />
  </div>
  <div class="list">
    <UserList />
  </div>
</div>
<UserPage />
</div>

<style>
.page {
  display: flex;
  width: 100%;
  height: 100%;
  gap: 1rem;
}

.sidebar {
  display: flex;
  flex-direction: column;
  gap: var(--margin);
  width: 30%;
  height: 100%;
}

.profile {
  width: 100%;
}

.list {
  width: 100%;
  height: fill-available;
  overflow: hidden;
}
</style>