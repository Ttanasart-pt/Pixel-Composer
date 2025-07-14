varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float maxDistance;
uniform int   pointAmount;
uniform int   inverted;

uniform vec2 points[1024];

void main() {
	vec2 px = v_vTexcoord * dimension;
	float minDist = 9999.;
	float matchCount = 0.;
	
	for(int i = 0; i < pointAmount; i++) {
		vec2  p    = points[i];
		float dist = distance(px, p);
		minDist    = min(minDist, dist);
		
		if(dist < maxDistance) matchCount++;
	}
	
	float distC = minDist / maxDistance;
	if(inverted == 1) distC = 1. - distC;
	
	gl_FragColor = vec4(vec3(distC), 1.);
}