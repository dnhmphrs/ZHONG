import { createShaderProgram, setupBuffer } from './UtilFunctions';
import vertexShader from '../shaders/vertex.glsl';
import fragmentShader from '../shaders/main.glsl';

export function setupBackground(gl) {
    const program = createShaderProgram(gl, vertexShader, fragmentShader);
    const positionBuffer = setupBuffer(gl, [-1, -1, 1, -1, -1, 1, -1, 1, 1, -1, 1, 1]);
    const positionAttributeLocation = gl.getAttribLocation(program, 'position');
    const timeUniformLocation = gl.getUniformLocation(program, 'time');
    const aspectRatioUniformLocation = gl.getUniformLocation(program, 'aspectRatio');
    const isDarkModeUniformLocation = gl.getUniformLocation(program, 'isDarkMode');

    return {
        program,
        positionBuffer,
        positionAttributeLocation,
        timeUniformLocation,
        aspectRatioUniformLocation,
        isDarkModeUniformLocation
    };
}

export function drawBackground(gl, bg, time, aspectRatio, isDarkMode) {
    gl.useProgram(bg.program);
    gl.bindBuffer(gl.ARRAY_BUFFER, bg.positionBuffer);
    gl.vertexAttribPointer(bg.positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);
    gl.enableVertexAttribArray(bg.positionAttributeLocation);
    // uniforms
    gl.uniform1f(bg.timeUniformLocation, time);
    gl.uniform1f(bg.aspectRatioUniformLocation, aspectRatio);
    gl.uniform1i(bg.isDarkModeUniformLocation, isDarkMode ? 1 : 0);
    gl.drawArrays(gl.TRIANGLES, 0, 6);
}

export function cleanupBackground(gl, bg) {
    gl.deleteProgram(bg.program);
    gl.deleteBuffer(bg.positionBuffer);
} 