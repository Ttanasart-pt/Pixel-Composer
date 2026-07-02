#pragma use(curve)
#region -- curve -- [1780117484.3465736]

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
        
        if(_x <= curve[curve_offset + 2]) return curve[curve_offset + 3];
        if(_x >= curve[curve_offset + _segs * 6 + 2]) return curve[curve_offset + _segs * 6 + 3];

        if(_type == 0.) { // interpolated
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

        } else if(_type == 1.) { // step
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
        if(_min == 0. && _max == 0.) {
            _min = 0.;
            _max = 1.;
        }

        float _y = _curveEval(curve, amo, _x);
        return mix(_min, _max, _y);
    }

#endregion -- curve --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;

uniform vec2 dimension;

uniform sampler2D original;

uniform float dripDirection;
uniform vec2  dripDistance;
uniform vec2  dripThreshold;

uniform vec2  thickness;
uniform float thickness_curve[CURVE_MAX];
uniform int   thickness_amount;

uniform int   dripping;
uniform float dripFreq;
uniform vec2  dripAmpli;
uniform float dripAmpli_curve[CURVE_MAX];
uniform int   dripAmpli_amount;

uniform float dripPhase;
uniform float dripTime;

#define PI 3.14159265359
#define TAU 6.283185307179586

float random( in vec2 st ) { return fract(sin(dot(st, vec2(12.9898, 78.233 + seed / 10000.))) * 43758.5453123); }
vec2 random2( in vec2 st ) { return fract(sin(vec2(dot(st, vec2(127.1, 311.7 + seed / 10000.)), 
                                                   dot(st, vec2(269.5 + seed / 10000., 183.3)))) * 43758.5453); }

void main() {
	vec2 tx = 1. / dimension;
	
	vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
	vec4 colr = base;
	
	float maxDrip = max(dripDistance.x, dripDistance.y);
	float rota    = radians(dripDirection);
	
	vec2  dripVec  = vec2(cos(rota), -sin(rota));
	float dripStep = maxDrip * dimension.x;
	
	gl_FragColor = vec4(0.);
	
	if(base.a > 0.) {
		vec4 edge = texture2D(gm_BaseTexture, v_vTexcoord + dripVec * tx);
		if(edge.a == 0.) gl_FragColor = texture2D(original, v_vTexcoord);
		return;
	}
	
	bool  isDrip  = false;
	float dripLen = 0.;
	vec2  dripPos;
	vec4  dripCol;
	
	float samThk  = 0.;
	float currThk = samThk;
	float currThr = 0.;
	float currDis = 0.;
	
	for(float i = 0.; i < dripStep; i++) {
		vec2  _dripPos = v_vTexcoord - dripVec * i * tx;
		vec4  _dripCol = texture2D(gm_BaseTexture, _dripPos);
		
		float _samThk  = _dripCol.r * _dripCol.a;
		vec2  dripCel  = _dripCol.gb;
		
		float _thres   = mix(dripThreshold.x, dripThreshold.y, random(dripCel + 0.2683));
		float _currThk = mix(thickness.x,     thickness.y,     random(dripCel + 0.9836));
		float _currDis = mix(dripDistance.x,  dripDistance.y,  random(dripCel + 0.6985));
		
		if(_samThk < 0.) break;
		if(_samThk > _thres && _samThk > samThk && _samThk > _currThk) {
			isDrip  = true;
			dripLen = 1. - i / dripStep * (maxDrip / _currDis);
			
			dripPos = _dripPos;
			dripCol = _dripCol;
			samThk  = _samThk;
			
			currThk = _currThk;
			currThr = _thres;
			currDis = _currDis;
		}
	}
	
	vec4  origColor = texture2D(original, dripPos);
	
	if(!isDrip || dripLen < 0. || dripLen > 1.) {
		gl_FragColor = vec4(origColor.rgb, 0.);
		return;
	}
	
	float dripPrg   = dripLen;
	float dripCurve = curveEval(thickness_curve, thickness_amount, 1. - dripPrg);
	
	float thkInv    = 1. - currThk;
	float samThkNrm = (samThk - thkInv) / currThk;
	float dripDens  = samThkNrm * 2. * dripCurve;
	
	vec2 dripCel = dripCol.gb;
	
	if(dripping == 1) {
		float dripProg  = dripPhase + dripPrg * dripFreq + dripTime;
		      dripProg += random(dripCel);
		
		float dripAmp  = curveEval(dripAmpli_curve, dripAmpli_amount, 1. - dripPrg) * mix(dripAmpli.x, dripAmpli.y, random(dripCel + 0.1651));
		float dripAnim = 1. - (sin(dripProg * TAU) + 1.) / 2. * dripAmp;
		
		dripDens *= dripAnim;
	}
	
	float dripDraw  = step(currThr, dripDens);
	
	gl_FragColor = vec4(origColor.rgb, dripDraw);
}