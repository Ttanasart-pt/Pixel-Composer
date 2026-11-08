varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float lv_min;
uniform float lv_rng;

void main() {
	vec4 base = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	float r = lv_min + base.r * lv_rng;
	gl_FragColor = vec4(r,r,r,1.);
}