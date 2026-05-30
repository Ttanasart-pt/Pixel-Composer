#pragma use(sampler_simple)

#region -- sampler_simple -- [1765194569.6586206]
    uniform int  sampleMode;
    
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(vec2 tx) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, tx).xy;
            map.y    = 1.0 - map.y;
            tx       = mix(tx, map, uvMapMix);
        }
        return tx;
    }

    vec4 sampleTexture( sampler2D texture, vec2 pos, float mapBlend) {
        if(useUvMap == 1) {
            vec2 map = texture2D(uvMap, pos).xy;
            map.y    = 1.0 - map.y;
            pos      = mix(pos, map, mapBlend * uvMapMix);
        }

        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2D(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2D(texture, fract(pos));
        // 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 8) return texture2D(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2D(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2D(texture, sp); } 
		else if(sampleMode == 12) return texture2D(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --

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
			float b  = getBright(sampleTexture( gm_BaseTexture, v_vTexcoord + tx * vec2(i, j) ));
			      b *= gaussianCoeff[int(abs(i))] * gaussianCoeff[int(abs(j))];
			bNeight += b;
		}
		
		bNeight -= bri;
		
		float _res = brightSmooth == 0.? _step(bNeight, cbright) : smoothstep(bNeight - brightSmooth, bNeight + brightSmooth, cbright);
		if(brightInvert == 1) _res = 1. - _res;
		
		     if(brightAlpha == 0) col.rgb = vec3(_res);
		else if(brightAlpha == 1) col     = vec4(col.rgb,  _res);
		else if(brightAlpha == 2) col     = vec4(_res);
		
		if(brightMulp   == 1) col *= base;
	}
	
	if(alpha == 1) {
		col.a = alphaSmooth == 0.? _step(alp, col.a) : smoothstep(alp - alphaSmooth, alp + alphaSmooth, col.a);
		if(alphaInvert == 1) col.a = 1. - col.a;
	}
	
    gl_FragColor = col;
}
