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
	
	vec2 fore_tex = v_vTexcoord;
	if(tile_type == 0) {
		fore_tex = v_vTexcoord;
	} else if(tile_type == 1) {
		fore_tex = fract(v_vTexcoord * dimension);
	}
	
	vec4 _col1 = texture2D( fore, fore_tex );
	_col1.a *= opacity * sampleMask();
	
	float lum = dot(_col1.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec4 blend = lum > 0.5? (1. - (1. - 2. * (_col1 - 0.5)) * (1. - _col0)) : ((2. * _col1) * _col0);
	vec4 res = mix(_col0, blend, opacity);
	if(preserveAlpha == 1) res.a = _col0.a;
	
    gl_FragColor = res;
}
