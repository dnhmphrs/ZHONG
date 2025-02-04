// Original background shader implementation
// Fragment Shader
precision highp float;
varying vec2 vUv;
uniform float time;
uniform float aspectRatio;
uniform bool isDarkMode;

void main() {
    float zoom = 1.0;
    float timescale = 0.000125;

    // Theme colors
    vec3 darkBottom = vec3(0.114, 0.114, 0.114);  // #1d1d1d
    vec3 darkTop = vec3(0.137, 0.137, 0.137);     // #232323
    vec3 lightBottom = vec3(0.941, 0.941, 0.941); // #f0f0f0
    vec3 lightTop = vec3(1.0, 1.0, 1.0);          // #ffffff
    
    vec3 bottomColor = isDarkMode ? darkBottom : lightBottom;
    vec3 topColor = isDarkMode ? darkTop : lightTop;

    vec2 adjustedPosition = (vUv - 0.5) / zoom + 0.5;
    adjustedPosition.x *= aspectRatio; // Adjust for aspect ratio

    float bandSize = 0.025;
    float dist = length(adjustedPosition - vec2(0.5, 0.5));
    float bandedDist = fract(dist / bandSize) * bandSize / dist * fract(dist / bandSize);

    // Smoother wave effect
    float wave = 2.71828 * timescale + -sin(bandedDist * 3.142 * 0.5 + (time * timescale));

    float noisePattern = sin(dot(adjustedPosition, vec2(12.9898, 78.233)) * 30.0 + time * timescale)
                       + cos(dot(adjustedPosition, vec2(43.2321, 29.1234)) * 30.0 - time * timescale);
    float noiseEffect = abs(noisePattern);

    float range1 = step(0.1, noiseEffect);
    
    vec3 color = mix(bottomColor, topColor, vUv.y);
    color = mix(bottomColor, color, wave * noiseEffect );

    gl_FragColor = vec4(color, 1.0);
}

// Vertex Shader
attribute vec2 position;
varying vec2 vUv;
void main() {
    vUv = position * 0.5 + 0.5;
    gl_Position = vec4(position, 0, 1);
} 