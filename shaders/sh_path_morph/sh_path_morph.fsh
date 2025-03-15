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

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  subdivision;
uniform int  clip;
uniform int  matchIndex;

uniform float w_curve[CURVE_MAX];
uniform int   w_amount;

uniform vec2 point1[1024];
uniform vec2 point2[1024];

#define PI  3.14159265359

vec2 pointToLine(in vec2 p, in vec2 l0, in vec2 l1) {
	float l2 = pow(l0.x - l1.x, 2.) + pow(l0.y - l1.y, 2.);
	if (l2 == 0.) return l0;
	  
	float t = ((p.x - l0.x) * (l1.x - l0.x) + (p.y - l0.y) * (l1.y - l0.y)) / l2;
	t = clamp(t, 0., 1.);
	
	return mix(l0, l1, t);
}

float pointOnLine(in vec2 p, in vec2 l0, in vec2 l1) {
	float l2 = pow(l0.x - l1.x, 2.) + pow(l0.y - l1.y, 2.);
	if (l2 == 0.) return 0.;
	  
	float t = ((p.x - l0.x) * (l1.x - l0.x) + (p.y - l0.y) * (l1.y - l0.y)) / l2;
	return t;
}

bool pointInTriangle(in vec2 p, in vec2 t0, in vec2 t1, in vec2 t2) {
    float d1 = (p.x - t1.x) * (t0.y - t1.y) - (t0.x - t1.x) * (p.y - t1.y);
    float d2 = (p.x - t2.x) * (t1.y - t2.y) - (t1.x - t2.x) * (p.y - t2.y);
    float d3 = (p.x - t0.x) * (t2.y - t0.y) - (t2.x - t0.x) * (p.y - t0.y);
	
    return (d1 >= 0. && d2 >= 0. && d3 >= 0.) || (d1 <= 0. && d2 <= 0. && d3 <= 0.);
}

bool intersect(in vec2 p, in vec2 l0, in vec2 l1) {
	float s0 = sign(p.y - l0.y);
	float s1 = sign(l1.y - p.y);
	bool ins = s0 == s1;
	return ins;
}

void main() {
    vec2 px = v_vTexcoord * dimension;
    
    float dF = dimension.x + dimension.y;
    vec2  pF = point1[0];
    vec2 pF0 = point1[0], pF1;
    
    float dT = dimension.x + dimension.y;
    vec2  pT = point2[0];
    vec2 pT0 = point2[0], pT1;
    
    bool inFrom = false;
    bool inTo   = false;
    float a = 0.;
    
    if(matchIndex == 0) {
	    for(int i = 1; i < subdivision; i++) {
	        pF1 = point1[i];
	        pT1 = point2[i];
	        
	        vec2 f = pointToLine(px, pF0, pF1);
	        vec2 t = pointToLine(px, pT0, pT1);
	        
	        if(intersect(px, pF0, pF1) && f.x >= px.x) inFrom = !inFrom;
	        if(intersect(px, pT0, pT1) && t.x >= px.x) inTo   = !inTo;
	        
	        float _f = distance(px, f);
	        float _t = distance(px, t);
	        
	        if(_f <= dF) {
	            dF = _f;
	            pF =  f;
	        }
	        
	        if(_t <= dT) {
	            dT = _t;
	            pT =  t;
	        }
	        
	        pF0 = pF1;
	        pT0 = pT1;
	    }
	    
	    a = dF / (dF + dT);
    	
    } else {
    	a = 0.;
    	
    	float d1, d2, d3;
    	
    	for(int i = 1; i < subdivision; i++) {
	        pF1 = point1[i];
	        pT0 = point2[0];
	        
	        vec2   f = pointToLine(px, pF0, pF1);
	        float _f = distance(px, f);
	        
	        float pxx_f1x = px.x - pF1.x;
	        float pxy_f1y = px.y - pF1.y;
	        float pxx_f0x = px.x - pF0.x;
	        float pxy_f0y = px.y - pF0.y;
	        float f0y_f1y = pF0.y - pF1.y;
	        float f0x_f1x = pF0.x - pF1.x;
	        float dd1     = pxx_f1x * f0y_f1y - f0x_f1x * pxy_f1y;
	        
	        for(int j = 1; j < subdivision; j++) {
		        pT1 = point2[j];
		        
		        d1 = dd1;
			    d2 = (px.x - pT0.x) * (pF1.y - pT0.y) - (pF1.x - pT0.x) * (px.y - pT0.y);
			    d3 = pxx_f0x * (pT0.y - pF0.y) - (pT0.x - pF0.x) * pxy_f0y;
			    bool i1 = (d1 >= 0. && d2 >= 0. && d3 >= 0.) || (d1 <= 0. && d2 <= 0. && d3 <= 0.);
		        
		        d1 = (px.x - pT0.x) * (pF1.y - pT0.y) - (pF1.x - pT0.x) * (px.y - pT0.y);
				d2 = (px.x - pT1.x) * (pT0.y - pT1.y) - (pT0.x - pT1.x) * (px.y - pT1.y);
				d3 = pxx_f1x * (pT1.y - pF1.y) - (pT1.x - pF1.x) * pxy_f1y;
			    bool i2 = (d1 >= 0. && d2 >= 0. && d3 >= 0.) || (d1 <= 0. && d2 <= 0. && d3 <= 0.);
			    
		        bool inRegion = i1 || i2;
		        	
		        if(!inRegion) {
		        	pT0 = pT1;
		        	continue;
		        }
		        
		        vec2   t = pointToLine(px, pT0, pT1);
		        float _t = distance(px, t);
		        a = max(a, _f / (_f + _t));
		        
		        pT0 = pT1;
		        inFrom = true;
		    }
		    
		    pF0 = pF1;
    	}
    	
	    pT0 = point2[0];
	    for(int i = 1; i < subdivision; i++) {
	        pT1 = point2[i];
	        vec2 t = pointToLine(px, pT0, pT1);
	        if(intersect(px, pT0, pT1) && t.x >= px.x) inTo   = !inTo;
	        pT0 = pT1;
	    }
    }
    
    if(clip == 1) {
	         if( inTo)   a = 1.;
	    else if(!inFrom) a = 0.;
    }
    a = curveEval(w_curve, w_amount, a);
    
    gl_FragColor = vec4(vec3(a), 1.);
}
