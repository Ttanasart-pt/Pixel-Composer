varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 mask = texture2D( gm_BaseTexture, v_vTexcoord );
	float msk = (mask.r + mask.g + mask.b) / 3. * mask.a;
	
	gl_FragColor = vec4(v_vColour.rgb, msk * v_vColour.a);
}
