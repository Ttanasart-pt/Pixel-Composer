#pragma use(uv)

#region -- uv -- [1770002023.9166503]
    uniform sampler2D uvMap;
    uniform int   useUvMap;
    uniform float uvMapMix;

    vec2 getUV(in vec2 uv) {
        if(useUvMap == 0) return uv;

        vec2 vuv   = texture2D( uvMap, uv ).xy;
             vuv.y = 1.0 - vuv.y;

        vec2 vtx = mix(uv, vuv, uvMapMix);
        return vtx;
    }
#endregion -- uv --
#pragma use(gradient)

#region -- gradient -- [1764901316.7213297]
	#define GRADIENT_LIMIT 128
	
	uniform int		  gradient_blend;
	uniform vec4	  gradient_color[GRADIENT_LIMIT];
	uniform float	  gradient_time[GRADIENT_LIMIT];
	uniform int		  gradient_keys;
	uniform int       gradient_use_map;
	uniform vec4      gradient_map_range;
	uniform sampler2D gradient_map;

	vec3 linearToGamma(vec3 c) { return pow(c, vec3(     2.2)); }
	vec3 gammaToLinear(vec3 c) { return pow(c, vec3(1. / 2.2)); }
	
	vec3 rgbMix(vec3 c1, vec3 c2, float t) {
		vec3 k1 = linearToGamma(c1);
		vec3 k2 = linearToGamma(c2);
		
		return gammaToLinear(mix(k1, k2, t));
	} 
	
	vec3 rgb2oklab(vec3 c) {
		const mat3 kCONEtoLMS = mat3(                
	         0.4121656120,  0.2118591070,  0.0883097947,
	         0.5362752080,  0.6807189584,  0.2818474174,
	         0.0514575653,  0.1074065790,  0.6302613616);
	    
		c = pow(c, vec3(2.2));
		c = pow( kCONEtoLMS * c, vec3(1.0 / 3.0) );
		
		return c;
	}
	
	vec3 oklab2rgb(vec3 c) {
		const mat3 kLMStoCONE = mat3(
	         4.0767245293, -1.2681437731, -0.0041119885,
	        -3.3072168827,  2.6093323231, -0.7034763098,
	         0.2307590544, -0.3411344290,  1.7068625689);
        
		c = kLMStoCONE * (c * c * c);
		c = pow(c, vec3(1. / 2.2));
		
	    return c;
	}

	vec3 oklabMax(vec3 c1, vec3 c2, float t) {
		vec3 k1 = rgb2oklab(c1);
		vec3 k2 = rgb2oklab(c2);
		
		return oklab2rgb(mix(k1, k2, t));
	} 
	
	vec3 rgb2hsv(vec3 c) {
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	    float d = q.x - min(q.w, q.y);
	    float e = 0.0000000001;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	}

	vec3 hsv2rgb(vec3 c) {
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	}

	float hueDist(float a0, float a1, float t) {
		float da = fract(a1 - a0);
	    float ds = fract(2. * da) - da;
	    return a0 + ds * t;
	}

	vec3 hsvMix(vec3 c1, vec3 c2, float t) {
		vec3 h1 = rgb2hsv(c1);
		vec3 h2 = rgb2hsv(c2);
	
		vec3 h = vec3(0.);
		h.x = h.x + hueDist(h1.x, h2.x, t);
		h.y = mix(h1.y, h2.y, t);
		h.z = mix(h1.z, h2.z, t);
	
		return hsv2rgb(h);
	}

	vec4 gradientEval(in float prog) {
		if(gradient_use_map == 1) {
			vec2 samplePos = mix(gradient_map_range.xy, gradient_map_range.zw, prog);
			return texture2D( gradient_map, samplePos );
		}
		
		for(int i = 0; i < GRADIENT_LIMIT; i++) {
			if(gradient_time[i] == prog) {
				return gradient_color[i];
				
			} else if(gradient_time[i] > prog) {
				if(i == 0) 
					return gradient_color[i];
				else {
					float t  = (prog - gradient_time[i - 1]) / (gradient_time[i] - gradient_time[i - 1]);
					vec3  c0 = gradient_color[i - 1].rgb;
					vec3  c1 = gradient_color[i].rgb;
					float a  = mix(gradient_color[i - 1].a, gradient_color[i].a, t);
					
					if(gradient_blend == 0)
						return vec4(mix(c0, c1, t), a);
						
					else if(gradient_blend == 1)
						return gradient_color[i - 1];
						
					else if(gradient_blend == 2)
						return vec4(hsvMix(c0, c1, t), a);
						
					else if(gradient_blend == 3)
						return vec4(oklabMax(c0, c1, t), a);
					
					else if(gradient_blend == 4)
						return vec4(rgbMix(c0, c1, t), a);
				}
				break;
			}
			
			if(i >= gradient_keys - 1)
				return gradient_color[gradient_keys - 1];
		}
	
		return gradient_color[gradient_keys - 1];
	}
	
