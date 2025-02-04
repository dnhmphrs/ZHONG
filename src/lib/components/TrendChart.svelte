<script>
    import { onMount } from 'svelte';
    import { darkMode } from '$lib/store/store';
    
    export let data = [];  // Array of {date, value} objects
    export let height = 150;  // Reduced default height
    export let accentColor = false;  // If true, uses accent color, otherwise primary
    
    let canvas;
    let ctx;
    let container;
    let resizeObserver;
    
    $: if (ctx && data && $darkMode !== undefined && canvas.width > 0) {
        drawChart();
    }
    
    onMount(() => {
        ctx = canvas.getContext('2d');
        
        // Set up resize observer
        resizeObserver = new ResizeObserver(entries => {
            for (let entry of entries) {
                const { width } = entry.contentRect;
                canvas.width = width;
                canvas.height = height;
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
        
        const width = canvas.width;
        const padding = 20;
        
        // Clear canvas
        ctx.clearRect(0, 0, width, height);
        
        // Theme-aware colors
        const lineColor = accentColor ? 
            ($darkMode ? 'var(--accent-light)' : 'var(--accent)') :
            ($darkMode ? 'var(--primary-light)' : 'var(--primary)');
        
        const pointColor = accentColor ?
            ($darkMode ? 'var(--accent-light)' : 'var(--accent)') :
            ($darkMode ? 'var(--primary-light)' : 'var(--primary)');
        
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
        
        ctx.strokeStyle = lineColor;
        ctx.lineWidth = 2;
        ctx.stroke();
        
        // Draw points
        points.forEach(point => {
            ctx.beginPath();
            ctx.arc(point.x, point.y, 4, 0, 2 * Math.PI);
            ctx.fillStyle = pointColor;
            ctx.fill();
        });
    }
</script>

<div bind:this={container} style="width: 100%; height: {height}px;">
    <canvas 
        bind:this={canvas}
        style="width: 100%; height: 100%;"
    />
</div> 