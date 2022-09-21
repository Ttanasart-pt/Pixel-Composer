//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 position;
uniform float angle;
uniform float amount;

uniform vec4 col1, col2;

void main() {
	vec2 dimension_norm = dimension / dimension.y;
	vec2 c = (v_vTexcoord - position) * dimension_norm;
	float _x = c.x * cos(angle) - c.y * sin(angle);
	float _y = c.x * sin(angle) + c.y * cos(angle);
	float _a   = 1. / amount;
	
	if(mod(floor(_x / _a) + floor(_y / _a), 2.) > 0.5)
		gl_FragColor = vec4(col1.rgb, 1.);
	else
		gl_FragColor = vec4(col2.rgb, 1.);
}
