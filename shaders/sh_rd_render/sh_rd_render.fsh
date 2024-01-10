varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4  col = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(col.r + col.g == 0.) {
		gl_FragColor = vec4(0., 0., 0., 1.);
	} else {
		float whi = (col.g) / (col.r + col.g);
	    gl_FragColor = vec4(whi, whi, whi, 1.);
	}
}
