varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 res = texture2D(gm_BaseTexture, v_vTexcoord);
	float aa = res.a > 0.? 1. : 0.;
	gl_FragColor = vec4(aa, aa, aa, 1.);
}