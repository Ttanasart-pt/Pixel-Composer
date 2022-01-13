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
	_col1 *= o;
	
	vec4 res;
	res.r = max(_col0.r, _col1.r);
	res.g = max(_col0.g, _col1.g);
	res.b = max(_col0.b, _col1.b);
	res.a = max(_col0.a, _col1.a);
	
    gl_FragColor = res;
}
