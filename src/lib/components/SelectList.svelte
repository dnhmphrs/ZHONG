<script>
    export let title = '';
    export let items = [];
    export let selectedItem = null;
    export let getHeader = (item) => item.name;
    export let getDescription = (item) => '';
    export let onSelect = (item) => {};
</script>

<div class="panel-content">
    <h3 class="panel-header">{title}</h3>
    <div class="list">
        {#each items as item}
            <button 
                class="list-item" 
                class:selected={selectedItem?.id === item.id}
                on:click={() => onSelect(item)}
            >
                <div class="item-header">{getHeader(item)}</div>
                {#if getDescription(item)}
                    <div class="item-description">{getDescription(item)}</div>
                {/if}
            </button>
        {/each}
    </div>
</div>

<style>
    .panel-content {
        padding: 1rem;
        height: 100%;
        display: flex;
        flex-direction: column;
        gap: 1rem;
    }

    .list {
        display: flex;
        flex-direction: column;
        gap: 0.5rem;
        overflow-y: auto;
    }

    .list-item {
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
        padding: 1rem;
        background: var(--background-light);
        border: 1px solid var(--primary-50);
        border-radius: 8px;
        text-align: left;
        transition: all 0.2s ease;
    }

    .list-item:hover {
        border-color: var(--accent);
    }

    .list-item.selected {
        background: var(--primary);
        color: var(--background);
    }

    .item-header {
        font-size: 14px;
        font-weight: 500;
    }

    .item-description {
        font-size: 12px;
        color: var(--primary-50);
    }

    .panel-header {
        text-align: center;
        padding-bottom: 0.5rem;
        border-bottom: 1px solid var(--primary-50);
    }
</style> 