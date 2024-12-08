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
uniform vec2 paddingStart;
uniform vec2 spacing;
uniform vec2 spriteDim;
uniform vec4 color;
uniform int  empty;

void main() {
	vec2 px   = v_vTexcoord * dimension - 0.5;
	vec2 cls  = floor((px - paddingStart) / (spriteDim + spacing)) * (spriteDim + spacing);
	
	gl_FragColor = vec4(0.);
	
	for(float i = 0.; i < spriteDim.x; i++)
	for(float j = 0.; j < spriteDim.y; j++) {
		vec2 tx = (cls + vec2(i, j)) / dimension;
		vec4 col = texture2D( gm_BaseTexture, tx );
		
		if((empty == 0 && col != color) || (empty == 1 && col.a != 0.)) {
			gl_FragColor = col;
			return;
		}
	}
}

