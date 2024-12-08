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

