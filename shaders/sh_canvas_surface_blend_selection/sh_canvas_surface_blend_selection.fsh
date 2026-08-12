varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int       selecting;
uniform sampler2D selectSurf;

vec4 blend(vec4 bg, vec4 fg) {
	if(bg.a == 0.) return fg;
	
	float al = fg.a + bg.a * (1. - fg.a);
	if(al == 0.) return vec4(0.);
	
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	res.a = al;
	
	return res;
}

void main() {
	vec4 bgC = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 res = bgC;
	
	if(selecting == 1) {
		vec4 slC = texture2D(selectSurf, v_vTexcoord);
		res = blend(res, slC);
	}
	
	gl_FragColor = res * v_vColour;
}