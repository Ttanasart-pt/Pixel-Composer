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

uniform float dimension;

void main() {
	vec2 pos = v_vTexcoord * dimension;
	vec2 st  = floor(pos / 2.) * 2.;
	
    vec4 c0 = texture2D( gm_BaseTexture, (st + vec2(0., 0.)) / dimension );
    vec4 c1 = texture2D( gm_BaseTexture, (st + vec2(1., 0.)) / dimension );
    vec4 c2 = texture2D( gm_BaseTexture, (st + vec2(0., 1.)) / dimension );
    vec4 c3 = texture2D( gm_BaseTexture, (st + vec2(1., 1.)) / dimension );
	
	gl_FragColor = (c0 + c1 + c2 + c3) / (c0.a + c1.a + c2.a + c3.a);
}

