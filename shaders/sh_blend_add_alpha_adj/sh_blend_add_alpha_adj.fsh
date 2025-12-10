varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D fore;
uniform int preserveAlpha;

uniform vec2      opacity;
uniform int       opacityUseSurf;
uniform sampler2D opacitySurf;

void main() {
	float opa = opacity.x;
	if(opacityUseSurf == 1) {
		vec4 _vMap = texture2D( opacitySurf, v_vTexcoord );
		opa = mix(opacity.x, opacity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 _col0 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 _col1 = texture2D( fore, v_vTexcoord );
	
	vec4 res = _col0 + _col1 * opa;
	
	////////// Alpha
	float bright = dot(_col1.rgb, vec3(0.2126, 0.7152, 0.0722));
	float aa = _col0.a + bright * opa;
	res.a = aa;
	if(preserveAlpha == 1) res.a = _col0.a;
	
    gl_FragColor = res;
}
