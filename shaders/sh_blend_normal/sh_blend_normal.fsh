varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec2 position;
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
