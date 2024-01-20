varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec2 vc = normalize(v_vTexcoord - 0.5);
	vec4 c  = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	gl_FragColor = vec4(vc.xy * c.a, 0., 1.);
}
