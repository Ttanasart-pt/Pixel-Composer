//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

void main() {
	vec2 tex = 1. / dimension;
	vec4 c = - 1. * texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tex.x, -tex.y) )
		     - 1. * texture2D( gm_BaseTexture, v_vTexcoord + vec2(    0., -tex.y) )
		     - 1. * texture2D( gm_BaseTexture, v_vTexcoord + vec2( tex.x, -tex.y) )
			
		     - 1. * texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tex.x, 0.) )
		     + 9. * texture2D( gm_BaseTexture, v_vTexcoord + vec2(    0., 0.) )
		     - 1. * texture2D( gm_BaseTexture, v_vTexcoord + vec2( tex.x, 0.) )
			
			 - 1. * texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tex.x, tex.y) )
		     - 1. * texture2D( gm_BaseTexture, v_vTexcoord + vec2(    0., tex.y) )
		     - 1. * texture2D( gm_BaseTexture, v_vTexcoord + vec2( tex.x, tex.y) );
	
    gl_FragColor = c;
}
