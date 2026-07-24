varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D surfaceBG;
uniform sampler2D surfaceFG;

vec4 blend(vec4 bg, vec4 fg) {
	float al = fg.a + bg.a * (1. - fg.a);
	if(al == 0.) return vec4(0.);
	
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	res.a = al;
	
	return res;
}

void main() {
	vec4 bg = texture2D(surfaceBG, v_vTexcoord);
	vec4 fg = texture2D(surfaceFG, v_vTexcoord);
	
	gl_FragColor = blend(bg, fg);
}