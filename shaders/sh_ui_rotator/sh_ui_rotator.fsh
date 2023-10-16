//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4  c0, c1;
uniform float angle;
uniform vec2  mouse;
uniform float mouseProg;

#define TAU 6.28318530718

float angleDiff(float angle1, float angle2) {
    float dif = mod(angle1 - angle2, TAU);
    return min(dif, TAU - dif);
}

void main() {
	float dist = distance(v_vTexcoord, vec2( 0.5, 0.5 )) * 2.;
	float ang  = atan(-(v_vTexcoord.y - 0.5), v_vTexcoord.x - 0.5);
	float muse = max(0., 0.5 - distance(v_vTexcoord, mouse));
	
	float dif = angleDiff(ang, angle) / TAU;
	float d0  = smoothstep(0.925, 1.00, 1. - dif);
	float d1  = clamp(1. - smoothstep(0.85 + mouseProg * 0.05, 1.00, 1. - dif) * 2., 0., 0.75);
	float rad = 0.935 - d0 * (mouseProg * 0.1 + 0.05);
	
	float ring = dist - muse * 0.2;
	ring = 1. - abs(ring - 0.7);
	ring = smoothstep(rad, 1.0, ring) * 25.;
	
    gl_FragColor = vec4(mix(c0.rgb, c1.rgb, d1), ring);
}
