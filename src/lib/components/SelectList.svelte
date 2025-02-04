<script>
    export let title = '';
    export let items = [];
    export let selectedPatient = null;
    export let getHeader = (item) => item.toString();
    export let getDescription = (item) => '';
    export let onSelect = (item) => {};
</script>

<div class="panel-content">
    <h3 class="panel-header">{title}</h3>
    <div class="list">
        {#each items as item}
            <button 
                class="list-item" 
                class:selected={selectedPatient?.id === item.id}
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
    }

    .panel-header {
        text-align: left;
        padding-bottom: 0.5rem;
        margin-bottom: 0.5rem;
        color: var(--primary-50);
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        border-bottom: 1px solid var(--primary-50);
    }

    .list {
        height: 100%;
        overflow-y: auto;
    }

    .list-item {
        padding: 0.75rem 0;
        width: 100%;
        text-align: left;
        border: none;
        background: none;
        cursor: pointer;
        transition: background-color 0.2s ease;
        border-bottom: 1px solid var(--primary-50);
        opacity: 0.7;
    }

    .list-item:hover {
        opacity: 1;
    }

    .list-item.selected {
        opacity: 1;
        border-bottom-color: var(--accent);
    }

    .item-header {
        font-size: 13px;
        font-weight: 500;
        margin-bottom: 0.25rem;
    }

    .item-description {
        font-size: 12px;
        color: var(--primary-50);
        line-height: 1.4;
        white-space: pre-line;
    }

    .title {
        padding: 0.75rem 1rem;
        font-size: 12px;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: var(--primary-50);
        border-bottom: 1px solid var(--background);
        background: var(--background-light);
    }
</style> 