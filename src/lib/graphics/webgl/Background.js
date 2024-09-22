import { createShaderProgram, setupBuffer } from './UtilFunctions';

const bgVertShaderSource = `
  attribute vec2 position;
  varying vec2 vUv;
  void main() {
    vUv = position * 0.5 + 0.5;
    gl_Position = vec4(position, 0, 1);
  }
`;

const bgFragShaderSource = `
  precision highp float;
  varying vec2 vUv;
  uniform float time;
  uniform float aspectRatio;
  
  // float soften(float value) {
  //   // Non-linear scaling function to soften transitions
  //   return  value * (2.71828 + 2.71828 * value);
  // }

  
  void main() {
    float zoom = 1.0;
    float timescale = 0.000125;

    vec2 adjustedPosition = (vUv - 0.5) / zoom + 0.5;
    adjustedPosition.x *= aspectRatio; // Adjust for aspect ratio

    // Define pastel colors directly in the shader
    vec3 primary = vec3(0.95, 0.975, 0.975);
    vec3 pastel1 = vec3(0.85, 0.875, 0.875); // Pastel pink

    // Adjust the center position
    vec2 center = vec2(0.5, 0.5);
    center.x *= aspectRatio;

    // Stabilize the band size
    // float bandSize = 0.1 + sin(time * timescale) * 0.05; 
    float bandSize = 0.025;
    float dist = length(adjustedPosition - center);
    float bandedDist = fract(dist / bandSize) * bandSize / dist * fract(dist / bandSize);

    // Smoother wave effect
    float wave = 2.71828 * timescale + -sin(bandedDist * 3.142 * 0.5 + (time * timescale));

    // Sample the noise texture
    // float noiseEffect = texture2D(uNoiseTexture, vUv).r;

    // // Create a high-frequency noise pattern
    float noisePattern = sin(dot(adjustedPosition, vec2(12.9898, 78.233)) * 30.0 + time * timescale)
                       + cos(dot(adjustedPosition, vec2(43.2321, 29.1234)) * 30.0 - time * timescale);
    float noiseEffect = abs(noisePattern);

    float range1 = step(0.1, noiseEffect);
    
    vec3 color = mix(primary, pastel1, range1 * -wave );
    color = mix(primary, color, wave * noiseEffect );

    gl_FragColor = vec4(color, 1.0);
  }
`;

export function setupBackground(gl) {
	const program = createShaderProgram(gl, bgVertShaderSource, bgFragShaderSource);
	const positionBuffer = setupBuffer(gl, [-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]);
	const positionAttributeLocation = gl.getAttribLocation(program, 'position');
	const timeUniformLocation = gl.getUniformLocation(program, 'time');
	const aspectRatioUniformLocation = gl.getUniformLocation(program, 'aspectRatio');

	return {
		program,
		positionBuffer,
		positionAttributeLocation,
		timeUniformLocation,
		aspectRatioUniformLocation
	};
}

export function drawBackground(gl, bg, time, aspectRatio) {
	gl.useProgram(bg.program);
	gl.bindBuffer(gl.ARRAY_BUFFER, bg.positionBuffer);
	gl.vertexAttribPointer(bg.positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);
	gl.enableVertexAttribArray(bg.positionAttributeLocation);
	// uniforms
	gl.uniform1f(bg.timeUniformLocation, time);
	gl.uniform1f(bg.aspectRatioUniformLocation, aspectRatio);
	gl.drawArrays(gl.TRIANGLES, 0, 6);
}

export function cleanupBackground(gl, bg) {
	gl.deleteProgram(bg.program);
	gl.deleteBuffer(bg.positionBuffer);
}
