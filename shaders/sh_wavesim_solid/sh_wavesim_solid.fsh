varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D domain;

uniform int type;
uniform int shape;
uniform sampler2D mask;

uniform vec2  dimension;
uniform vec2  position;
uniform float radius;

void main() {
	vec4 dom = v_vColour * texture2D(domain, v_vTexcoord);
	
	vec2 pos = position / dimension;
	vec2 vec = v_vTexcoord - pos;
	bool isSolid = false;
	
	if(shape == 0) {
		float rad  = radius / dimension.x;
		float dist = 1. - distance(v_vTexcoord, pos) / rad;
		if(dist > 0.) isSolid = true;
		
	} else if(shape == 1) {
		vec4 msk = texture2D(mask, vec + .5);
		float ds = (msk.r + msk.g + msk.b) / 3. * msk.a;
		if(ds > 0.) isSolid = true;
		
	}
	
	if(isSolid) {
		     if(type == 0)   dom.z = 1.;
		else if(type == 1) { dom.x = 0.; dom.y = 0.; }
	}
	
	gl_FragColor = dom;
}