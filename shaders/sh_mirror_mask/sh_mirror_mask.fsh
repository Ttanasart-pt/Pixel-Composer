varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586
#define pi1 3.14159
#define pi2 1.57079

uniform vec2  dimension;
uniform vec2  position;
uniform float angle;

void main() {
	vec2 pos       = v_vTexcoord;
	vec2 pixel_pos = v_vTexcoord * dimension;
	float _angle;
	
	_angle = atan((pixel_pos.y - position.y), (pixel_pos.x - position.x)) + angle;
	_angle = TAU - (_angle - floor(_angle / TAU) * TAU); 
	
	gl_FragColor = (_angle < pi1)? vec4(vec3(1.), 1.) : vec4(vec3(0.), 1.);
}
