varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	float msk = (base.r + base.g + base.b) / 3. * base.a;
	
	gl_FragColor = v_vColour * (msk > 0.? 1. : 0.);
}