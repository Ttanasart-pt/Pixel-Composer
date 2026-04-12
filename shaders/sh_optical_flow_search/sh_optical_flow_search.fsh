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
	
	vec4 orig = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 base = texture2D(currHash, v_vTexcoord);
	
	vec2  match = vec2(0.,0.);
	float mind  = threshold;
	
	for(float i = -radius; i <= radius; i++)
	for(float j = -radius; j <= radius; j++) {
		vec4  prv  = texture2D(prevHash, clamp(v_vTexcoord - vec2(i,j) * tx, 0., 1.));
		float dist = distance(base, prv);
		
		if(dist < mind) {
			match = vec2(i,j) * tx;
			mind  = dist;
		}
	}
	
	match *= intensity;
	if(cformat == 0) match = 0.5 + match;
	
	// if(orig.a == 0.) gl_FragColor = vec4(0., 0., 0., 1.);
	// else 
	gl_FragColor = vec4(match, 0., 1.);
}