varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform int useMask;
uniform sampler2D mask;

vec2 tx;

vec4 sample(float x, float y, vec4 c4) {
	vec4 c = texture2D( gm_BaseTexture, v_vTexcoord + vec2(x, y) * tx ); 
	
	if(c.a > 0.) { 
		c4.rgb = min(c4.rgb, c.rgb);
		
		if(useMask == 1) {
			vec4 m = texture2D( mask, v_vTexcoord + vec2(x, y) * tx ); 
			if(m.r == 0.) c4.b = 0.;
		}
	}
	
	return c4;
}

void main() {
	tx = 1. / dimension;
	gl_FragColor = vec4(0.);
	
	vec4 c4 = texture2D( gm_BaseTexture, v_vTexcoord );
	if(c4.a == 0.) return;
	
	if(useMask == 1) {
		vec4 m = texture2D( mask, v_vTexcoord ); 
		if(m.r == 0.) c4.b = 0.;
	}
		
	c4 = sample(-1., -1., c4);
	c4 = sample(-1.,  0., c4);
	c4 = sample(-1.,  1., c4);
	
	c4 = sample( 0., -1., c4);
	c4 = sample( 0.,  1., c4);
	
	c4 = sample( 1., -1., c4);
	c4 = sample( 1.,  0., c4);
	c4 = sample( 1.,  1., c4);
	
	gl_FragColor = c4;
	
}
