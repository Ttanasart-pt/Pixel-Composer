//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int gradient_use;
uniform int gradient_blend;
uniform vec4 gradient_color[16];
uniform float gradient_time[16];
uniform int gradient_keys;

uniform vec2 dimension;
uniform vec2 position;
uniform float angle;
uniform float amount;
uniform float rand;
uniform int blend;

#define PI 3.14159265359

float random (in vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
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
	
	for(int i = 0; i < 16; i++) {
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

void main() {
	vec2 pos = v_vTexcoord - position;
	float ratio = dimension.x / dimension.y;
	float prog = pos.x * ratio * cos(angle) - pos.y * sin(angle);
    float _a   = 1. / amount;
	
	float slot = floor(prog / _a);
	float ground  = (slot + (random(vec2(slot + 0.)) * 2. - 1.) * rand * 0.5 + 0.) * _a;
	float ceiling = (slot + (random(vec2(slot + 1.)) * 2. - 1.) * rand * 0.5 + 1.) * _a;
	float _s   = (prog - ground) / (ceiling - ground);
	
	if(gradient_use == 0) {
		if(blend == 0) {
			if(_s > .5)
				gl_FragColor = vec4(vec3(0.), 1.);
			else
				gl_FragColor = vec4(vec3(1.), 1.);
		} else
			gl_FragColor = vec4(vec3(sin(_s * 2. * PI) * 0.5 + 0.5), 1.);
	} else {
		if(_s > .5)
			gl_FragColor = vec4(gradientEval(random(vec2(slot))).rgb, 1.);
		else
			gl_FragColor = vec4(gradientEval(random(vec2(slot + 1.))).rgb, 1.);
	}
}
