//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
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

uniform sampler2D fore;
uniform vec2 dimension;
uniform vec2 fdimension;
uniform vec2 position;

void main() {
	vec2 px  = v_vTexcoord * dimension;
	vec2 fpx = px - position;
	vec2 ftx = fpx / fdimension;
	
	vec4 _cBg = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(ftx.x < 0. || ftx.y < 0. || ftx.x > 1. || ftx.y > 1.) {
		gl_FragColor = _cBg;
		return;
	}
	
	vec4 _cFg = texture2D( fore, ftx );
	float al  = _cFg.a + _cBg.a * (1. - _cFg.a);
	vec4 res  = (_cFg * _cFg.a) + (_cBg * _cBg.a * (1. - _cFg.a));
	res = vec4(res.rgb / al, al);
	
	gl_FragColor = res;
}

