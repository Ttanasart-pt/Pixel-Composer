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
uniform sampler2D replace;
uniform vec2 replace_dim;
uniform sampler2D findRes;
uniform float index;

void main() {
	vec2 px = v_vTexcoord * dimension - (replace_dim - 1.);
	
	for( float i = 0.; i < replace_dim.x; i++ ) 
	for( float j = 0.; j < replace_dim.y; j++ ) {
		vec2 uv = px + vec2(i, j);
		if(uv.x < 0. || uv.y < 0.) continue;
		
		vec4 wg = texture2D( findRes, uv / dimension );
		
		if(wg.r == 1. && abs(wg.g - index) < 0.01) {
			gl_FragData[0] = texture2D( replace, (replace_dim - vec2(i, j) - 1. + .5) / replace_dim );
			gl_FragData[1] = vec4(1.);
			return;
		}
	}
}

