//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359

uniform vec2  dimension;
uniform vec2  position;
uniform int   blend;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      randomAmount;
uniform int       randomAmountUseSurf;
uniform sampler2D randomAmountSurf;

uniform vec2      ratio;
uniform int       ratioUseSurf;
uniform sampler2D ratioSurf;

uniform vec4  color0;
uniform vec4  color1;

#define GRADIENT_LIMIT 128
uniform int   gradient_use;
uniform int   gradient_blend;
uniform vec4  gradient_color[GRADIENT_LIMIT];
uniform float gradient_time[GRADIENT_LIMIT];
uniform int   gradient_keys;
uniform int       gradient_use_map;
uniform vec4      gradient_map_range;
uniform sampler2D gradient_map;

vec3 rgb2hsv(vec3 c) { #region
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 0.0000000001;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
} #endregion

vec3 hsv2rgb(vec3 c) { #region
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
} #endregion

float hueDist(float a0, float a1, float t) { #region
	float da = fract(a1 - a0);
    float ds = fract(2. * da) - da;
    return a0 + ds * t;
} #endregion

vec3 hsvMix(vec3 c1, vec3 c2, float t) { #region
	vec3 h1 = rgb2hsv(c1);
	vec3 h2 = rgb2hsv(c2);
	
	vec3 h = vec3(0.);
	h.x = h.x + hueDist(h1.x, h2.x, t);
	h.y = mix(h1.y, h2.y, t);
	h.z = mix(h1.z, h2.z, t);
	
	return hsv2rgb(h);
} #endregion

vec4 gradientEval(in float prog) { #region
	if(gradient_use_map == 1) {
		vec2 samplePos = mix(gradient_map_range.xy, gradient_map_range.zw, prog);
		return texture2D( gradient_map, samplePos );
	}
	
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
} #endregion

float random (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); }

void main() { #region
	#region params
		float amo = amount.x;
		if(amountUseSurf == 1) {
			vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
			amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
		
		float rnd = randomAmount.x;
		if(randomAmountUseSurf == 1) {
			vec4 _vMap = texture2D( randomAmountSurf, v_vTexcoord );
			rnd = mix(randomAmount.x, randomAmount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float rat = ratio.x;
		if(ratioUseSurf == 1) {
			vec4 _vMap = texture2D( ratioSurf, v_vTexcoord );
			rat = mix(ratio.x, ratio.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	vec2  pos     = v_vTexcoord - position;
	float aspect  = dimension.x / dimension.y;
	float prog    = pos.x * aspect * cos(ang) - pos.y * sin(ang);
    float _a      = 1. / amo;
	
	float slot    = floor(prog / _a);
	float ground  = (slot + (random(vec2(slot + 0.)) * 2. - 1.) * rnd * 0.5 + 0.) * _a;
	float ceiling = (slot + (random(vec2(slot + 1.)) * 2. - 1.) * rnd * 0.5 + 1.) * _a;
	float _s      = (prog - ground) / (ceiling - ground);
	
	if(gradient_use == 0) {
		if(blend == 0)	gl_FragColor = _s > rat? color0 : color1;
		else			gl_FragColor = vec4(vec3(sin(_s * 2. * PI) * 0.5 + 0.5), 1.);
	} else {
		if(_s > rat)	gl_FragColor = gradientEval(random(vec2(slot)));
		else			gl_FragColor = gradientEval(random(vec2(slot + 1.)));
	}
} #endregion
