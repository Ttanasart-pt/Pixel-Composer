//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D samH, samS, samV;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
    vec4 _h = texture2D( samH, v_vTexcoord );
    vec4 _s = texture2D( samS, v_vTexcoord );
    vec4 _v = texture2D( samV, v_vTexcoord );
	
	float h = (_h[0] + _h[1] + _h[2]) / 3.;
	float s = (_s[0] + _s[1] + _s[2]) / 3.;
	float v = (_v[0] + _v[1] + _v[2]) / 3.;
	
	gl_FragColor = vec4(hsv2rgb(vec3(h, s, v)), 1.);
}
