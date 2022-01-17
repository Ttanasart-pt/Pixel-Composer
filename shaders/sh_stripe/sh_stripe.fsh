//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 position;
uniform float angle;
uniform float amount;
uniform int   blend;

void main() {
	vec2 pos = v_vTexcoord - position;
	float prog = pos.x * cos(angle) - pos.y * sin(angle);
    float _a   = 1. / amount;
	
	float _s   = mod(prog, _a);
	if(blend == 0) {
		if(_s > _a / 2.)
			gl_FragColor = vec4(vec3(0.), 1.);
		else
			gl_FragColor = vec4(vec3(1.), 1.);
	} else {
		gl_FragColor = vec4(vec3(abs(_s / _a - 0.5) * 2.), 1.);
	}
}
