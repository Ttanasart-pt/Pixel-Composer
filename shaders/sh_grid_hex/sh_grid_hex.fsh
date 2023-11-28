varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define GRADIENT_LIMIT 128

uniform vec2  dimension;
uniform vec2  position;
uniform vec2  scale;
uniform float angle;
uniform float thick;
uniform float seed;
uniform int   mode;
uniform int   aa;

uniform vec4  gapCol;
uniform int   gradient_use;
uniform int   gradient_blend;
uniform vec4  gradient_color[GRADIENT_LIMIT];
uniform float gradient_time[GRADIENT_LIMIT];
uniform int   gradient_keys;

#define PI 3.14159265359

float random (in vec2 st) {	return fract(sin(dot(st.xy + vec2(85.456034, 64.54065), vec2(12.9898, 78.233))) * (43758.5453123 + seed) ); }

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

float HexDist(vec2 p) { #region
	p = abs(p);
    
    float c = dot(p, normalize(vec2(1, 1.73)));
    c = max(c, p.x);
    
    return c;
} #endregion

vec4 HexCoords(vec2 uv) { #region
	vec2 r = vec2(1, sqrt(3.));
    vec2 h = r * .5;
    
    vec2 a = mod(uv,     r) - h;
    vec2 b = mod(uv - h, r) - h;
    
    vec2 gv = dot(a, a) < dot(b,b) ? a : b;
    
    float x = atan(gv.x, gv.y);
    float y = max(0., .5 - HexDist(gv));
    vec2 id = uv - gv;
    return vec4(x, y, id.x, id.y);
} #endregion

void main() { #region
	vec2 pos = (v_vTexcoord - position) * scale, _pos;
	float ratio = dimension.x / dimension.y;
	_pos.x = pos.x * ratio * cos(angle) - pos.y * sin(angle);
	_pos.y = pos.x * ratio * sin(angle) + pos.y * cos(angle);
	
    vec4 hc = HexCoords(_pos);
	vec4 colr;
	
	if(mode == 1) {
		gl_FragColor = vec4(vec3(hc.y), 1.0);
		return;
	}
	
	if(mode == 0) {
		vec2 uv = abs(hc.zw) / scale;
		uv.x = fract(uv.x);
		uv.y = clamp(uv.y, 0., 1.);
		
		float tileY = floor(scale.y * 4. / 3.);
		uv.y = mod(floor(uv.y * (tileY + 1.)), tileY) / tileY;
		
		colr = vec4(gradientEval(random(uv)).rgb, 1.);
	} else if(mode == 2) {
		vec2 uv = hc.xy;
		uv.x = (uv.x + PI / 2.) / PI;
		
		colr = texture2D( gm_BaseTexture, uv );
	} else if(mode == 3) {
		vec2 uv = clamp(abs(hc.zw) / scale, 0., 1.);
		colr = texture2D( gm_BaseTexture, uv );
	}
	
	float _aa = 3. / max(dimension.x, dimension.y);
	gl_FragColor = mix(gapCol, colr, aa == 1? smoothstep(thick - _aa, thick, hc.y) : step(thick, hc.y));
} #endregion