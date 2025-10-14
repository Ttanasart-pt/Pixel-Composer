varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2      dimension;
uniform float     gaussianCoeff[128];

uniform int       bright;
uniform int       brightInvert;
uniform vec2      brightThreshold;
uniform int       brightThresholdUseSurf;
uniform sampler2D brightThresholdSurf;
uniform float     brightSmooth;
uniform float     adaptiveRadius;
uniform int       brightAlpha;
uniform int       brightMulp;

uniform int       alpha;
uniform int       alphaInvert;
uniform vec2      alphaThreshold;
uniform int       alphaThresholdUseSurf;
uniform sampler2D alphaThresholdSurf;
uniform float     alphaSmooth;

float _step( in float threshold, in float val ) { return val < threshold? 0. : 1.; }
float getBright( in vec4 c ) { return dot(c.rgb, vec3(0.2126, 0.7152, 0.0722)); }

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
	vec2 tx   = 1. / dimension;
	
	if(bright == 1) {
		float cbright = getBright(col);
		float bNeight = 0.;
		
		for(float j = -adaptiveRadius; j <= adaptiveRadius; j++) 
		for(float i = -adaptiveRadius; i <= adaptiveRadius; i++) {
			float b  = getBright(texture2D( gm_BaseTexture, clamp(v_vTexcoord + tx * vec2(i, j), 0., 1.) ));
			      b *= gaussianCoeff[int(abs(i))] * gaussianCoeff[int(abs(j))];
			bNeight += b;
		}
		
		bNeight -= bri;
		
		float _res = brightSmooth == 0.? _step(bNeight, cbright) : smoothstep(bNeight - brightSmooth, bNeight + brightSmooth, cbright);
		if(brightInvert == 1) _res = 1. - _res;
		
		if(brightAlpha == 0) col.rgb = vec3(_res);
		else                 col     = vec4(col.rgb, _res);
		
		if(brightMulp   == 1) col *= base;
	}
	
	if(alpha == 1) {
		col.a = alphaSmooth == 0.? _step(alp, col.a) : smoothstep(alp - alphaSmooth, alp + alphaSmooth, col.a);
		if(alphaInvert == 1) col.a = 1. - col.a;
	}
	
    gl_FragColor = col;
}
