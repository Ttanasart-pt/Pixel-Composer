#pragma use(curve)

#region -- curve -- [1765334869.6409068]

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
        int _binRep = 8;
        float _prec = 0.0001;

        if(_x <= 0.) return _y0;
        if(_x >= 1.) return _y1;
        if(_y0 == ay0 && _y0 == by1 && _y0 == _y1) return _y0;

        float t = _x;
                
        for(int i = 0; i < _binRep; i++) {
            float _t = 1. - t;
            float ft =   3. * _t * _t * t * ax0 
                       + 3. * _t *  t * t * bx1
                       +       t *  t * t;
            
            if(abs(ft - _x) < _prec)
                return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, t);
            
            float dfdt =  3. * _t * _t *  ax0
				        + 6. * _t *  t * (bx1 - ax0)
				        + 3. *  t *  t * (1. - bx1);
            
            t = t - (ft - _x) / dfdt;
        }
        
        return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, t);
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

                if(_x < _x0) continue;
                if(_x > _x1) continue;

                float _dx0 = curve[ind + 4];
                float _dy0 = curve[ind + 5];
                float _dx1 = curve[ind + 6 + 0];
                float _dy1 = curve[ind + 6 + 1];
                
				if(abs(_dx0) + abs(_dx1) > abs(_x0 - _x1) * 2.) {
					float _rdx = (abs(_x0 - _x1) * 2.) / (abs(_dx0) + abs(_dx1));
					_dx0 *= _rdx;
					_dx1 *= _rdx;
				}
				
                float _rx  = _x1 - _x0;
                float t = (_x - _x0) / _rx;

                if(_dx0 == 0. && _dy0 == 0. && _dx1 == 0. && _dy1 == 0.)
                    return mix(_y0, _y1, t);
                
                float ax0  = 0. + _dx0 / _rx;
                float ay0  = _y0 + _dy0;

                float bx1  = 1. + _dx1 / _rx;
                float by1  = _y1 + _dy1;
                
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
#pragma use(sampler)

#region -- sampler -- [1765244104.78094]
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
	    
	    // Use 3x3 grid where each sample combines adjacent weights via bilinear
	    for(int x = -1; x <= 1; x++)
	    for(int y = -1; y <= 1; y++) {
	        // Combine weights from 2 adjacent taps in each direction
	        float wx_a = lanczosWeight(float(x * 2 - 1) - offset.x, float(LANCZOS_RADIUS));
	        float wx_b = lanczosWeight(float(x * 2    ) - offset.x, float(LANCZOS_RADIUS));
	        float wy_a = lanczosWeight(float(y * 2 - 1) - offset.y, float(LANCZOS_RADIUS));
	        float wy_b = lanczosWeight(float(y * 2    ) - offset.y, float(LANCZOS_RADIUS));
	        
	        float wx_total = wx_a + wx_b;
	        float wy_total = wy_a + wy_b;
	        float w = wx_total * wy_total;
	        
	        // Offset for bilinear interpolation between the two taps
	        vec2 samplePos = vec2(x * 2, y * 2) - vec2(.5, .5) + vec2(wx_b / wx_total, wy_b / wy_total);
	        
	        col += w * texture2D(texture, center + samplePos * tx);
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
		else if(sampleMode == 2) return vec4(0.,0.,0., 1.);
		else if(sampleMode == 3) return texture2Dintp(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 4) return texture2Dintp(texture, fract(pos));
		// 5
		else if(sampleMode == 6) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 7) { vec2 sp = vec2(fract(pos.x), pos.y); return (sp.y < 0. || sp.y > 1.) ? vec4(0.,0.,0.,1.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 8) return texture2Dintp(texture, vec2(fract(pos.x), clamp(pos.y, 0., 1.)));
		// 9
		else if(sampleMode == 10) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 11) { vec2 sp = vec2(pos.x, fract(pos.y)); return (sp.x < 0. || sp.x > 1.) ? vec4(0.,0.,0.,1.) : texture2Dintp(texture, sp); } 
		else if(sampleMode == 12) return texture2Dintp(texture, vec2(clamp(pos.x, 0., 1.), fract(pos.y)));
		
		return vec4(0.);
	}
	vec4 sampleTexture( sampler2D texture, vec2 pos) { return sampleTexture(texture, pos, 0.); }
#endregion -- sampler --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D map;
uniform sampler2D map2;

uniform vec2  dimension;
uniform vec2  map_dimension;
uniform vec2  displace;
uniform int   mode;
uniform int   sepAxis;

uniform int   iterate;
uniform float iteration;
uniform int   blendMode;
uniform int   fadeDist;
uniform int   reposition;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;
uniform float     strength_curve[CURVE_MAX];
uniform int       strength_curve_use;
uniform int       strength_amount;

