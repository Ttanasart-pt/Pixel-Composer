//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D fore;
uniform float opacity;
uniform int preserveAlpha;

void main() {
	vec4 _col0 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 _col1 = texture2D( fore, v_vTexcoord );
	
	vec4 res = _col0 + _col1 * opacity;
	
	////////// Alpha
	float bright = dot(_col1.rgb, vec3(0.2126, 0.7152, 0.0722));
	float aa = _col0.a + bright * opacity;
	res.a = aa;
	if(preserveAlpha == 1) res.a = _col0.a;
	
    gl_FragColor = res;
}
