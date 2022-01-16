//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  position;
uniform vec2  scale;
uniform float width;

void main() {
	vec2 _pos = v_vTexcoord + position;
	
	vec2 dist = _pos - floor(_pos * scale) / scale;
	float ww = width / 2.;
	
	if(dist == clamp(dist, vec2(ww), vec2(1. / scale - ww)))
		gl_FragColor = vec4(1.);
	else
		gl_FragColor = vec4(vec3(0.), 1.);
}
