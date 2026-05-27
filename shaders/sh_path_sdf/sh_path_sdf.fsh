varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   subdivision;
uniform float maxDistance;
uniform int   inverted;

uniform vec2 points[1024];

uniform vec2  position;
uniform vec2  anchor;
uniform float rotation;
uniform vec2  scale;

vec2 pointToLine(in vec2 p, in vec2 l0, in vec2 l1) {
	float l2 = pow(l0.x - l1.x, 2.) + pow(l0.y - l1.y, 2.);
	if (l2 == 0.) return l0;
	  
	float t = ((p.x - l0.x) * (l1.x - l0.x) + (p.y - l0.y) * (l1.y - l0.y)) / l2;
	t = clamp(t, 0., 1.);
	
	return mix(l0, l1, t);
}

void main() {
	vec2 px  = v_vTexcoord * dimension;
	vec2 anc = anchor * dimension;
	
	float minDist = 9999.;
	vec2 ox, nx;
	vec2 p;
	
	float ang = radians(rotation);
	mat2  rot = mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	
	for(int i = 0; i < subdivision; i++) {
		nx = points[i];
		
		nx -= anc;
		nx  = (nx * rot) * scale + position;
		nx += anc;
		
		if(i > 0) {
			p  = pointToLine(px, ox, nx);
			
			float dist = distance(px, p);
			minDist = min(minDist, dist);
		}
		
		ox = nx;
	}
	
	float distC = minDist / maxDistance;
	if(inverted == 1) distC = 1. - distC;
	
	gl_FragColor = vec4(vec3(distC), 1.);
}