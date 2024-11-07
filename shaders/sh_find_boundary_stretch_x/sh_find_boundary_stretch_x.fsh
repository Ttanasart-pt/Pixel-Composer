varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 background;

void main() {
	bool emp = background.a == 0.;
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	if((emp && col.a > 0.) || (!emp && col != background)) { gl_FragColor = vec4(1.); return; }
	
	gl_FragColor = vec4(0.);
	vec2 tx = 1. / dimension;
	
	for(float i = 0.; i < dimension.y; i++) {
		vec4 col = texture2D( gm_BaseTexture, vec2(v_vTexcoord.x, tx.y * i) );
		if((emp && col.a > 0.) || (!emp && col != background)) {
			gl_FragColor = vec4(1.);
			break;
		}
	}
}
