varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   pointAmount;
uniform int   inverted;

uniform vec2      maxDistance;
uniform int       maxDistanceUseSurf;
uniform sampler2D maxDistanceSurf;

uniform vec2 points[1024];

void main() {
	float dst = maxDistance.x;
	if(maxDistanceUseSurf == 1) {
		vec4 _vMap = texture2D( maxDistanceSurf, v_vTexcoord );
		dst = mix(maxDistance.x, maxDistance.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2 px = v_vTexcoord * dimension;
	float minDist = 9999.;
	float matchCount = 0.;
	
	for(int i = 0; i < pointAmount; i++) {
		vec2  p    = points[i];
		float dist = distance(px, p);
		minDist    = min(minDist, dist);
		
		if(dist < dst) matchCount++;
	}
	
	float distC = minDist / dst;
	if(inverted == 1) distC = 1. - distC;
	
	gl_FragColor = vec4(vec3(distC), 1.);
}