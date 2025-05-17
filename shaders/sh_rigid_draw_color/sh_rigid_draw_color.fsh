varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 c = texture2D(gm_BaseTexture, v_vTexcoord);
	
	gl_FragColor = vec4(v_vColour.rgb * c.a, c.a);
}