<script>
  let users = Array.from({ length: 30 }, (_, i) => `User ${i + 1}`);
</script>


<div class="list">
  <ul>
    {#each users as user}
      <li>{user}</li>
    {/each}
  </ul>
</div>


<style>
  .list {
    /* padding: var(--margin); */
    max-height: 100%;
    overflow: auto;
    backdrop-filter: blur(5px);
    /* border-top: 1px solid var(--primary); */
  }

  ul {
    margin-top: -8px;
    list-style: none;
    padding: 0;
  }

  li {
    padding: 8px 0;
    border-bottom: 1px solid var(--primary-50);
  }
</style>