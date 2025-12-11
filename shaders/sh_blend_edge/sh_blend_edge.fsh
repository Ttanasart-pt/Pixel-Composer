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

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  edge;

uniform vec2      width;
uniform int       widthUseSurf;
uniform sampler2D widthSurf;

uniform vec2      blend;
uniform int       blendUseSurf;
uniform sampler2D blendSurf;

uniform vec2      smooth;
uniform int       smoothUseSurf;
uniform sampler2D smoothSurf;
uniform float     smooth_curve[CURVE_MAX];
uniform int       smooth_curve_use;
uniform int       smooth_amount;

void main() {
	float wid = width.x;
	if(widthUseSurf == 1) {
		vec4 _vMap = texture2D( widthSurf, v_vTexcoord );
		wid = mix(width.x, width.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float bld = blend.x;
	if(blendUseSurf == 1) {
		vec4 _vMap = texture2D( blendSurf, v_vTexcoord );
		bld = mix(blend.x, blend.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float smt = smooth.x;
	if(smoothUseSurf == 1) {
		vec4 _vMap = texture2D( smoothSurf, v_vTexcoord );
		smt = mix(smooth.x, smooth.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float bnd = 1. - bld;
	vec4  off;
	float m  = 0.;
	vec2  v  = 1. - max(vec2(0.), (1. - abs(v_vTexcoord - 0.5) * 2.) / wid - bnd) / (1. - bnd);
	
	vec4 c1 = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 c2;
	
	if(edge == 0) { 
		m  = v.x;
		c2 = texture2D( gm_BaseTexture, vec2(fract(v_vTexcoord.x + 0.5), v_vTexcoord.y) );
		
	} else if(edge == 1) { 
		m  = v.y;
		c2 = texture2D( gm_BaseTexture, vec2(v_vTexcoord.x, fract(v_vTexcoord.y + 0.5)) );
		
	} 
	
	m = clamp(m, 0., 1.);
	
	float m2 = smooth_curve_use == 1? curveEval(smooth_curve, smooth_amount, m) : smoothstep(0., 1., m);
	m = mix(m, m2, smt);
	
	gl_FragColor = mix(c1, c2, m);
}
