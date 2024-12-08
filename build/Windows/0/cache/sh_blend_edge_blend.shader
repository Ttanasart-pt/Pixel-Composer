//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  edge;

uniform sampler2D mask;

void main() {
	float msk = texture2D( mask, v_vTexcoord ).r;
	vec4  cur = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4  off;
	
	if(edge == 0) {
		off = texture2D( gm_BaseTexture, fract(v_vTexcoord + vec2(0.5, 0.5)) );
		
	} else if(edge == 1) {
		off = texture2D( gm_BaseTexture, fract(v_vTexcoord + vec2(0.5, 0.0)) );
		
	} else if(edge == 2) {
		off = texture2D( gm_BaseTexture, fract(v_vTexcoord + vec2(0.0, 0.5)) );
		
	}
	
	gl_FragColor = mix(off, cur, msk);
}

