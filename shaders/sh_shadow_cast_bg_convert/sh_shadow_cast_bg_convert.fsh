varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor = vec4(0.);
	
	if(length(base.rgb * base.a) >= .5)
		gl_FragColor = vec4(1.);
}