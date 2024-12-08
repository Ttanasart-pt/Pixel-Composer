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

uniform sampler2D textureMap;
uniform vec2 dimension;
uniform vec2 oriPosition;
uniform vec2 oriScale;
uniform int   side;

uniform int   shadowInv;
uniform float shadow;
uniform float shadowThres;

void main() {
	vec2 texPos = texture2D( textureMap, v_vTexcoord ).xy;
	vec2 oriPos = v_vTexcoord - (oriPosition / dimension);
	     oriPos /= oriScale / dimension;
	
	float shade;
	if(side == 0) {
		if(shadowInv == 0) shade = oriPos.y - shadowThres < texPos.y? shadow : 1.;
		else               shade = oriPos.y - shadowThres > texPos.y? shadow : 1.;
	} else {
		if(shadowInv == 0) shade = oriPos.x - shadowThres < texPos.x? shadow : 1.;
		else               shade = oriPos.x - shadowThres > texPos.x? shadow : 1.;
	}
	
	vec4  tex   = texture2D( gm_BaseTexture, v_vTexcoord );
	
	tex.rgb *= shade;
	
    gl_FragColor = tex;
}

