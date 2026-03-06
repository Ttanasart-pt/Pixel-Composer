varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D shadowTex;
uniform int   type;
uniform float strength;

void main() {
	vec4 shad = texture2D(shadowTex, v_vTexcoord);
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 res;
	
	if(type == 0) {
		shad *= strength;
     	res   = shad * (1. - base.a) + base * base.a;
     	
	} else if(type == 1) {
		shad.a = (1. - shad.a) * strength;
		res    = base * (1. - shad.a) + shad * shad.a;
		res.a  = base.a;
	}
	
	gl_FragColor = res;
}