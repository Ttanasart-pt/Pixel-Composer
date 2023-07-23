//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 inset;

void main() {
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	if(gl_FragColor.a == 0.) return;
	
	vec2 tx = 1. / dimension;
	
	for(int i = 0; i < 4; i++)
	for(float j = 1.; j <= inset[i]; j++) {
		vec2 pos;
		
			 if(i == 0) pos = v_vTexcoord + vec2( tx.x * j, 0. );
		else if(i == 1) pos = v_vTexcoord - vec2( 0., tx.y * j );
		else if(i == 2) pos = v_vTexcoord - vec2( tx.x * j, 0. );
		else if(i == 3) pos = v_vTexcoord + vec2( 0., tx.y * j );
		
		vec4 px = texture2D( gm_BaseTexture, pos );
		if(px.a == 0.) {
			gl_FragColor = vec4(0.);
			return;
		}
	}
}
