varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec2 tx = 1. / dimension;
	
	float sc = texture2D(gm_BaseTexture, v_vTexcoord).a;
	float st = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., tx.y)).a;
	float sb = texture2D(gm_BaseTexture, v_vTexcoord - vec2(0., tx.y)).a;
	float sl = texture2D(gm_BaseTexture, v_vTexcoord + vec2(tx.x, 0.)).a;
	float sr = texture2D(gm_BaseTexture, v_vTexcoord - vec2(tx.x, 0.)).a;
	
	gl_FragColor = vec4(0.);
	
	if(sc != 0. && (st == 0. || sb == 0. || sl == 0. || sr == 0.))
		gl_FragColor = vec4(0., 0., 0., 1.);
	
	if(sc == 0. && (st != 0. || sb != 0. || sl != 0. || sr != 0.))
		gl_FragColor = vec4(1., 1., 1., 1.);
}