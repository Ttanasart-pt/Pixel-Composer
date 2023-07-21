//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float btop;
uniform float bbot;

void main() {
	vec2 pos = v_vTexcoord.x > 0.5? vec2(v_vTexcoord.x - 0.5, v_vTexcoord.y) : vec2(0.5 - v_vTexcoord.x, v_vTexcoord.y);
	
	float _t = (1. - pos.y);
	float _x = 3. * (btop * _t * (1. - _t) * (1. - _t) + bbot * _t * _t * (1. - _t));
	
    gl_FragColor = pos.x < _x? v_vColour : vec4(0.);
}
