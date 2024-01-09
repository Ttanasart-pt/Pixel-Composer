//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define GRADIENT_LIMIT 128

uniform float seed;
uniform float strength;
uniform float dist;
uniform int useMap;
uniform sampler2D strengthMap;

uniform int gradient_blend;
uniform vec4 gradient_color[GRADIENT_LIMIT];
uniform float gradient_time[GRADIENT_LIMIT];
uniform int gradient_keys;

uniform float alpha_curve[64];
uniform int   curve_amount;
uniform float randomAmount;

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
	
	int _newRep = 8;
	
	for(int i = 0; i < _newRep; i++) {
		float slope = (9. * ax0 - 9. * bx1 + 3.) * _xt * _xt
					+ (-12. * ax0 + 6. * bx1) * _xt
					+ 3. * ax0;
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

float curveEval(in float _x) {
	_x = clamp(_x, 0., 1.);
	int segments = curve_amount / 6 - 1;
	
	for( int i = 0; i < segments; i++ ) {
		int ind = i * 6;
		float _x0 = alpha_curve[ind + 2];
		float _y0 = alpha_curve[ind + 3];
	  //float bx0 = _x0 + alpha_curve[ind + 0];
	  //float by0 = _y0 + alpha_curve[ind + 1];
		float ax0 = _x0 + alpha_curve[ind + 4];
		float ay0 = _y0 + alpha_curve[ind + 5];
		
		float _x1 = alpha_curve[ind + 6 + 2];
		float _y1 = alpha_curve[ind + 6 + 3];
		float bx1 = _x1 + alpha_curve[ind + 6 + 0];
		float by1 = _y1 + alpha_curve[ind + 6 + 1];
	  //float ax1 = _x1 + alpha_curve[ind + 6 + 4];
	  //float ay1 = _y1 + alpha_curve[ind + 6 + 5];
		
		if(_x < _x0) continue;
		if(_x > _x1) continue;
		
		return eval_curve_segment_x(_y0, ax0, ay0, bx1, by1, _y1, (_x - _x0) / (_x1 - _x0));
	}
	
	return alpha_curve[0];
}

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 0.0000000001;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
 }

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float hueDist(float a0, float a1, float t) {
	float da = fract(a1 - a0);
    float ds = fract(2. * da) - da;
    return a0 + ds * t;
}

vec3 hsvMix(vec3 c1, vec3 c2, float t) {
	vec3 h1 = rgb2hsv(c1);
	vec3 h2 = rgb2hsv(c2);
	
	vec3 h = vec3(0.);
	h.x = h.x + hueDist(h1.x, h2.x, t);
	h.y = mix(h1.y, h2.y, t);
	h.z = mix(h1.z, h2.z, t);
	
	return hsv2rgb(h);
}

vec4 gradientEval(in float prog) {
	vec4 col = vec4(0.);
	
	for(int i = 0; i < GRADIENT_LIMIT; i++) {
		if(gradient_time[i] == prog) {
			col = gradient_color[i];
			break;
		} else if(gradient_time[i] > prog) {
			if(i == 0) 
				col = gradient_color[i];
			else {
				float t = (prog - gradient_time[i - 1]) / (gradient_time[i] - gradient_time[i - 1]);
				if(gradient_blend == 0)
					col = mix(gradient_color[i - 1], gradient_color[i], t);
				else if(gradient_blend == 1)
					col = gradient_color[i - 1];
				else if(gradient_blend == 2)
					col = vec4(hsvMix(gradient_color[i - 1].rgb, gradient_color[i].rgb, t), 1.);
			}
			break;
		}
		if(i >= gradient_keys - 1) {
			col = gradient_color[gradient_keys - 1];
			break;
		}
	}
	
	return col;
}

float frandom (in vec2 st, in float _seed) {
	float f = fract(sin(dot(st.xy, vec2(12.9898, 78.233)) * mod(15.15 + seed, 32.156 + _seed) * 12.588) * 43758.5453123);
    return mix(-1., 1., f);
}

vec2 vrandom (in vec2 st) {
    return vec2(frandom(st, 165.874), frandom(st, 98.601));
}

void main() {
	vec2 _pos = v_vTexcoord;
	float str = strength;
	
	vec2 _vec = vrandom(_pos) * str * dist;
	
	if(useMap == 1) {
		vec4 _map = texture2D( strengthMap, _pos);
		_vec.x *= _map.r;
		_vec.y *= _map.g;
		str *= dot(_map.rg, _map.rg);
	}
	
	str += frandom(_pos, 12.01) * abs(.1) * str;
	
	vec2 _new_pos = _pos - _vec;
	vec4 _col = vec4(0.);
	
	if(_new_pos.x >= 0. && _new_pos.x <= 1. && _new_pos.y >= 0. && _new_pos.y <= 1.) {
		_col = texture2D( gm_BaseTexture, _new_pos );
		vec4 cc = gradientEval(str + frandom(_pos, 1.235) * randomAmount);
		_col.rgb *= cc.rgb;
		_col.a   *= cc.a   * curveEval(str + frandom(_pos, 2.984) * randomAmount);
	}
	
    gl_FragColor = _col;
}

