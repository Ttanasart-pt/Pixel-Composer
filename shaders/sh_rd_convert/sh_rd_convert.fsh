varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4  col = texture2D( gm_BaseTexture, v_vTexcoord );
	gl_FragColor = col;
	
	//float whi = (col.r + col.g + col.b) / 3. * col.a;
    //gl_FragColor = vec4(1., whi, 0., 1.);
}
