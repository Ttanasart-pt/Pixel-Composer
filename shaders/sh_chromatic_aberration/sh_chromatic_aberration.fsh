// continuous chromatic aberration
// by 01000001

#pragma use(sampler)

#region -- sampler -- [1764837296.5436046]
	uniform int  interpolation;
	uniform vec2 sampleDimension;
	uniform int  sampleMode;

    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

	const float PI = 3.14159265358979323846;
	float sinc ( float x ) { return x == 0.? 1. : sin(x * PI) / (x * PI); }

	vec4 texture2D_bicubic( sampler2D texture, vec2 uv ) {
		uv = uv * sampleDimension + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);
		uv = (uv - 0.5) / sampleDimension;
		return texture2D( texture, uv );
	}

	const int RSIN_RADIUS = 1;
	vec4 texture2D_rsin( sampler2D texture, vec2 uv ) {
		vec2 tx = 1.0 / sampleDimension;
		vec2 p  = uv * sampleDimension;
		
		vec4  col = vec4(0.);
		float wei = 0.;
		
		for (int x = -RSIN_RADIUS; x <= RSIN_RADIUS; x++)
		for (int y = -RSIN_RADIUS; y <= RSIN_RADIUS; y++) {
			vec2 sx = vec2(float(x), float(y));
			float a = length(sx) / float(RSIN_RADIUS);
			// if(a > 1.) continue;
			
			vec4 sample = texture2D(texture, uv + sx * tx);
			float w     = sinc(a * PI * tx.x) * sinc(a * PI * tx.y);
			
			col += w * sample;
			wei += w;
		}
		
		col /= wei;
		return col;
	}

	const int LANCZOS_RADIUS = 3;
	float lanczosWeight(float d, float n) { return d == 0.0 ? 1.0 : (d * d < n * n ? sinc(d) * sinc(d / n) : 0.0); }

	vec4 texture2D_lanczos3( sampler2D texture, vec2 uv ) {
		vec2 center = uv - (mod(uv * sampleDimension, 1.0) - 0.5) / sampleDimension;
		vec2 offset = (uv - center) * sampleDimension;
		vec2 tx = 1. / sampleDimension;
		
		vec4  col = vec4(0.);
		float wei = 0.;
		
		for(int x = -LANCZOS_RADIUS; x < LANCZOS_RADIUS; x++)
		for(int y = -LANCZOS_RADIUS; y < LANCZOS_RADIUS; y++) {
			
			float wx = lanczosWeight(float(x) - offset.x, float(LANCZOS_RADIUS));
			float wy = lanczosWeight(float(y) - offset.y, float(LANCZOS_RADIUS));
			float w  = wx * wy;
			
			col += w * texture2D(texture, center + vec2(x, y) * tx);
			wei += w;
		}
		
		col /= wei;
		return col;
	}

	vec4 texture2Dintp( sampler2D texture, vec2 uv ) {
			 if(interpolation <= 2)	return texture2D(          texture, uv );
		else if(interpolation == 3)	return texture2D_bicubic(  texture, uv );
		else if(interpolation == 4)	return texture2D_lanczos3( texture, uv );
		
		return texture2D( texture, uv );
	}

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
			return texture2Dintp(texture, pos);
		
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return texture2Dintp(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 3) return texture2Dintp(texture, fract(pos));
		else if(sampleMode == 4) return vec4(vec3(0.), 1.);
		
		return vec4(0.);
	}
	vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float     resolution;

uniform int       type;
uniform vec2      dimension;
uniform vec2      center;

uniform vec2      intensity;
uniform int       intensityUseSurf;
uniform sampler2D intensitySurf;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

float saturate (float x) { return min(1.0, max(0.0,x)); }
vec3  saturate (vec3  x) { return min(vec3(1.,1.,1.), max(vec3(0.,0.,0.),x)); }

vec3 bump3y (vec3 x, vec3 yoffset) {
	vec3 y = vec3(1.,1.,1.) - x * x;
	y = saturate(y - yoffset);
	return y;
}

vec3 spectral_zucconi6 (float w) {
	// w: [400, 700]
	// x: [0,   1]
	float x = saturate((w - 400.0)/ 300.0);

	const vec3 c1 = vec3(3.54585104, 2.93225262, 2.41593945);
	const vec3 x1 = vec3(0.69549072, 0.49228336, 0.27699880);
	const vec3 y1 = vec3(0.02312639, 0.15225084, 0.52607955);

	const vec3 c2 = vec3(3.90307140, 3.21182957, 3.96587128);
	const vec3 x2 = vec3(0.11748627, 0.86755042, 0.66077860);
	const vec3 y2 = vec3(0.84897130, 0.88445281, 0.73949448);

	return bump3y(c1 * (x - x1), y1) +
		   bump3y(c2 * (x - x2), y2) ;
}

vec4 chroma_scaling(vec2 uv, float str, float itns) {
	vec2 tx = 1.0 / dimension;
    vec2 co = (uv - center * tx) * 2.0;
    vec2 pp = vec2(0.);
	
	pp = dot(co, co) * co;
	pp *= str * tx;
	
    vec4 cr = sampleTexture(gm_BaseTexture, uv-pp, .5 ); cr.rgb *= cr.a;
    vec4 cb = sampleTexture(gm_BaseTexture, uv+pp, 1. ); cb.rgb *= cb.a;
    vec4 cv = sampleTexture(gm_BaseTexture, uv        ); cv.rgb *= cv.a;
    vec4 res = vec4(cr.r, cv.g, cb.b, cv.a + cr.a + cb.a);
    
    return mix(cv, res, itns);
}

vec4 chroma_continuous(vec2 uv, float str, float itns) {
	float stp  = resolution;
	vec2  tx   = 1.0 / dimension;
	float strr = str / 16. * .2;
	vec2  cuv  = (uv - center * tx) * 2.0;
    vec3  o    = vec3(0.);
    vec4  cv   = sampleTexture(gm_BaseTexture, uv);
    
    for (float i = 0.; i <= 1.; i += 1. / stp) {
    	vec4 sam = sampleTexture(gm_BaseTexture, uv - cuv * strr * i, i); 
    	sam.rgb *= sam.a;
        o += pow(sam.rgb, vec3(2.2)) * spectral_zucconi6(400. + i * 300.);
    }
    
    o /= stp * vec3(.386, .372, .23);
    o  = pow(o, vec3(1. / 2.2));
    vec4 res = vec4(o, 1.);
    
    return mix(cv, res, itns);
}

void main() {
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = sampleTexture( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float itns = intensity.x;
	if(intensityUseSurf == 1) {
		vec4 _vMap = sampleTexture( intensitySurf, v_vTexcoord );
		itns = mix(intensity.x, intensity.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	gl_FragColor = vec4(0.);
	
	if(type == 0) gl_FragColor = chroma_scaling(v_vTexcoord, str, itns);
	if(type == 1) gl_FragColor = chroma_continuous(v_vTexcoord, str, itns);
}
