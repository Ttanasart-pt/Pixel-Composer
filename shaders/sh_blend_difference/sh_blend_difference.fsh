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
	
	vec2 _frtx = tile_type == 1? fract(v_vTexcoord * dimension) : v_vTexcoord;
	vec4 _col1 = texture2D( fore, _frtx );
	
	float mx = opacity * sampleMask();
	
	/////////////////////////////////////////////////
		vec4 res = vec4(abs(_col0.rgb - _col1.rgb), 1.);
	/////////////////////////////////////////////////
	
    gl_FragColor = mix(_col0, res, mx);
}
