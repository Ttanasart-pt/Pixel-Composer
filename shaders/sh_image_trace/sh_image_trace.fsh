varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
vec2 tx;

bool sample(float x, float y) {
	vec2 pos = v_vTexcoord + vec2(tx.x * x, tx.y * y);
	if(pos.x < 0. || pos.y < 0. || pos.x > 1. || pos.y > 1.) return true;
	
	vec4 c = texture2D( gm_BaseTexture, pos );
	return (c.r + c.g + c.b) * c.a == 0.;
}

void main() {
	tx = 1. / dimension;
	vec4 cc = texture2D( gm_BaseTexture, v_vTexcoord );
	
    gl_FragColor = vec4(0.);
	if(cc.a == 0.) return;
	
	bool s1 = sample(-1., 0.);
	bool s2 = sample( 1., 0.);
	bool s3 = sample(0., -1.);
	bool s4 = sample(0.,  1.);
	
	if(s1 && s2) return;
	if(s3 && s4) return;
	
	if(s1) { gl_FragColor = vec4(1.); return; }
	if(s2) { gl_FragColor = vec4(1.); return; }
	if(s3) { gl_FragColor = vec4(1.); return; }
	if(s4) { gl_FragColor = vec4(1.); return; }
}
