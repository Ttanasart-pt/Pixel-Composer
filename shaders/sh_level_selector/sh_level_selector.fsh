varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2      middle;
uniform int       middleUseSurf;
uniform sampler2D middleSurf;

uniform vec2      range;
uniform int       rangeUseSurf;
uniform sampler2D rangeSurf;

uniform float     smoothness;
uniform int       keep;

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
	
	vec4  col    = texture2D( gm_BaseTexture, v_vTexcoord );
	float bright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
	
	if(keep == 0) col.rgb = vec3(1.);
	
	if(smoothness == 0.)
		col.rgb *= 1. - step(rng, abs(bright - mid));
	else 
		col.rgb *= 1. - smoothstep(rng - smoothness, rng + smoothness, abs(bright - mid));
	
	gl_FragColor = vec4(col.rgb, col.a);
}
