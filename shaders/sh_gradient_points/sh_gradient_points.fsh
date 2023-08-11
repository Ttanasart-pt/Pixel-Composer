//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform vec2 dimension;
uniform vec2 center[4];
uniform vec3 color[4];
uniform vec4 strength;

void main() {
	vec4 distances = vec4(0.);
	float maxDist = 0.;
	int i;
	
	for( i = 0; i < 4; i++ ) {
		float d = distance(v_vTexcoord, center[i] / dimension);
		distances[i] = d;
		maxDist = max(maxDist, d);
	}
	
	maxDist *= 2.;
	
	for( i = 0; i < 4; i++ )
		distances[i] = pow((maxDist - distances[i]) / maxDist, strength[i]);
	
	vec4 weights = distances / (distances[0] + distances[1] + distances[2] + distances[3]);
	vec3 clr = (color[0] * weights[0]) + (color[1] * weights[1]) + (color[2] * weights[2]) + (color[3] * weights[3]);
	
	gl_FragColor = vec4(clr, 1.);
}
