varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define BATCH_SIZE 128

uniform int mode;
uniform vec2 range;
uniform float number[BATCH_SIZE];

#region ////////////////////////////////////////// GRADIENT BEGIN //////////////////////////////////////////

#define GRADIENT_LIMIT 128
uniform int gradient_blend;
uniform vec4 gradient_color[GRADIENT_LIMIT];
uniform float gradient_time[GRADIENT_LIMIT];
uniform int gradient_keys;
uniform int       gradient_use_map;
uniform vec4      gradient_map_range;
uniform sampler2D gradient_map;

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
}

#endregion ////////////////////////////////////////// GRADIENT END //////////////////////////////////////////

void main() {
	vec2 px = v_vTexcoord;
	px.x *= float(BATCH_SIZE);
	float value = number[int(px.x)];
	float grey  = (value - range[0]) / (range[1] - range[0]);
	
	gl_FragColor = vec4(0.);
	
	if(mode == 0)
	    gl_FragColor = vec4(vec3(grey), 1.);
	else if(mode == 1)
		gl_FragColor = gradientEval(grey);
	
}
