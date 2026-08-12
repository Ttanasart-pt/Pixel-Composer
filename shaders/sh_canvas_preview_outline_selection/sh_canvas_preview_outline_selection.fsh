varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

uniform float time;
uniform float scale;
uniform float size;

void main() {
	gl_FragColor = vec4(0.);
	
	vec2 tx = 1. / dimension;
	vec2 px = v_vTexcoord * dimension;
	
	float sc = texture2D(gm_BaseTexture, v_vTexcoord).a;
	float st = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., tx.y)).a;
	float sb = texture2D(gm_BaseTexture, v_vTexcoord - vec2(0., tx.y)).a;
	float sl = texture2D(gm_BaseTexture, v_vTexcoord + vec2(tx.x, 0.)).a;
	float sr = texture2D(gm_BaseTexture, v_vTexcoord - vec2(tx.x, 0.)).a;
	
	float i = 0.;
	float a = 0.;
	
	if(sc != 0. && (st == 0. || sb == 0. || sl == 0. || sr == 0.)) {
		i = 0.;
		a = 1.;
	}
	
	if(sc == 0. && (st != 0. || sb != 0. || sl != 0. || sr != 0.)) {
		i = 1.;
		a = 1.;
	}
		
	if(mod(px.x + px.y - time, size * 2.) < size)
		i = 1. - i;
	
	gl_FragColor = vec4(i,i,i,a) * v_vColour;
}