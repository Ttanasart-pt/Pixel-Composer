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
	vec2 _frtx = tile_type == 1? fract(v_vTexcoord * dimension) : v_vTexcoord;
	vec4 _col1 = texture2D( fore, _frtx );
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
		vec4 blend = 1. - mix(1. - _col0, (1. - _col0) * (1. - _col1), opacity);
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	float po = preserveAlpha == 1? _col1.a : opacity;
	float al = _col1.a + _col0.a * (1. - _col1.a);
	vec4 res = mix(_col0, blend, po * sampleMask());
	res.rgb /= al;
	res.a = preserveAlpha == 1? _col0.a : res.a;
	
    gl_FragColor = res;
}
