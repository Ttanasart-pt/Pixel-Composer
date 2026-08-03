varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int       selecting;
uniform sampler2D selectMask;

uniform sampler2D origSurf;
uniform int       blending;

vec4 blend(vec4 bg, vec4 fg) {
	if(bg.a == 0.) return fg;
	
	float al = fg.a + bg.a * (1. - fg.a);
	if(al == 0.) return vec4(0.);
	
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	res.a = al;
	
	return res;
}

void main() {
	vec4 edit = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 orig = texture2D(origSurf, v_vTexcoord);
	
	vec4 res  = edit;
	
	if(blending == 0) res = blend(orig, edit);
	if(blending == 1) res = edit;
	if(blending == 2) res = orig * edit;
	if(blending == 3) res = orig + edit;
	
	gl_FragColor = res;
}