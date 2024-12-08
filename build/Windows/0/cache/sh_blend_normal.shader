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

uniform vec2 dimension;
uniform int tile_type;

uniform int useMask;
uniform int preserveAlpha;
uniform sampler2D mask;
uniform sampler2D fore;
uniform float opacity;

float sampleMask() {
	if(useMask == 0) return 1.;
	vec4 m = texture2D( mask, v_vTexcoord );
	return (m.r + m.g + m.b) / 3. * m.a;
}

void main() {
	vec4 _cBg = texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec2 fore_tex = v_vTexcoord;
	if(tile_type == 0)
		fore_tex = v_vTexcoord;
	else if(tile_type == 1)
		fore_tex = fract(v_vTexcoord * dimension);
	
	vec4 _cFg = texture2D( fore, fore_tex );
	_cFg.a *= opacity * sampleMask();
	
	float al = _cFg.a + _cBg.a * (1. - _cFg.a);
	vec4 res = ((_cFg * _cFg.a) + (_cBg * _cBg.a * (1. - _cFg.a))) / al;
	res.a = al;
	
    gl_FragColor = res;
}

