varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

uniform int       bgUse;
uniform int       bgType;
uniform vec4      bgColor;
uniform sampler2D bgSurface;

uniform sampler2D canvas;

void main() {
	vec4 bg = vec4(0.);
	vec4 fg = texture2D(canvas, v_vTexcoord);
	
	if(bgUse == 1) {
		     if(bgType == 0) bg = texture2D(bgSurface, v_vTexcoord);
		else if(bgType == 1) bg = bgColor;
	}
	
	float al = fg.a + bg.a * (1. - fg.a);
	vec4 res = ((fg * fg.a) + (bg * bg.a * (1. - fg.a))) / al;
	
	gl_FragColor = res;
}