#endregion -- gradient --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359

uniform float seed;
uniform vec2  dimension;
uniform vec2  position;

uniform vec2  spacing;
uniform float intensity;
uniform float aa;

uniform int   pattern;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      dothr;
uniform int       dothrUseSurf;
uniform sampler2D dothrSurf;

uniform int   coloring;
uniform int   colorMode;
uniform vec4  color0;
uniform vec4  color1;
uniform sampler2D texture;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform vec4  palette[PALETTE_LIMIT];
uniform int   paletteAmount;

vec2 amoVec;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy, vec2(1892.9898, 78.23453))) * (seed + 437.54123)); }

float getDist(vec2 tx, vec2 _frc) {
	float thr = dothr.x;
	if(dothrUseSurf == 1) {
		vec2 _tx   = tx;
		     _tx  += position / dimension;
		vec4 _vMap = texture2D( dothrSurf, _tx );
		thr = mix(dothr.x, dothr.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float dist, dott;
	float d = distance(_frc, vec2(.5)) * 2.;

	if(coloring == 0) {
		dist = 1. - d;
		dott = step(1. - thr, dist);
	
	} else if(coloring == 1) {
		dist = 1. - d;
		dott = smoothstep(1. - aa - thr, 1. - thr, dist);
		
	} else if(coloring == 2) {
		if(thr == 0.) return 0.;
		dist = thr - d;
		dott = max(0., dist);
	}
	
	return dott;
}

vec4 getD(vec2 _cen, vec2 _frc, vec2 _shf) { 
	vec2 tx = _cen + _shf / amoVec;
	vec2 rx = tx * amoVec;
	vec4 cc;
	
	if(colorMode == 0) {
		cc = vec4(1.);
		
	} else if(colorMode == 1) {
		float ind = mod(rx.y + rx.x, float(paletteAmount));
		cc = palette[int(ind)];
		
	} else if(colorMode == 2) {
		float ind = random(rx, seed);
		cc = gradientEval(ind);
		
	} else if(colorMode == 3) {
		cc = texture2D( texture, tx );
		
	}
	
	return cc * intensity * getDist(tx, (_frc - _shf) * spacing); 
}

void main() {
	#region params
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
		
		float amo = amount.x;
		if(amountUseSurf == 1) {
			vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
			amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		amoVec = (dimension / vec2(amo)) / spacing;
	#endregion
	
	vec2 vtx  = getUV(v_vTexcoord);
	vec2 asp  = vec2(dimension.x / dimension.y, 1.);
	vec2 pos  = (vtx - position / dimension) * asp;
	     pos *= mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
	      
	vec4 cbg  = color0;
	vec4 dott = vec4(0.);
	
	if(pattern == 0) {
		
		vec2 _box = floor(pos * amoVec);
		vec2 _frc = pos * amoVec - _box;
		vec2 _cen = _box / amoVec;
		
		dott += getD(_cen, _frc, vec2(-1., -1.));
		dott += getD(_cen, _frc, vec2( 0., -1.));
		dott += getD(_cen, _frc, vec2( 1., -1.));
		
		dott += getD(_cen, _frc, vec2(-1.,  0.));
		dott += getD(_cen, _frc, vec2( 0.,  0.));
		dott += getD(_cen, _frc, vec2( 1.,  0.));
		
		dott += getD(_cen, _frc, vec2(-1.,  1.));
		dott += getD(_cen, _frc, vec2( 0.,  1.));
		dott += getD(_cen, _frc, vec2( 1.,  1.));
		
	} else if(pattern == 1) {
		vec2 s3 = vec2(1., sqrt(3.) / 2.);
		amoVec /= s3;
		
		vec2 _box = floor(pos * amoVec);
		float by = floor(mod(_box.y, 2.));
		if(by == 1.) _box.x += .5;
		
		vec2 _frc = pos * amoVec - _box;
		     _frc = .5 + (_frc - .5) * s3;
		vec2 _cen = _box / amoVec;
		
		dott += getD(_cen, _frc, vec2(-.5, -1.) * s3);
		dott += getD(_cen, _frc, vec2( .5, -1.) * s3);
		
		dott += getD(_cen, _frc, vec2(-1.,  0.) * s3);
		dott += getD(_cen, _frc, vec2( 0.,  0.) * s3);
		dott += getD(_cen, _frc, vec2( 1.,  0.) * s3);
		
		dott += getD(_cen, _frc, vec2(-.5,  1.) * s3);
		dott += getD(_cen, _frc, vec2( .5,  1.) * s3);
		
	}
	
	if(colorMode == 0)
		gl_FragColor = mix(cbg, color1, dott.a);
	else
		gl_FragColor = cbg + dott;
}