<script>
  import { goto } from '$app/navigation';

  // Dummy user data
  let users = Array.from({ length: 30 }, (_, i) => ({ id: i + 1, name: `User ${i + 1}` }));

  function selectUser(user) {
    goto(`/user/${user.id}`);
  }
</script>


<div class="list">
  <ul>
    {#each users as user}
      <li on:click={() => selectUser(user)} on:keydown={() => selectUser(user)}>
        {user.name}
      </li>
    {/each}
  </ul>
</div>


<style>
  .list {
    /* padding: var(--margin); */
    max-height: 100%;
    overflow: auto;
    /* border-top: 1px solid var(--primary); */
  }

  ul {
    margin-top: -8px;
    list-style: none;
    padding: 0;
  }

  li {
    cursor: pointer;
    padding: 8px 0;
    border-top: 1px solid var(--primary-50);
  }

  li:hover, li:active {
    color: var(--primary-50);
  }
</style>