//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	if(col.a > 0.) { gl_FragColor = vec4(1.); return; }
	
	gl_FragColor = vec4(0.);
	vec2 tx = 1. / dimension;
	
	for(float i = 0.; i < dimension.x; i++) {
		vec4 col = texture2D( gm_BaseTexture, vec2(tx.x * i, v_vTexcoord.y) );
		if(col.a > 0.) {
			gl_FragColor = vec4(1.);
			break;
		}
	}
}
