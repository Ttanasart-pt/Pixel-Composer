//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 position;
uniform float angle;
uniform float amount;

void main() {
	vec2 c = v_vTexcoord - position;
	float _x = .5 + c.x * cos(angle) - c.y * sin(angle);
	float _y = .5 + c.x * sin(angle) + c.y * cos(angle);
	float _a   = 1. / amount;
	
	if(mod(floor(_x / _a) + floor(_y / _a), 2.) > 0.5)
		gl_FragColor = vec4(vec3(0.), 1.);
	else
		gl_FragColor = vec4(vec3(1.), 1.);
}
