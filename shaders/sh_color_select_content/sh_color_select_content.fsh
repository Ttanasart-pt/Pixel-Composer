//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int mode;
uniform float hue;
uniform float val;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    if(mode == 0)  
		gl_FragColor = vec4(hsv2rgb(vec3(hue, v_vTexcoord.x, 1. - v_vTexcoord.y)), 1.);
	else if(mode == 1)  
		gl_FragColor = vec4(hsv2rgb(vec3(v_vTexcoord.x, 1. - v_vTexcoord.y, val)), 1.);
}
