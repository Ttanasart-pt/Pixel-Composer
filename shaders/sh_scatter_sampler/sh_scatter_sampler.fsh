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
#pragma use(curve)

#region -- curve -- [1771218718.8737755]

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

    float _curveEval(in float[CURVE_MAX] curve, in int amo, in float _x) {
        
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
    
    float curveEval(in float[CURVE_MAX] curve, in int amo, in float _x) {
        float _min   = curve[3];
        float _max   = curve[4];

        float _y = _curveEval(curve, amo, _x);
        return mix(_min, _max, _y);
    }

#endregion -- curve --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float     seed;
uniform float     randomize;

uniform int       useMask;
uniform sampler2D mask;

uniform float     inten_curve[CURVE_MAX];
uniform int       inten_amount;

uniform int       type;
uniform sampler2D surface;

uniform int       iteration;
uniform int       itrBlend;

uniform vec2      itrScale;
uniform int       itrScaleUseSurf;
uniform sampler2D itrScaleSurf;

uniform vec2      itrAmpli;
uniform int       itrAmpliUseSurf;
uniform sampler2D itrAmpliSurf;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

float random  (in vec2 st, float seed) { return fract(sin(dot(st.xy + seed / 1000., vec2(1892.9898, 78.23453))) * 437.54123); }
vec2  random2 (in vec2 st, float seed) { return vec2(random(st, seed), random(st, seed + 56.5742)); }

vec4 sample(vec2 px, float tile) {
	vec2 fr  = fract(px);
	vec2 fl  = floor(px);
	
	vec4 res = vec4(0.);
	
	for(float i = -2.; i <= 2.; i++)
	for(float j = -2.; j <= 2.; j++) {
		
		vec2 ofs = vec2(i, j);
		vec2 _fl = fl + ofs;
		vec2 _fr = fr - ofs;
		vec2 cen = vec2(.5) + (random2(mod(_fl, tile), seed) - .5) * 2. * randomize;
		
		vec2 mx = (_fl + cen) / tile + .5;
		
		if(useMask == 1) {
			vec4  msam = texture2D(mask, mx);
			float m    = (msam.r + msam.g + msam.b) / 3. * msam.a;
			if(m <= random(cen, seed)) continue;
		}
		
		float rad = radius.x;
		if(radiusUseSurf == 1) {
			vec4 _vMap = texture2D( radiusSurf, mx );
			rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		vec4 sam;
		
		if(type == 0) {
			sam = sampleTexture(surface, (_fr - .5) / rad + cen);
			
		} else if(type == 1) {
			float dist = 1. - distance(_fr, cen) * 2. / rad;
			      dist = clamp(dist, 0., 1.);
			
			sam = vec4(vec3(dist), 1.);
		}
		
		res += sam;
	}
	
	return res;
}

void main() {
	float isca = itrScale.x;
	if(itrScaleUseSurf == 1) {
		vec4 _vMap = texture2D( itrScaleSurf, v_vTexcoord );
		isca = mix(itrScale.x, itrScale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float iamp = itrAmpli.x;
	if(itrAmpliUseSurf == 1) {
		vec4 _vMap = texture2D( itrAmpliSurf, v_vTexcoord );
		iamp = mix(itrAmpli.x, itrAmpli.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float scl = scale.x;
	if(scaleUseSurf == 1) {
		vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
		scl = mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float wei = 0.;
	vec4  res = vec4(0.,0.,0.,1.);
	vec2  pos = (v_vTexcoord - .5) * scl;
	float sca = scl;
	float amp = 1.;
	
	for(int i = 0; i < 16; i++) {
		if(i >= iteration) break;
		
		vec4 sam = sample(pos, sca);
		sam.rgb *= amp;
		
		if(itrBlend == 0) {
			res += sam;
			wei += amp;
			
		} else if(itrBlend == 1) {
			res = max(res, sam);
			wei = 1.;
		}
		
		pos *= isca;
		sca *= isca;
		amp *= iamp;
	}
	
	res.rgb /= wei;
	
	gl_FragColor = res;
}