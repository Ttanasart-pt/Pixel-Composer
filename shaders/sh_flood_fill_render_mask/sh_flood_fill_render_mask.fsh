varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int  invert;

void main() {
	vec4 res = texture2D(gm_BaseTexture, v_vTexcoord);
	float rr = res.r;
	
	if(invert == 1) rr = 1. - rr;
	
	gl_FragColor = vec4(rr, rr, rr, 1.);
}