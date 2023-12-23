//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2      middle;
uniform int       middleUseSurf;
uniform sampler2D middleSurf;

uniform vec2      range;
uniform int       rangeUseSurf;
uniform sampler2D rangeSurf;

void main() {
	float mid = middle.x;
	if(middleUseSurf == 1) {
		vec4 _vMap = texture2D( middleSurf, v_vTexcoord );
		mid = mix(middle.x, middle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float rng = range.x;
	if(rangeUseSurf == 1) {
		vec4 _vMap = texture2D( rangeSurf, v_vTexcoord );
		rng = mix(range.x, range.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 col     = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
	
	if(bright > mid + rng || bright < mid - rng)
		gl_FragColor = vec4(0., 0., 0., col.a);
	else
		gl_FragColor = vec4(1., 1., 1., col.a);
}
