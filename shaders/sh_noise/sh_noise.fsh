//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float seed;

float random (in vec2 st, float seed) {
    return fract(sin(dot(st.xy + seed, vec2(1892.9898, 78.23453))) * 437.54123);
}

void main() {
	float n0 = random(v_vTexcoord, floor(seed) / 5000.);
	float n1 = random(v_vTexcoord, (floor(seed) + 1.) / 5000.);
	float n  = mix(n0, n1, fract(seed));
	gl_FragColor = vec4(vec3(n), 1.0);
}
