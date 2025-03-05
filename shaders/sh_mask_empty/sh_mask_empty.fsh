varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D mask;

void main() {
	vec4 cc  = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 msk = texture2D(mask, v_vTexcoord);
	
	float alp = (msk.r + msk.g + msk.b) / 3. * msk.a;
	gl_FragColor = vec4(cc.rgb, cc.a * alp);
}