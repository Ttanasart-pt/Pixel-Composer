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
uniform vec4 background;

void main() {
	bool emp = background.a == 0.;
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	if((emp && col.a > 0.) || (!emp && col != background)) { gl_FragColor = vec4(1.); return; }
	
	gl_FragColor = vec4(0.);
	vec2 tx = 1. / dimension;
	
	for(float i = 0.; i < dimension.x; i++) {
		vec4 col = texture2D( gm_BaseTexture, vec2(tx.x * i, v_vTexcoord.y) );
		if((emp && col.a > 0.) || (!emp && col != background)) {
			gl_FragColor = vec4(1.);
			break;
		}
	}
}

