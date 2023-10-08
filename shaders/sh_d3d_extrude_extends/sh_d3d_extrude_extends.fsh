//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 clr  = texture2D( gm_BaseTexture, v_vTexcoord );
	if(clr.a > 0.) { gl_FragColor = clr; return; }
	
	clr = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, 0.) );
	if(clr.a > 0.) { gl_FragColor = clr; return; }
	
	clr = texture2D( gm_BaseTexture, v_vTexcoord + vec2( 0., tx.y) );
	if(clr.a > 0.) { gl_FragColor = clr; return; }
	
	clr = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, 0.) );
	if(clr.a > 0.) { gl_FragColor = clr; return; }
	
	clr = texture2D( gm_BaseTexture, v_vTexcoord + vec2(0., -tx.y) );
	if(clr.a > 0.) { gl_FragColor = clr; return; }
}
