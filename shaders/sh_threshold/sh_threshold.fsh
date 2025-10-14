varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int       bright;
uniform int       brightInvert;
uniform vec2      brightThreshold;
uniform int       brightThresholdUseSurf;
uniform sampler2D brightThresholdSurf;
uniform float     brightSmooth;
uniform int       brightAlpha;
uniform int       brightMulp;

uniform int       alpha;
uniform int       alphaInvert;
uniform vec2      alphaThreshold;
uniform int       alphaThresholdUseSurf;
uniform sampler2D alphaThresholdSurf;
uniform float     alphaSmooth;

float _step( in float threshold, in float val ) { return val < threshold? 0. : 1.; }

void main() {
	float bri = brightThreshold.x;
	if(brightThresholdUseSurf == 1) {
		vec4 _vMap = texture2D( brightThresholdSurf, v_vTexcoord );
		bri = mix(brightThreshold.x, brightThreshold.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float alp = alphaThreshold.x;
	if(alphaThresholdUseSurf == 1) {
		vec4 _vMap = texture2D( alphaThresholdSurf, v_vTexcoord );
		alp = mix(alphaThreshold.x, alphaThreshold.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 base = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 col  = base;
	
	if(bright == 1) {
		float cbright = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
		float vBright = brightSmooth == 0.? _step(bri, cbright) : smoothstep(bri - brightSmooth, bri + brightSmooth, cbright);
		if(brightInvert == 1) vBright = 1. - vBright;
		
		if(brightAlpha == 0) col.rgb = vec3(vBright);
		else                 col     = vec4(col.rgb, vBright);
		
		if(brightMulp   == 1) col *= base;
	}
	
	if(alpha == 1) {
		col.a = alphaSmooth == 0.? _step(alp, col.a) : smoothstep(alp - alphaSmooth, alp + alphaSmooth, col.a);
		if(alphaInvert == 1) col.a = 1. - col.a;
	}
	
    gl_FragColor = col;
}
