varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 res = texture2D(gm_BaseTexture, v_vTexcoord);
	
	gl_FragColor = vec4(res.r, res.r, res.r, 1.);
}