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
// SDF (with blur) fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// SDF values are measured from 0 (at the outer edge) to 1 which is the innermost point that can be represented
uniform vec2 gm_SDF_Blur_MinMax;			// the range across which to filter the SDF
uniform vec4 gm_SDF_Blur_Col;				// the colour tint of the blurred text

void main()
{
	vec4 texcol = texture2D( gm_BaseTexture, v_vTexcoord );	
	vec4 currcol = gm_SDF_Blur_Col;
		
	currcol.a *= smoothstep(gm_SDF_Blur_MinMax.x, gm_SDF_Blur_MinMax.y, texcol.a);		
	
	vec4 combinedcol = v_vColour * currcol;
	DoAlphaTest(combinedcol);	

    gl_FragColor = combinedcol;
}

