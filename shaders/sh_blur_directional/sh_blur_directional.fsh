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
#pragma use(curve)

#region -- curve -- [1742009781.2228172]

    #ifdef _YY_HLSL11_ 
        #define CURVE_MAX  512
    #else 
        #define CURVE_MAX  256
    #endif

    uniform int   curve_offset;

    float eval_curve_segment_t(in float _y0, in float ax0, in float ay0, in float bx1, in float by1, in float _y1, in float prog) {
        float p = prog;
        float i = 1. - p;
        
        return _y0 *      i*i*i + 
            ay0 * 3. * i*i*p + 
            by1 * 3. * i*p*p + 
            _y1 *      p*p*p;
    }

    float eval_curve_segment_x(in float _y0, in float ax0, in float ay0, in float bx1, in float by1, in float _y1, in float _x) {
        float st = 0.;
        float ed = 1.;
        float _prec = 0.0001;
        
        float _xt = _x;
        int _binRep = 8;
        
        if(_x <= 0.) return _y0;
        if(_x >= 1.) return _y1;
        if(_y0 == ay0 && _y0 == by1 && _y0 == _y1) return _y0;
        
        for(int i = 0; i < _binRep; i++) {
            float _ftx = 3. * pow(1. - _xt, 2.) * _xt * ax0 
                    + 3. * (1. - _xt) * pow(_xt, 2.) * bx1
                    + pow(_xt, 3.);
            
            if(abs(_ftx - _x) < _prec)
                return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, _xt);
            
            if(_xt < _x) st = _xt;
            else		 ed = _xt;
            
            _xt = (st + ed) / 2.;
        }
        
        int _newRep = 16;
        
        for(int i = 0; i < _newRep; i++) {
            float slope = (  9. * ax0 - 9. * bx1 + 3.) * _xt * _xt
                        + (-12. * ax0 + 6. * bx1) * _xt
                        +    3. * ax0;
            float _ftx = 3. * pow(1. - _xt, 2.) * _xt * ax0 
                    + 3. * (1. - _xt) * pow(_xt, 2.) * bx1
                    + pow(_xt, 3.)
                    - _x;
            
            _xt -= _ftx / slope;
            
            if(abs(_ftx) < _prec)
                break;
        }
        
        _xt = clamp(_xt, 0., 1.);
        return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, _xt);
    }

    float curveEval(in float[CURVE_MAX] curve, in int amo, in float _x) {
        
        int   _segs  = (amo - curve_offset) / 6 - 1;
        float _shift = curve[0];
        float _scale = curve[1];
        float _type  = curve[2];
        
        _x = _x / _scale - _shift;
        _x = clamp(_x, 0., 1.);
        
        if(_type == 0.) {
            for( int i = 0; i < _segs; i++ ) {
                int ind    = curve_offset + i * 6;
                float _x0  = curve[ind + 2];
                float _y0  = curve[ind + 3];
                float _x1  = curve[ind + 6 + 2];
                float _y1  = curve[ind + 6 + 3];

                float _dx0 = curve[ind + 4];
                float _dy0 = curve[ind + 5];
                float _dx1 = curve[ind + 6 + 0];
                float _dy1 = curve[ind + 6 + 1];

                if(abs(_dx0) + abs(_dx1) > 1.) {
                    float _total = abs(_dx0) + abs(_dx1);
                    _dx0 /= _total;
                    _dx1 /= _total;
                }

                float ax0  = _x0 + _dx0;
                float ay0  = _y0 + _dy0;
                float bx1  = _x1 + _dx1;
                float by1  = _y1 + _dy1;
                
                if(_x < _x0) continue;
                if(_x > _x1) continue;

                float t = (_x - _x0) / (_x1 - _x0);
                if(curve[ind + 4] == 0. && curve[ind + 5] == 0. && curve[ind + 6 + 0] == 0. && curve[ind + 6 + 1] == 0.)
                    return mix(_y0, _y1, t);
                
                return eval_curve_segment_x(_y0, ax0, ay0, bx1, by1, _y1, t);
            }

        } else if(_type == 1.) {
            float y0 = curve[curve_offset + 3];

            for( int i = 0; i < _segs; i++ ) {
                int ind   = curve_offset + i * 6;
                float _x0 = curve[ind + 2];

                if(_x < _x0) return y0;
                y0 = curve[ind + 3];
            }

            return y0;
        }

        return curve[amo - 3];
    }

#endregion -- curve --
#pragma use(sampler_simple)

#region -- sampler_simple -- [1764837291.6127295]
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
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
    vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler_simple --


varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float     size;
uniform float     resolution;
uniform int       singleDirect;
uniform int       fadeDistance;

uniform vec2      direction;
uniform int       directionUseSurf;
uniform sampler2D directionSurf;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform int	  gamma;

uniform float s_curve[CURVE_MAX];
uniform int   s_curve_use;
uniform int   s_amount;

uniform int   spectralUse;
uniform float spectralIntensity;
uniform float spectralShift;
uniform float spectralScale;

vec3 bump3y(vec3 x, vec3 yoffset) {
	vec3 y = vec3(1.) - x * x;
	     y = clamp(y - yoffset, 0., 1.);
	return y;
}

vec3 spectral_zucconi6(float x) {
	const vec3 c1 = vec3(3.54585104, 2.93225262, 2.41593945);
	const vec3 x1 = vec3(0.69549072, 0.49228336, 0.27699880);
	const vec3 y1 = vec3(0.02312639, 0.15225084, 0.52607955);

	const vec3 c2 = vec3(3.90307140, 3.21182957, 3.96587128);
	const vec3 x2 = vec3(0.11748627, 0.86755042, 0.66077860);
	const vec3 y2 = vec3(0.84897130, 0.88445281, 0.73949448);

	return bump3y(c1 * (x - x1), y1) +
		   bump3y(c2 * (x - x2), y2) ;
}

vec4 dirBlur(vec2 angle) {
    vec4  res    = vec4(0.);
    vec3  spec   = vec3(0.);
    float delta  = 1. / size / resolution;
	float weight = 0.;
	float itrr   = 0.;
    
    for(float i = singleDirect == 0? -1. : 0.; i <= 1.0; i += delta) {
		vec4  col  = sampleTexture( gm_BaseTexture, v_vTexcoord - angle * i, abs(i));
		if(gamma == 1) col.rgb = pow(col.rgb, vec3(2.2));
		
    	float fade = fadeDistance == 1? 1. - abs(i) : 1.;
    	float ampl = s_curve_use == 0? 1. : curveEval(s_curve, s_amount, abs(i));
    	
		col.rgb *= fade;
        res     += col   * ampl;
		weight  += col.a * fade;
		itrr    += fade;
		
		float specOffs = fract(abs(i * spectralScale) + spectralShift);
		float specInts = fade * ampl * length(col.rgb) * col.a * spectralIntensity;
		
		if(spectralUse == 1) spec += spectral_zucconi6(specOffs) * specInts;
		if(spectralUse == 2) spec += gradientEval(specOffs).rgb * specInts;
    }
	
	res.rgb += spec;
	res.rgb /= weight;
	res.a   /= itrr;
		
	if(gamma == 1) res.rgb = pow(res.rgb, vec3(1. / 2.2));
	
    return res;
}

void main() {
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	} str /= 128.;
	
	float dir = direction.x;
	if(directionUseSurf == 1) {
		vec4 _vMap = texture2D( directionSurf, v_vTexcoord );
		dir = mix(direction.x, direction.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    float r   = radians(dir + 90.);
    vec2 dirr = vec2(sin(r), cos(r)) * str;
    
    gl_FragColor = dirBlur(dirr);
}