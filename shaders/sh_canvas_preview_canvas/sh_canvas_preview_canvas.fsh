varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int       eraser;
uniform sampler2D outputSurf;
uniform sampler2D background;
uniform sampler2D canvas;

void main() {
	vec4 og = texture2D(outputSurf, v_vTexcoord);
	vec4 bg = texture2D(background, v_vTexcoord);
	vec4 fg = texture2D(canvas,     v_vTexcoord);
	vec4 res;
	
	if(eraser == 1) {
		res = mix(og, bg, fg.a);
		
	} else {
		float al = fg.a + og.a * (1. - fg.a);
		res = ((fg * fg.a) + (og * og.a * (1. - fg.a))) / al;
	}
	
	gl_FragColor = res;
}