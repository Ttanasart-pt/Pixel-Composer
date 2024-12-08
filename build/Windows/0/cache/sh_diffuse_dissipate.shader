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
uniform float dissipation;

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 f0 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x, -tx.y) );
	vec4 f1 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0., -tx.y) );
	vec4 f2 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x, -tx.y) );
	
	vec4 f3 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,    0.) );
	vec4 f4 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0.,    0.) );
	vec4 f5 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,    0.) );
	
	vec4 f6 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(-tx.x,  tx.y) );
	vec4 f7 = texture2D( gm_BaseTexture, v_vTexcoord + vec2(   0.,  tx.y) );
	vec4 f8 = texture2D( gm_BaseTexture, v_vTexcoord + vec2( tx.x,  tx.y) );
	
    vec4 clr = (f0 + f1 + f2 + f3 + f4 + f5 + f6 + f7 + f8) / 9.;
    gl_FragColor = vec4(clr.rgb * dissipation, 1.);
}

