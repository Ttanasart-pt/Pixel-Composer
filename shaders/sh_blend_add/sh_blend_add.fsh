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
	vec4 _col0 = texture2D( gm_BaseTexture, v_vTexcoord );
	_col0.rgb *= _col0.a;
	
	vec2 fore_tex = v_vTexcoord;
	if(tile_type == 0) {
		fore_tex = v_vTexcoord;
	} else if(tile_type == 1) {
		fore_tex = fract(v_vTexcoord * dimension);
	}
	
	vec4 _col1 = texture2D( fore, fore_tex );
	_col1.a *= opacity * sampleMask();
	_col1.rgb *= _col1.a;
	
	float al = _col1.a + _col0.a * (1. - _col1.a);
	vec4 res = _col0 + _col1;
	res.rgb /= al;
	res.a = preserveAlpha == 1? _col0.a : res.a;
    gl_FragColor = res;
}
