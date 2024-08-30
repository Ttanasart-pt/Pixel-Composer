//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float w_curve[1024];
uniform int   w_amount;

uniform float r_curve[1024];
uniform int   r_amount;

uniform float g_curve[1024];
uniform int   g_amount;

uniform float b_curve[1024];
uniform int   b_amount;

uniform float a_curve[1024];
uniform int   a_amount;

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

float curveEval(in float[1024] curve, in int amo, in float _x) {
	
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

void main() {
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	
	col.r = curveEval(r_curve, r_amount, col.r);
	col.g = curveEval(g_curve, g_amount, col.g);
	col.b = curveEval(b_curve, b_amount, col.b);
	col.a = curveEval(a_curve, b_amount, col.a);
	
	float w = (col.r + col.g + col.b) / 3.;
	float wtarget = curveEval(w_curve, w_amount, w);
	
	col.rgb *= wtarget / w;
	
    gl_FragColor = col;
}
