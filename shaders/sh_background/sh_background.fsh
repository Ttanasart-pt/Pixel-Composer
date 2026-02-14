varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 color;

void main() {
	vec4 bg = color;
	vec4 fg = texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec4 res  = bg * (1. - fg.a) + fg * fg.a;
	res.a = 1.;
	     
	gl_FragColor = res;
}