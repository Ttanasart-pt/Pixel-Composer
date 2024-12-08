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

uniform float btop;
uniform float bbot;

void main() {
	vec2 pos = v_vTexcoord.x > 0.5? vec2(v_vTexcoord.x - 0.5, v_vTexcoord.y) : vec2(0.5 - v_vTexcoord.x, v_vTexcoord.y);
	
	float _t = (1. - pos.y);
	float _x = 3. * (btop * _t * (1. - _t) * (1. - _t) + bbot * _t * _t * (1. - _t));
	
    gl_FragColor = pos.x < _x? v_vColour : vec4(0.);
}

