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

uniform vec2  dimension;
uniform vec2  pos1;
uniform vec2  pos2;
uniform int   usePath;
uniform int   pathResolution;
uniform vec2  pathList[1024];

uniform float radius;
uniform float radius2;
uniform float intensity;
uniform float pushIntens;

uniform float falloff;
uniform float falloff_curve[CURVE_MAX];
uniform int   falloff_curve_use;
uniform int   falloff_amount;

vec2 closestPointOnLine(vec2 P, vec2 A, vec2 B, out float t) {
    vec2 AP = P - A;
    vec2 AB = B - A;
    t = dot(AP, AB) / dot(AB, AB);
    t = clamp(t, 0.0, 1.0);
    return A + t * AB;
}

void main() {
    vec2  tx  = 1. / dimension;
    vec2  pushPoint = vec2(0.); 
    vec2  pushDir   = vec2(0.);
    float pushT     = 0.;
    float inf = 0.;
    vec2  stx = v_vTexcoord;
    vec2  p1, p2;
    
    if(usePath == 0) {
        p1 = pos1 * tx;
        p2 = pos2 * tx;
        pushDir = p2 - p1;
        
        pushPoint = closestPointOnLine(v_vTexcoord, p1, p2, pushT);
        float dis = distance(v_vTexcoord * dimension, pushPoint * dimension);
        float rad = mix(radius, radius2, pushT);
        
        if(falloff_curve_use == 1) {
            float normDis = dis / (rad + falloff);
            float curveVal = curveEval(falloff_curve, falloff_amount, normDis);
            inf = clamp(curveVal, 0., 1.);
        } else
            inf = smoothstep(rad - falloff, rad + falloff, dis);
        inf = 1. - inf;
        
        stx -= (pushPoint - stx) * inf * intensity * pushIntens;
        stx -=  pushDir * inf * intensity * pushT;
        
    } else {
        float minDist = 9999.;
        float _intRes = intensity;
        float _pshRes = pushIntens / float(pathResolution);
        vec2 cpc;
        
        for(int i = pathResolution - 2; i >= 0; i--) {
            p1  = pathList[i]     * tx;
            p2  = pathList[i + 1] * tx;
            cpc = closestPointOnLine(stx, p1, p2, pushT);
            
            pushPoint = cpc;
            pushDir   = p2 - p1;
            
            float rad = mix(radius, radius2, (float(i) + pushT) / float(pathResolution));
            float dis = distance(stx * dimension, pushPoint * dimension);
            
            if(falloff_curve_use == 1) {
            	float normDis = dis / (rad + falloff);
	            float curveVal = curveEval(falloff_curve, falloff_amount, normDis);
	            inf = clamp(curveVal, 0., 1.);
	        } else
	            inf = smoothstep(rad - falloff, rad + falloff, dis);
	        inf = 1. - inf;
            
            stx += (pushPoint - v_vTexcoord) * inf * _intRes * _pshRes;
            stx -=  pushDir * inf * _intRes * pushT;
        }
    }
    
    gl_FragColor = texture2Dintp( gm_BaseTexture, stx );
}
