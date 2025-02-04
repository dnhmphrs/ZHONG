precision highp float;
varying vec2 vUv;
uniform float time;
uniform float aspectRatio;
uniform bool isDarkMode;

// Improved metaball function with softer falloff
float metaball(vec2 p, vec2 center, float radius) {
    float d = length(p - center);
    float falloff = pow(radius / d, 0.05);
    return falloff * (1.0 - smoothstep(0.0, radius * 1.0, d));
}

// Improved noise function for better shading
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = sin(dot(i, vec2(12.9898, 78.233))) * 43758.5453;
    float b = sin(dot(i + vec2(1.0, 0.0), vec2(12.9898, 78.233))) * 43758.5453;
    float c = sin(dot(i + vec2(0.0, 1.0), vec2(12.9898, 78.233))) * 43758.5453;
    float d = sin(dot(i + vec2(1.0, 1.0), vec2(12.9898, 78.233))) * 43758.5453;
    f = f * f * (3.0 - 2.0 * f);
    return cos(mix(mix(a, b, f.x), mix(c, d, f.x), f.y));
}

void main() {
    float zoom = 1.0;
    float timescale = 0.000125;

    // Theme colors
    vec3 darkBottom = vec3(0.114, 0.114, 0.114);  // ?
    vec3 darkTop = vec3(0.137, 0.137, 0.137);     // ?
    vec3 lightBottom =  vec3(0.97, 0.97, 0.97);   // ?
    vec3 lightTop = vec3(0.941, 0.941, 0.941);    // ?
    
    vec3 bottomColor = isDarkMode ? darkBottom : lightBottom;
    vec3 topColor = isDarkMode ? darkTop : lightTop;

    vec2 adjustedPosition = (vUv - 0.5) / zoom + 0.5;
    adjustedPosition.x *= aspectRatio; // Adjust for aspect ratio

    // Background noise
    float noisePattern = sin(dot(adjustedPosition, vec2(12.9898, 78.233)) * 30.0 + time * timescale)
                      + cos(dot(adjustedPosition, vec2(43.2321, 29.1234)) * 30.0 - time * timescale);
    float noiseEffect = abs(noisePattern);
    
    // Metaballs with more variety
    float metaballs = 0.1;
    float slowTime = time * 0.0003;
    
    // More spread out positions with varied movement
    vec2 center1 = vec2(0.3 + sin(slowTime) * 0.3, 0.3 + cos(slowTime * 1.2) * 0.3);
    vec2 center2 = vec2(0.7 + cos(slowTime * 0.7) * 0.3, 0.7 + sin(slowTime * 0.9) * 0.3);
    vec2 center3 = vec2(0.2 + sin(slowTime * 1.1) * 0.25, 0.8 + cos(slowTime * 0.8) * 0.25);
    vec2 center4 = vec2(0.8 + cos(slowTime * 0.9) * 0.25, 0.0 + sin(slowTime * 1.3) * 0.25);
    vec2 center5 = vec2(0.5 + sin(slowTime * 1.4) * 0.4, 0.5 + cos(slowTime * 0.6) * 0.4);
    vec2 center6 = vec2(1.5 + cos(slowTime * 0.8) * 0.2, 0.5 + sin(slowTime * 1.1) * 0.3);
    
    // Larger radii
    metaballs += metaball(adjustedPosition, center1, 0.25);
    metaballs += metaball(adjustedPosition, center2, 0.22);
    metaballs += metaball(adjustedPosition, center3, 0.20);
    metaballs += metaball(adjustedPosition, center4, 0.23);
    metaballs += metaball(adjustedPosition, center5, 0.24);
    metaballs += metaball(adjustedPosition, center6, 0.21);
    
    // Enhanced shading with multiple noise layers
    float blobShade = metaballs;
    float noiseScale1 = 1.0;
    float noiseScale2 = 1.0;
    float noiseTime = time * 0.0001;
    
    vec2 noisePos = adjustedPosition + vec2(cos(noiseTime), sin(noiseTime)) * 0.1;
    float noise1 = noise(noisePos * noiseScale1);
    float noise2 = noise(noisePos * noiseScale2);
    
    blobShade *= 0.1 + noise1 * 0.1 + noise2 * 0.1;
    
    float metaballEffect = smoothstep(0.5, 1.1, blobShade);
    
    // More dramatic color variation for metaballs
    vec3 metaballColor = isDarkMode ? 
        vec3(0.25 + metaballEffect * 0.15 + noise1 * 0.1) :
        vec3(0.9 - metaballEffect * 0.15 - noise2 * 0.1);
    
    // Base color with noise
    vec3 color = mix(bottomColor, topColor, vUv.y + noiseEffect);
    
    color = mix(color, metaballColor, metaballEffect * 0.8);

    gl_FragColor = vec4(color, 1.0);
} 