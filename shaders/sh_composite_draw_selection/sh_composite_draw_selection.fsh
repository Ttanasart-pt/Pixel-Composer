varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float selecting;

uniform float time;
uniform float scale;
uniform float size;

void main() {
	vec2 tx = 1. / dimension;
	vec2 px = v_vTexcoord * dimension;
	
	float sc = texture2D(gm_BaseTexture, v_vTexcoord).r;
	float st = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., tx.y)).r;
	float sb = texture2D(gm_BaseTexture, v_vTexcoord - vec2(0., tx.y)).r;
	float sl = texture2D(gm_BaseTexture, v_vTexcoord + vec2(tx.x, 0.)).r;
	float sr = texture2D(gm_BaseTexture, v_vTexcoord - vec2(tx.x, 0.)).r;
	
	gl_FragColor = vec4(0.);
	
	float i = 0.;
	float a = 0.;
	
	if(sc != selecting && (st == selecting || sb == selecting || sl == selecting || sr == selecting)) {
		i = 0.;
		a = 1.;
	}
	
	if(sc == selecting && (st != selecting || sb != selecting || sl != selecting || sr != selecting)) {
		i = 1.;
		a = 1.;
	}
	
	if(mod(px.x + px.y - time, size * 2.) < size)
		i = 1. - i;
	
	gl_FragColor = vec4(i,i,i,a);
}