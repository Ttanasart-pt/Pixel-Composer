varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int       bgUse;
uniform sampler2D bgSurface;
uniform sampler2D fgSurface;

uniform float bgAlpha;

void main() {
	vec4 bg    = bgUse == 1? texture2D(bgSurface, v_vTexcoord) : vec4(0.);
	     bg.a *= bgAlpha;
	
	vec4 fg = texture2D(fgSurface, v_vTexcoord);
	
	float al = fg.a + bg.a * (1. - fg.a);
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	
	gl_FragColor = res * v_vColour;
}