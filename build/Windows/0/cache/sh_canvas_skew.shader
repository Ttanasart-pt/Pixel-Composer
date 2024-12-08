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
uniform vec2  origin;
uniform float amount;

float round(float x) { return x >= 0.? floor(x) : floor(x) + 1.; }

void main() {
	vec2 px = v_vTexcoord * dimension;
	vec2 amo;
	
		 if(axis == 0) amo = vec2(round(amount * (px.y - origin.y)), 0.);
	else if(axis == 1) amo = vec2(0., round(amount * (px.x - origin.x)));
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord - amo / dimension);
}

