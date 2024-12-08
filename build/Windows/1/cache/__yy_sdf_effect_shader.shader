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
// SDF (with effects) fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// SDF values are measured from 0 (at the outer edge) to 1 which is the innermost point that can be represented
uniform bool gm_SDF_DrawGlow;				// whether the glow effect is enabled
uniform vec2 gm_SDF_Glow_MinMax;			// the SDF range across which the glow fades
uniform vec4 gm_SDF_Glow_Col;				// the colour of the glow

uniform bool gm_SDF_DrawOutline;			// whether the outline effect is enabled
uniform float gm_SDF_Outline_Thresh;		// the SDF distance which represents the outer edge of the outline
uniform vec4 gm_SDF_Outline_Col;			// the colour of the outline

uniform float gm_SDF_Core_Thresh;			// the SDF distance which represents the outer edge the shape
uniform vec4 gm_SDF_Core_Col;				// the colour of the core part of the shape

void main()
{
	vec4 texcol = texture2D( gm_BaseTexture, v_vTexcoord );
		
	float pixelspread = fwidth(texcol.a);	
	pixelspread = max(pixelspread * 0.75, 0.001);	
	
	float blendfactor;
	vec4 currcol = vec4(0.0, 0.0, 0.0, -1.0);
	
	// Handle glow effect
	if (gm_SDF_DrawGlow)
	{		
		if (texcol.a > gm_SDF_Glow_MinMax.x)
		{
			currcol = gm_SDF_Glow_Col;
			currcol.a *= smoothstep(gm_SDF_Glow_MinMax.x, gm_SDF_Glow_MinMax.y, texcol.a);
		}
	}	
	
	// Handle outline effect
	if (gm_SDF_DrawOutline)
	{
		if (texcol.a > (gm_SDF_Outline_Thresh - pixelspread))
		{			
			blendfactor = smoothstep(gm_SDF_Outline_Thresh - pixelspread, gm_SDF_Outline_Thresh + pixelspread, texcol.a);
			if (currcol.a < 0.0)
			{
				currcol = vec4(gm_SDF_Outline_Col.r,gm_SDF_Outline_Col.g,gm_SDF_Outline_Col.b, 0.0);
			}
			currcol = mix(currcol, gm_SDF_Outline_Col, blendfactor);
		}
	}
	
	// Handle inner core
	blendfactor = smoothstep(gm_SDF_Core_Thresh - pixelspread, gm_SDF_Core_Thresh + pixelspread, texcol.a);
	
	if (currcol.a < 0.0)
	{
		currcol = vec4(gm_SDF_Core_Col.r,gm_SDF_Core_Col.g,gm_SDF_Core_Col.b, 0.0);
	}
	texcol = mix(currcol, gm_SDF_Core_Col, blendfactor);	
	
	vec4 combinedcol = v_vColour * texcol;
	DoAlphaTest(combinedcol);	
			
    gl_FragColor = combinedcol;
}

