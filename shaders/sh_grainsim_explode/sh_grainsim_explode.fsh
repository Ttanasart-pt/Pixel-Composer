varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 center;
uniform vec2 size;

void main() {
	vec2 dx = v_vTexcoord * dimension - center;
	vec2 sz = size;
	
	float dx2 = dx.x * dx.x;
	float dy2 = dx.y * dx.y;
	
	float sx2 = sz.x * sz.x;
	float sy2 = sz.y * sz.y;
	
	float dis = sqrt(dx2 / sx2 + dy2 / sy2);
	      dis = 1. - clamp(dis, 0., 1.);
	
	gl_FragColor = vec4(normalize(dx) * .5 + .5, 0., dis);
}