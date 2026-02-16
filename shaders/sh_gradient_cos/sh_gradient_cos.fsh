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
// Created by inigo quilez

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 center;
uniform vec2 dimension;

uniform float angle;
uniform float radius;
uniform float shift;
uniform float scale;

uniform int type;
uniform int uniAsp;

uniform vec2 cirScale;

uniform vec3 co_a;
uniform vec3 co_a_max;
uniform int  co_a_use;
uniform sampler2D co_a_map;

uniform vec3 co_b;
uniform vec3 co_b_max;
uniform int  co_b_use;
uniform sampler2D co_b_map;

uniform vec3 co_c;
uniform vec3 co_c_max;
uniform int  co_c_use;
uniform sampler2D co_c_map;

uniform vec3 co_d;
uniform vec3 co_d_max;
uniform int  co_d_use;
uniform sampler2D co_d_map;

uniform float pCurve_curve[CURVE_MAX];
uniform int   pCurve_curve_use;
uniform int   pCurve_amount;

#define TAU 6.283185307179586

vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b * cos( 6.28318 * (c * t + d) );
}

float sLength(vec2 p) { return max(abs(p.x), abs(p.y)); }
float dLength(vec2 p) { return (abs(p.x) + abs(p.y));   }

void main() {
	#region params
		vec3 _a = co_a;
		if(co_a_use == 1) {
			vec4 _vMap = texture2D( co_a_map, v_vTexcoord );
			_a = mix(co_a, co_a_max, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		vec3 _b = co_b;
		if(co_b_use == 1) {
			vec4 _vMap = texture2D( co_b_map, v_vTexcoord );
			_b = mix(co_b, co_a_max, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		vec3 _c = co_c;
		if(co_c_use == 1) {
			vec4 _vMap = texture2D( co_c_map, v_vTexcoord );
			_c = mix(co_c, co_a_max, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		vec3 _d = co_d;
		if(co_d_use == 1) {
			vec4 _vMap = texture2D( co_d_map, v_vTexcoord );
			_d = mix(co_d, co_a_max, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = radians(angle);
		float rad = radius * sqrt(2.);
		float shf = shift;
		float sca = scale;
	#endregion
	
	vec2  vtx  = getUV(v_vTexcoord);
	vec2  asp  = dimension / dimension.y;
	vec2  cent = center / dimension;
	float prog = 0.;
	mat2  rot  = mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	
	if(type == 0) { // linear
		prog = .5 + (vtx.x - cent.x) * cos(ang) - (vtx.y - cent.y) * sin(ang);
		
	} else if(type == 1) { // circular
		vec2 _asp = uniAsp == 0? vec2(1.) : asp;
		prog = length((vtx - cent) * _asp / cirScale) / rad;
		
	} else if(type == 2) { // radial
		vec2  _p = vtx - cent;
		if(uniAsp == 1) _p *= asp;
		
		float _a = atan(_p.y, _p.x) + ang;
		prog = (_a - floor(_a / TAU) * TAU) / TAU;
		
	} else if(type == 3) { // diamond
		vec2 _asp = uniAsp == 0? vec2(1.) : asp;
		prog = dLength((vtx - cent) * rot * _asp / cirScale) / rad;
		
	} 
	
	prog = (prog + shf - 0.5) / sca + 0.5;
	if(pCurve_curve_use == 1) prog = curveEval(pCurve_curve, pCurve_amount, prog);
	
	vec3 col = pal(prog, _a, _b, _c, _d);
	gl_FragColor = vec4(col, 1.);
}