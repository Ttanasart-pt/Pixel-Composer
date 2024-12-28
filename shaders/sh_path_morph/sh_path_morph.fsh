#define PI  3.14159265359

#ifdef _YY_HLSL11_ 
	#define CURVE_MAX 1024
#else 
	#define CURVE_MAX 512
#endif

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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

float eval_curve_segment_t(in float _y0, in float ax0, in float ay0, in float bx1, in float by1, in float _y1, in float prog) {
	return _y0 * pow(1. - prog, 3.) + 
		   ay0 * 3. * pow(1. - prog, 2.) * prog + 
		   by1 * 3. * (1. - prog) * pow(prog, 2.) + 
		   _y1 * pow(prog, 3.);
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
	
	int   _shf   = amo - int(floor(float(amo) / 6.) * 6.);
	int   _segs  = (amo - _shf) / 6 - 1;
	float _shift = _shf > 0? curve[0] : 0.;
	float _scale = _shf > 1? curve[1] : 1.;
	
	_x = _x / _scale - _shift;
	_x = clamp(_x, 0., 1.);
	
	for( int i = 0; i < _segs; i++ ) {
		int ind = _shf + i * 6;
		float _x0 = curve[ind + 2];
		float _y0 = curve[ind + 3];
	  //float bx0 = _x0 + curve[ind + 0];
	  //float by0 = _y0 + curve[ind + 1];
		float ax0 = _x0 + curve[ind + 4];
		float ay0 = _y0 + curve[ind + 5];
		
		float _x1 = curve[ind + 6 + 2];
		float _y1 = curve[ind + 6 + 3];
		float bx1 = _x1 + curve[ind + 6 + 0];
		float by1 = _y1 + curve[ind + 6 + 1];
	  //float ax1 = _x1 + curve[ind + 6 + 4];
	  //float ay1 = _y1 + curve[ind + 6 + 5];
		
		if(_x < _x0) continue;
		if(_x > _x1) continue;
		
		return eval_curve_segment_x(_y0, ax0, ay0, bx1, by1, _y1, (_x - _x0) / (_x1 - _x0));
	}
	
	return curve[0];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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

float tsign (in vec2 p1, in vec2 p2, in vec2 p3) { return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y); }

bool pointInTriangle(in vec2 p, in vec2 t0, in vec2 t1, in vec2 t2) {
    float d1 = tsign(p, t0, t1);
    float d2 = tsign(p, t1, t2);
    float d3 = tsign(p, t2, t0);
	
    bool has_neg = (d1 < 0.) || (d2 < 0.) || (d3 < 0.);
    bool has_pos = (d1 > 0.) || (d2 > 0.) || (d3 > 0.);

    return !(has_neg && has_pos);
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
    	float ma    = 99999.;
    	float index = 0.;
    	bool  infr  = false;
    	a = 0.;
    	
    	for(int i = 1; i < subdivision; i++) {
	        pF1 = point1[i];
	        pT1 = point2[i];
	        
	        vec2 f = pointToLine(px, pF0, pF1);
	        vec2 t = pointToLine(px, pT0, pT1);
	        
	        if(intersect(px, pF0, pF1) && f.x >= px.x) inFrom = !inFrom;
	        if(intersect(px, pT0, pT1) && t.x >= px.x) inTo   = !inTo;
	        
	        bool inRegion = pointInTriangle(px, pF0, pF1, pT0) || pointInTriangle(px, pF1, pT0, pT1);
	        
	        pF0 = pF1;
        	pT0 = pT1;
	        	
	        if(!inRegion) continue;
	        
	        float _f = distance(px, f);
	        float _t = distance(px, t);
	        
	        a = max(a, _f / (_f + _t));
	        
	        infr = true;
	    }
	    
	    if(infr) inFrom = true;
    }
    
    if(clip == 1) {
	         if( inTo)   a = 1.;
	    else if(!inFrom) a = 0.;
    }
    a = curveEval(w_curve, w_amount, a);
    
    gl_FragColor = vec4(vec3(a), 1.);
}
