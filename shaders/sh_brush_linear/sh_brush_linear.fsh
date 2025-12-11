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

const float PI  = 3.14159265;
const float ATR = PI / 180.;

uniform int   iteration;

uniform vec2      brushLen;
uniform int       brushLenUseSurf;
uniform sampler2D brushLenSurf;

uniform vec2      brushAtn;
uniform int       brushAtnUseSurf;
uniform sampler2D brushAtnSurf;
uniform float     brushAtn_curve[CURVE_MAX];
uniform int       brushAtn_curve_use;
uniform int       brushAtn_amount;

uniform vec2      brushRot;
uniform int       brushRotUseSurf;
uniform sampler2D brushRotSurf;

uniform vec2  dimension;
uniform float seed;

vec4  getCol( vec2 pos ) { return        texture2D( gm_BaseTexture, pos / dimension);  }
float getD(   vec2 pos ) { return length(texture2D( gm_BaseTexture, pos / dimension)); }

vec2 grad( vec2 pos, float delta) {
    vec2  e = vec2(1., 0.) * delta;
    float o = getD(pos);
    return vec2(getD(pos + e.xy) - o, getD(pos + e.yx) - o) / delta;
}

void main() {
    float len = brushLen.x;
	if(brushLenUseSurf == 1) {
		vec4 _vMap = texture2D( brushLenSurf, v_vTexcoord );
		len = mix(brushLen.x, brushLen.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float atn = brushAtn.x;
	if(brushAtnUseSurf == 1) {
		vec4 _vMap = texture2D( brushAtnSurf, v_vTexcoord );
		atn = mix(brushAtn.x, brushAtn.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float rot = brushRot.x;
	if(brushRotUseSurf == 1) {
		vec4 _vMap = texture2D( brushRotSurf, v_vTexcoord );
		rot = mix(brushRot.x, brushRot.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec2  pos = v_vTexcoord * dimension;
    float r   = 1.;
    float acc = 0.;
    vec4  res = vec4(0.);
    vec2  dir;
    
    for(int i = 0; i < iteration; i++) {
        dir  = grad(pos, len) + vec2(1) * 0.001;
        pos += 2. * normalize(mix(dir, dir.yx * vec2(1, -1), rot));
        
        float _atc = 1.;
        if(brushAtn_curve_use == 1) 
        	_atc = curveEval(brushAtn_curve, brushAtn_amount, float(i) / float(iteration));
        
        acc += r * _atc;
        res += getCol(pos) * r * _atc;
        r   *= atn;
    }
    
    res.xyz /= acc;
    
    gl_FragColor = res;
}
