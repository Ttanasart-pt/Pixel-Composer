//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float angle;
uniform float amount;
uniform int   blend;

void main() {
	float prog = .5 + (v_vTexcoord.x - .5) * cos(angle) - (v_vTexcoord.y - .5) * sin(angle);
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
