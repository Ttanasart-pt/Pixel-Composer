varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

vec2 tx;

bool sample(float x, float y) {
	vec2 pos = v_vTexcoord + vec2(tx.x * x, tx.y * y);
	if(pos.x < 0. || pos.y < 0. || pos.x > 1. || pos.y > 1.) return false;
	
	vec4 c = texture2D( gm_BaseTexture, pos );
	return (c.r + c.g + c.b) * c.a > 0.;
}

void main() {
	tx = 1. / dimension;
	vec4 cc = texture2D( gm_BaseTexture, v_vTexcoord );
	
    gl_FragColor = vec4(0.);
	if(cc.r == 0.) return;
	
	if(!sample(-1., 0.)) { gl_FragColor = vec4(1.); return; }
	if(!sample( 1., 0.)) { gl_FragColor = vec4(1.); return; }
	if(!sample(0., -1.)) { gl_FragColor = vec4(1.); return; }
	if(!sample(0.,  1.)) { gl_FragColor = vec4(1.); return; }
}
