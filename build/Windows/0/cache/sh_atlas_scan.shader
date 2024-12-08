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

uniform vec2  dimension;
uniform int   axis;
uniform float iteration;

void main() {
	vec2 tx  = 1. / dimension;
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = col;
	
	if(col.a > 0.) return;
	
	float amo;
	vec2 _axs;
	vec4 ss;
	
	if(axis == 0) {
		amo = dimension.x;
		_axs = vec2(tx.x, 0.);
		
	} else {
		amo = dimension.y;
		_axs = vec2(0., tx.y);
		
	}
		
	for(float i = 1.; i < amo; i++) {
		ss = texture2D( gm_BaseTexture, v_vTexcoord + _axs * i);
		if(ss.a > 0.) { col = ss; break; }
		
		ss = texture2D( gm_BaseTexture, v_vTexcoord - _axs * i);
		if(ss.a > 0.) { col = ss; break; }
	}
	
	gl_FragColor = col;
}

