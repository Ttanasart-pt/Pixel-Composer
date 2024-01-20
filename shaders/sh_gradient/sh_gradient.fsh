//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform vec2 center;
uniform vec2 dimension;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      radius;
uniform int       radiusUseSurf;
uniform sampler2D radiusSurf;

uniform vec2      shift;
uniform int       shiftUseSurf;
uniform sampler2D shiftSurf;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform int type;
uniform int gradient_loop;
uniform int uniAsp;

float sca;

#region ////////////////////////////////////////// GRADIENT BEGIN //////////////////////////////////////////

#define GRADIENT_LIMIT 128
uniform int   gradient_blend;
uniform vec4  gradient_color[GRADIENT_LIMIT];
uniform float gradient_time[GRADIENT_LIMIT];
uniform int   gradient_keys;

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
	vec4 col     = vec4(0.);
	float _ptime = 0.;
	
	for(int i = 0; i < GRADIENT_LIMIT; i++) {
		if(i >= gradient_keys) {
			col = gradient_color[i - 1];
			break;
		}
		
		float _time = gradient_time[i];
		_time = 0.5 + (_time - 0.5) * sca;
		
		if(_time == prog) {
			col = gradient_color[i];
			break;
		} else if(_time > prog) {
			if(i == 0) 
				col = gradient_color[i];
			else {
				float t = (prog - _ptime) / (_time - _ptime);
				if(gradient_blend == 0)
					col = mix(gradient_color[i - 1], gradient_color[i], t);
				else if(gradient_blend == 1)
					col = gradient_color[i - 1];
				else if(gradient_blend == 2)
					col = vec4(hsvMix(gradient_color[i - 1].rgb, gradient_color[i].rgb, t), 1.);
			}
			break;
		}
		
		_ptime = _time;
	}
	
	return col;
}

#endregion ////////////////////////////////////////// GRADIENT END //////////////////////////////////////////

void main() {
	#region params
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
		
		float rad = radius.x;
		if(radiusUseSurf == 1) {
			vec4 _vMap = texture2D( radiusSurf, v_vTexcoord );
			rad = mix(radius.x, radius.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		rad *= sqrt(2.);
		
		float shf = shift.x;
		if(shiftUseSurf == 1) {
			vec4 _vMap = texture2D( shiftSurf, v_vTexcoord );
			shf = mix(shift.x, shift.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		sca = scale.x;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	float prog = 0.;
	if(type == 0) {
		prog = .5 + (v_vTexcoord.x - center.x) * cos(ang) - (v_vTexcoord.y - center.y) * sin(ang);
		
	} else if(type == 1) {
		vec2 asp = dimension / dimension.y;
		
		if(uniAsp == 0) prog = distance(v_vTexcoord, center) / rad;
		else            prog = distance(v_vTexcoord * asp, center * asp) / rad;
		
	} else if(type == 2) {
		vec2  _p = v_vTexcoord - center;
		float _a = atan(_p.y, _p.x) + ang;
		prog = (_a - floor(_a / TAU) * TAU) / TAU;
		
	}
	
	prog += shf;
	
	if(gradient_loop == 1) { 
		prog = abs(prog);
		if(prog > 1.)
			prog = prog == floor(prog)? 1. : fract(prog);
	}
	
	vec4 col = gradientEval(prog);
	gl_FragColor = vec4(col.rgb, col.a * texture2D( gm_BaseTexture, v_vTexcoord ).a);
}
