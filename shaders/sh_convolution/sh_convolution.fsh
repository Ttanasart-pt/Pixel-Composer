//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float kernel[9];

void main() {
	vec2 tex = 1. / dimension;
	vec4 c = + kernel[0] * texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tex.x, -tex.y) )
		     + kernel[1] * texture2D( gm_BaseTexture, v_vTexcoord + vec2(    0., -tex.y) )
		     + kernel[2] * texture2D( gm_BaseTexture, v_vTexcoord + vec2( tex.x, -tex.y) )
			
		     + kernel[3] * texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tex.x, 0.) )
		     + kernel[4] * texture2D( gm_BaseTexture, v_vTexcoord + vec2(    0., 0.) )
		     + kernel[5] * texture2D( gm_BaseTexture, v_vTexcoord + vec2( tex.x, 0.) )
			
			 + kernel[6] * texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tex.x, tex.y) )
		     + kernel[7] * texture2D( gm_BaseTexture, v_vTexcoord + vec2(    0., tex.y) )
		     + kernel[8] * texture2D( gm_BaseTexture, v_vTexcoord + vec2( tex.x, tex.y) );
	
    gl_FragColor = c;
}
