varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D prevHash;
uniform sampler2D currHash;

uniform vec2  dimension;
uniform float radius;
uniform float threshold;

uniform int   cformat;
uniform float intensity;

void main() {
	vec2 tx = 1. / dimension;
	
	float next = texture2D(prevHash, v_vTexcoord).r;
	float base = texture2D(currHash, v_vTexcoord).r;
	
	vec2  match = vec2(0.,0.);
	float mind  = threshold;
	float mdst  = 1.;
	
	for(float i = -radius; i <= radius; i++)
	for(float j = -radius; j <= radius; j++) {
		float dist = 1. - length(vec2(i,j)) / radius;
		float prv  = texture2D(prevHash, clamp(v_vTexcoord - vec2(i,j) * tx, 0., 1.)).r;
		float delt = abs(base - prv);
		
		if(delt < mind || (delt <= mind && dist < mdst)) {
			match = vec2(-i,j) * tx;
			mind  = delt;
			mdst  = dist;
		}
	}
	
	match *= intensity;
	if(cformat == 0) match = 0.5 + match;
	
	if(next == base) // When putting this as early terminate the compiler complain about loop for some reason.
		gl_FragColor = vec4(cformat == 0? vec2(.5) : vec2(0.), 0., 1.);
	else 
		gl_FragColor = vec4(match, 0., 1.);
}