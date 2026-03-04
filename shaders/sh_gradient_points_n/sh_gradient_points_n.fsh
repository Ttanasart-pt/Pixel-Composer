varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   mode; // 0: exponential; 1: Gaussian; 2: linear

uniform int   pointAmount;
uniform vec2  points[64];
uniform vec4  colors[64];
uniform float ranges[64];

void main() {
	vec4 res = vec4(0., 0., 0., 1.);
	if(pointAmount == 0) { gl_FragColor = res; return; }
	
	if(mode == 0) {
		float distances[64];
	
		float maxDist = 0.;
		for(int i = 0; i < pointAmount; i++) {
			float dist = distance(points[i], v_vTexcoord);
			distances[i] = dist;
			maxDist = max(maxDist, dist);
		}
	
		maxDist *= 2.;
		float distSqr = 0.;
		for(int i = 0; i < pointAmount; i++) {
			float dist = distances[i];
			dist = pow((maxDist - dist) / maxDist, ranges[i]);
			distSqr += dist * dist;
			distances[i] = dist;
		}
		distSqr = sqrt(distSqr);
	
		for(int i = 0; i < pointAmount; i++) {
			float dist   = distances[i];
			float weight = dist / distSqr;
			res += colors[i] * weight;
		}

	} else if(mode == 1) {
		float totalD = 0.;
		float weights[64];

		for(int i = 0; i < pointAmount; i++) {
			float dist   = distance(points[i], v_vTexcoord);
			float range  = ranges[i] / dimension.x;
			float weight = exp(-pow(dist / range, 2.));
			weights[i] = weight;
			totalD += weight;
		}

		for(int i = 0; i < pointAmount; i++) {
			float weight = weights[i] / totalD;
			res += colors[i] * weight;
		}
		
	} else if(mode == 2) {
		for(int i = 0; i < pointAmount; i++) {
			float dist   = distance(points[i], v_vTexcoord);
			float range  = ranges[i] / dimension.x;
			float weight = max(0., (range - dist) / range);
			res += colors[i] * weight;
		}
	}
	
	gl_FragColor = res;
}