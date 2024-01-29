varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = vec4(0.);
	
	if((c.r + c.g + c.b) * c.a / 3. > 0.)
		gl_FragColor = vec4(1.);
}
