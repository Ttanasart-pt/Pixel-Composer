//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359

uniform float strength;

void main() {
	float inCircle = length(v_vTexcoord - vec2(0.5));
	
	if(inCircle > 0.5) {
		gl_FragColor = vec4(128. / 255., 128. / 255., 0., 0.);
		return;
	}
	
	vec2 pos = vec2(0.5) - v_vTexcoord;
	float rad = inCircle * 2.;
	float angle = atan(pos.y, pos.x);
	float dist  = (1. - rad) * strength;
	
	gl_FragColor = vec4(128. / 255. + cos(angle) * 0.125 * dist, 128. / 255. + sin(angle) * 0.125 * dist, 0., 1.);
}
