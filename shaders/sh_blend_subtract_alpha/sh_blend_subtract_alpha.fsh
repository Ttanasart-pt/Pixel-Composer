//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int tile_type;

uniform int useMask;
uniform sampler2D mask;
uniform sampler2D fore;
uniform float opacity;

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
	
	float o = opacity;
	if(useMask == 1) {
		vec3 m = texture2D( mask, v_vTexcoord ).rgb;
		o *= (m.r + m.g + m.b) / 3.;
	}
	_col1.a *= o;
	_col1.rgb *= _col1.a;
	
	vec4 res = _col0 - _col1;
	res.a = _col0.a;
	
    gl_FragColor = res;
}
