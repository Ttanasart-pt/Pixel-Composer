varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D domain;
uniform sampler2D mask;

uniform vec2  dimension;
uniform vec2  position;

uniform float radius;
uniform float intensity;
uniform float velocity;

void main() {
	vec4 dom = v_vColour * texture2D(domain, v_vTexcoord);
	
	vec2 pos = position / dimension;
	vec2 vec = v_vTexcoord - pos;
	
	float rad  = radius / dimension.x;
	float dist = clamp(1. - distance(v_vTexcoord, pos) / rad, 0., 1.);
	float ds   = dist;
	
	dom.x  += intensity * ds;
	
	gl_FragColor = dom;
}