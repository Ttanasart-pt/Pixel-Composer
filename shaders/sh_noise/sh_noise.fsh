//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float seed;

float random (in vec2 st) {
    return fract(sin(dot(st.xy, vec2(1892.9898, 78.23453))) * 437.54123);
}

void main() {
	float n = random(v_vTexcoord + seed / 5000.);
	gl_FragColor = vec4(vec3(n), 1.0);
}
