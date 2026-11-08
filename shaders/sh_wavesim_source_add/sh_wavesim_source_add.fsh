varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D domain;

uniform int shape;
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
	float ds = 0.;
	
	if(shape == 0) {
		float rad  = radius / dimension.x;
		float dist = clamp(1. - distance(v_vTexcoord, pos) / rad, 0., 1.);
		ds = dist;
		
	} else if(shape == 1) {
		vec4 msk = texture2D(mask, vec + .5);
		ds = (msk.r + msk.g + msk.b) / 3. * msk.a;
		
	}
	
	dom.x  += intensity * ds;
	gl_FragColor = dom;
}