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

uniform int   light;

uniform vec2      exposure;
uniform int       exposureUseSurf;
uniform sampler2D exposureSurf;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;
uniform float     strength_curve[CURVE_MAX];
uniform int       strength_curve_use;
uniform int       strength_amount;

uniform vec2      smoothness;
uniform int       smoothnessUseSurf;
uniform sampler2D smoothnessSurf;

void main() {
	#region 
		float epo = exposure.x;
		if(exposureUseSurf == 1) {
			vec4 _vMap = texture2D( exposureSurf, v_vTexcoord );
			epo = mix(exposure.x, exposure.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float str = strength.x;
		if(strengthUseSurf == 1) {
			vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
			str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float smo = smoothness.x;
		if(smoothnessUseSurf == 1) {
			vec4 _vMap = texture2D( smoothnessSurf, v_vTexcoord );
			smo = mix(smoothness.x, smoothness.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
	#endregion
	
	vec2 uv  = v_vTexcoord;
	
	vec2  _uv  = v_vTexcoord - 0.5;
	float dist = dot(_uv, _uv);
	float ang  = atan(_uv.y, _uv.x);
	vec2  _sp  = 0.5 + vec2(cos(ang), sin(ang)) * dist;
	
	float smt = smo / 2.;
	uv = mix(uv, _sp, smt);
	
	uv *= 1.0 - uv.yx;
    float vig = uv.x * uv.y * epo;
    
    vig = pow(vig, 0.25 + smt);
	vig = clamp(vig, 0., 1.);
	
	vec4 samp  = texture2D( gm_BaseTexture, v_vTexcoord );
	float strn = (1. - ((1. - vig) * str));
	if(strength_curve_use == 1) strn = curveEval(strength_curve, strength_amount, strn);
	
	if(light == 1) strn = strn < 0.001? 10000. : 1. / strn;
    gl_FragColor = vec4(samp.rgb * strn, samp.a);
}
