varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform vec4 highlight;

bool sample(vec2 px) {
	if(px.x < 0. || px.y < 0. || px.x > 1. || px.y > 1.) return true;
	return texture2D(gm_BaseTexture, px).a == 0.;
}

void main() {
	vec2 tx = 1. / dimension;
	vec4 cc = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = cc;
	if(cc.a == 0.) return;
	
	bool hh0 = sample(v_vTexcoord + vec2( tx.x, 0.));
	bool hh1 = sample(v_vTexcoord + vec2(0., -tx.y));
	bool hh2 = sample(v_vTexcoord + vec2(-tx.x, 0.));
	bool hh3 = sample(v_vTexcoord + vec2(0.,  tx.y));
	
	if(highlight[0] != 0. && hh0) cc.rgb *= 1. + highlight[0];
	if(highlight[1] != 0. && hh1) cc.rgb *= 1. + highlight[1];
	if(highlight[2] != 0. && hh2) cc.rgb *= 1. + highlight[2];
	if(highlight[3] != 0. && hh3) cc.rgb *= 1. + highlight[3];
	
	gl_FragColor = cc;
}