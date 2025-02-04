<script>
    import { onMount } from 'svelte';
    import { darkMode } from '$lib/store/store';
    
    export let data = [];  // Array of {date, value} objects
    export let height = 150;  // Reduced default height
    
    let canvas;
    let ctx;
    let container;
    let resizeObserver;
    
    $: if (ctx && data && $darkMode !== undefined && canvas.width > 0) {
        drawChart();
    }
    
    function setupCanvas() {
        const dpr = window.devicePixelRatio || 1;
        const rect = container.getBoundingClientRect();
        
        canvas.width = rect.width * dpr;
        canvas.height = height * dpr;
        
        ctx.scale(dpr, dpr);
        canvas.style.width = `${rect.width}px`;
        canvas.style.height = `${height}px`;
    }
    
    onMount(() => {
        ctx = canvas.getContext('2d');
        setupCanvas();
        
        resizeObserver = new ResizeObserver(entries => {
            for (let entry of entries) {
                setupCanvas();
                drawChart();
            }
        });
        
        resizeObserver.observe(container);
        drawChart();
        
        return () => {
            if (resizeObserver) {
                resizeObserver.disconnect();
            }
        };
    });
    
    function drawChart() {
        if (!ctx || !data || data.length < 2) return;
        
        const dpr = window.devicePixelRatio || 1;
        const width = canvas.width / dpr;
        const padding = 20;
        
        // Clear canvas
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        // Get computed primary color from the container element
        const color = getComputedStyle(container).getPropertyValue('color');
        
        // Find min/max values
        const values = data.map(d => d.value);
        const minValue = Math.min(...values);
        const maxValue = Math.max(...values);
        const valueRange = maxValue - minValue;
        
        // Scale points to canvas
        const points = data.map((d, i) => ({
            x: padding + (i * (width - 2 * padding) / (data.length - 1)),
            y: height - padding - ((d.value - minValue) * (height - 2 * padding) / valueRange)
        }));
        
        // Draw line
        ctx.beginPath();
        ctx.moveTo(points[0].x, points[0].y);
        
        for (let i = 1; i < points.length; i++) {
            const xc = (points[i].x + points[i - 1].x) / 2;
            const yc = (points[i].y + points[i - 1].y) / 2;
            ctx.quadraticCurveTo(points[i - 1].x, points[i - 1].y, xc, yc);
        }
        
        ctx.strokeStyle = color;
        ctx.lineWidth = 2;
        ctx.stroke();
        
        // Draw points
        points.forEach(point => {
            ctx.beginPath();
            ctx.arc(point.x, point.y, 4, 0, 2 * Math.PI);
            ctx.fillStyle = color;
            ctx.fill();
        });
    }
</script>

<div 
    bind:this={container} 
    style="width: 100%; height: {height}px; color: var(--accent);"
>
    <canvas 
        bind:this={canvas}
    />
</div> 