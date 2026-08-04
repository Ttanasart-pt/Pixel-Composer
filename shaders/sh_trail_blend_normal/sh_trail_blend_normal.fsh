varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D bg;
uniform sampler2D fg;

vec4 blend(vec4 bg, vec4 fg) {
	if(bg.a == 0.) return fg;
	
	float al = fg.a + bg.a * (1. - fg.a);
	if(al == 0.) return vec4(0.);
	
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	res.a = al;
	
	return res;
}

void main() {
	vec4 sbg = texture2D(bg, v_vTexcoord);
	vec4 sfg = texture2D(fg, v_vTexcoord);
	gl_FragColor = blend(sbg, sfg);
}