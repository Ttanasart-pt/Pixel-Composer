// lol never use this
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define RADIUS 4.

uniform sampler2D prevSurf;

uniform vec2  dimension;
uniform float radius;
uniform float threshold;

uniform int   cformat;
uniform float intensity;

vec2  tx = 1. / dimension;
float currentFrame[1024];

float compare(vec2 offs) {
	float delt = 0.;
	
	for(float i = -RADIUS; i <= RADIUS; i++)
	for(float j = -RADIUS; j <= RADIUS; j++) {
		float samp = texture2D(prevSurf, clamp(offs - vec2(i,j) * tx, 0., 1.)).r;
		delt += abs(samp);
	}
	
	return delt / (RADIUS * RADIUS + 1.);
}

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
	
	int ind = 0;
	for(float i = -RADIUS; i <= RADIUS; i++)
	for(float j = -RADIUS; j <= RADIUS; j++) {
		currentFrame[ind++] = texture2D(gm_BaseTexture, clamp(v_vTexcoord - vec2(i,j) * tx, 0., 1.)).r;
	}
	
	vec2  match  = vec2(0.,0.);
	float minDif = threshold;
	float minDst = 1.;
	
	for(float i = -RADIUS; i <= RADIUS; i++)
	for(float j = -RADIUS; j <= RADIUS; j++) {
		float dst = length(vec2(i,j)) / RADIUS;
		float cmp = compare( v_vTexcoord + vec2(i,j) * tx );
		
		if(cmp < minDif || (cmp <= minDif && dst < minDst)) {
			minDif = cmp;
			minDst = dst;
			match  = -vec2(i,j) * tx;
		}
	}
	
	match *= intensity;
	if(cformat == 0) match = 0.5 + match;
	gl_FragColor = vec4(match, 0., 1.);
}