uniform vec2      middle;
uniform int       middleUseSurf;
uniform sampler2D middleSurf;

float mid;

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }

vec2 shiftMap(in vec2 pos, in float str) {
	pos = getUV(pos);
	
	vec2  tx   = 1. / dimension;
	vec4  disP = texture2Dintp( map, pos );
	vec2  raw_displace = displace * tx;
	
	vec2  sam_pos;
	float _str;
	vec2  _disp;
	
	if(mode == 0) {
		_str  = bright(disP) - mid;
		if(strength_curve_use == 1) 
			_str = curveEval(strength_curve, strength_amount, _str);
		_disp = _str * str * raw_displace;
		sam_pos = pos + _disp;
		
	} else if(mode == 1) {
		if(sepAxis == 0)
			_disp = vec2(disP.r - mid, disP.g - mid) * vec2((disP.r + disP.g + disP.b) / 3. - mid) * str;
			
		else if(sepAxis == 1) {
			vec4  disP2 = texture2Dintp( map2, pos );
			
			_str  = bright(disP) - mid;
			if(strength_curve_use == 1) 
				_str = curveEval(strength_curve, strength_amount, _str);
			_disp.x = _str * str;
			
			_str  = bright(disP2) - mid;
			if(strength_curve_use == 1) 
				_str = curveEval(strength_curve, strength_amount, _str);
			_disp.y = _str * str;
		}
		
		sam_pos = pos + _disp;
		
	} else if(mode == 2) {
		float _ang;
		
		if(sepAxis == 0) {
			_ang = disP.r * PI * 2.;
			
			_str = disP.g - mid;
			if(strength_curve_use == 1) 
				_str = curveEval(strength_curve, strength_amount, _str);
			_str *= str;
			
		} else if(sepAxis == 1) {
			vec4  disP2 = texture2Dintp( map2, pos );
			
			_ang = bright(disP) * PI * 2.;
			
			_str = bright(disP2) - mid;
			if(strength_curve_use == 1) 
				_str = curveEval(strength_curve, strength_amount, _str);
			_str *= str;
		}
		
		sam_pos = pos + _str * vec2(cos(_ang), sin(_ang));
		
	} else if(mode == 3) {
		vec4  d0 = texture2Dintp( map, pos + vec2( tx.x, 0.) ); float h0 = (d0.r + d0.g + d0.b) / 3.;
		vec4  d1 = texture2Dintp( map, pos - vec2( 0., tx.y) ); float h1 = (d1.r + d1.g + d1.b) / 3.;
		vec4  d2 = texture2Dintp( map, pos - vec2( tx.x, 0.) ); float h2 = (d2.r + d2.g + d2.b) / 3.;
		vec4  d3 = texture2Dintp( map, pos + vec2( 0., tx.y) ); float h3 = (d3.r + d3.g + d3.b) / 3.;
		
		vec2 grad = vec2( h0 - h2, h3 - h1 ) - mid;
		sam_pos = pos + grad * str;
	}
	
	return sam_pos;
}

vec4 blend(in vec4 c0, in vec4 c1) {
	if(blendMode == 0) return c1;
	
	if(blendMode == 1) {
		float b0 = bright(c0);
		float b1 = bright(c1);
		return b0 < b1? c0 : c1;
	} 
	
	if(blendMode == 2) {
		float b0 = bright(c0);
		float b1 = bright(c1);
		return b0 > b1? c0 : c1;
	}
	
	return c1;
}

void main() {
	vec2 samPos = v_vTexcoord;
	vec4 ccol = sampleTexture( gm_BaseTexture, v_vTexcoord );
	vec4 ncol = ccol;
	
	float stren = strength.x;
	if(strengthUseSurf == 1) {
		vec4 strMap = texture2Dintp( strengthSurf, v_vTexcoord );
		stren = mix(strength.x, strength.y, (strMap.r + strMap.g + strMap.b) / 3.);
	}
	
	mid = middle.x;
	if(middleUseSurf == 1) {
		vec4 _vMap = texture2D( middleSurf, v_vTexcoord );
		mid = mix(middle.x, middle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	if(iterate == 1) {
		float _t = 1. / iteration;
		float str;
		vec4  c;
		
		for(float i = 0.; i < iteration; i++) {
			str    = stren * (i + 1.) * _t;
			samPos = shiftMap(reposition == 1? samPos : v_vTexcoord, str);
			c      = sampleTexture( gm_BaseTexture, samPos );
			if(fadeDist == 1) c.rgb *= 1. - i * _t;
			
			ncol   = blend(ncol, c);
		}
		
	} else {
		samPos = shiftMap(samPos, stren);
		ncol   = sampleTexture( gm_BaseTexture, samPos );
	}
	
    gl_FragColor = blend(ccol, ncol);
}