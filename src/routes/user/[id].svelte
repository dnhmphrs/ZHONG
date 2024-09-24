<script context="module">
  export async function load({ params }) {
    const { id } = params; // Grab the user ID from the URL
    // You can fetch user details here based on the ID, for now let's just return it
    return { id };
  }
</script>

<script>
  export let id; // id will come from the load function
</script>

<div>
  <h1>User ID: {id}</h1>
  <!-- User-specific content can be displayed here -->
</div>
