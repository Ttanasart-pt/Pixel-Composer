varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 samp = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = vec4(v_vColour.rgb, v_vColour.a * samp.r);
}