varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   inverted;
uniform int   radius;
uniform float sigma;

void main() {
	vec2  tx = 1. / dimension;
	float sg = 2.0 * sigma * sigma;
	float ss = 0.;
	float ww = 0.;
	
	for(int i = -radius; i <= radius; i++)
	for(int j = -radius; j <= radius; j++) {
		vec2  offset = vec2(float(i), float(j)) * tx;
		float weight = exp(-(float(i*i + j*j)) / sg);
		vec2  tx = fract(fract(v_vTexcoord + offset) + 1.);
		
		ss += texture2D(gm_BaseTexture, tx).r * weight;
		ww += weight;
	}
	
	ss /= ww;
	
	float cc = texture2D(gm_BaseTexture, v_vTexcoord).r;
	if(inverted == 0) gl_FragColor = vec4(cc == 1.? 1. : ss, cc == 1.? ss : 0., 0., 1.);
	else              gl_FragColor = vec4(cc == 0.? ss : 1., 0., 0., 1.);
}