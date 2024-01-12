// Pytagorean tiling 
// gelami Pythagorean Square Tiling 2

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define GRADIENT_LIMIT 128

uniform vec2  dimension;
uniform vec2  position;
uniform float seed;
uniform int   mode;
uniform int   aa;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      thick;
uniform int       thickUseSurf;
uniform sampler2D thickSurf;

uniform vec4  gapCol;
uniform int   gradient_use;
uniform int   gradient_blend;
uniform vec4  gradient_color[GRADIENT_LIMIT];
uniform float gradient_time[GRADIENT_LIMIT];
uniform int   gradient_keys;

uniform int   textureTruchet;
uniform float truchetSeed;
uniform float truchetThres;

uniform float phase;

#define PI  3.14159265359
#define TAU 6.28318530718

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

mat2 rot2D(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

vec3 sdBox( in vec2 p, in float b ) { #region
    vec2 d = abs(p) - b;
    return vec3( max(d.x, d.y), step(vec2(0), d) );
} #endregion

float round(float val) { return fract(val) >= 0.5? ceil(val) : floor(val); }

vec4 PytagoreanCoords(vec2 uv) { #region
	float a = radians(phase) / 4.;
    float q = mod(round(a / (TAU / 4.)), 2.);
    
    vec2 p = uv * 2.;
    
    p *= rot2D(a);
    
    vec2 p1 = fract(p) - 0.5;
    vec2 sp = sign(p1);
    vec2 p2 = (abs(p1) - 0.5) * sp;
    
    vec2 id = (p - p1) * 2.;
    
    p1 *= rot2D(-a);
    p2 *= rot2D(-a);
    
    vec2 sp2 = sign(p1);
    vec2 s   = abs(vec2(cos(a), sin(a))) * 0.5;
    
    vec3 d1 = sdBox(p1, s.x);
    vec3 d2 = sdBox(p2, s.y);
    
    float m  = q > 0.5 ? step(0., d1.x) : step(d2.x, 0.);
    float s1 = mod(ceil(abs((a - PI) / (PI / 4.))), 2.) * 2. - 1.;
    float s2 = q * 2. - 1.;
    float ss = s1 * s2 * 2.;
    
    id += sp * m;
    
    float m2 = clamp(sign(d1.x) + sign(d2.x), 0., 1.);
    
    id += d1.yz * sp2 * ss * m2;
    
    float size = m < 0.5 ? s.x : s.y;
    vec2  puv  = (p - id * 0.5) / size * rot2D(-a) * 0.5;
    
    vec2 dp = (0.5 - abs(puv)) * size;
    float d = min(dp.x, dp.y);
	
	return vec4(0., d, puv);
} #endregion

void main() { #region
	#region params
		vec2 sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
		
		float thk = thick.x;
		if(thickUseSurf == 1) {
			vec4 _vMap = texture2D( thickSurf, v_vTexcoord );
			thk = mix(thick.x, thick.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	thk = clamp(thk, 0., 1.);
	thk = pow(thk, 3.);
	
	vec2 pos = (v_vTexcoord - position) * sca, _pos;
	float ratio = dimension.x / dimension.y;
	_pos.x = pos.x * ratio * cos(ang) - pos.y * sin(ang);
	_pos.y = pos.x * ratio * sin(ang) + pos.y * cos(ang);
	
    vec4 hc = PytagoreanCoords(_pos);
	vec4 colr;
	
	if(mode == 1) {
		gl_FragColor = vec4(vec3(hc.y), 1.0);
		return;
	}
	
	if(mode == 0) {
		vec2 uv = abs(hc.zw) / sca;
		colr = gradientEval(random(uv));
	} else if(mode == 2) {
		vec2 uv = hc.zw + vec2(0.5, 0.5);
		
		if(textureTruchet == 1) { 
			float rx = random(hc.zw + truchetSeed / 100.);
			float ry = random(hc.zw + truchetSeed / 100. + vec2(0.4864, 0.6879));
			
			if(rx > truchetThres) uv.x = 1. - uv.x;
			if(ry > truchetThres) uv.y = 1. - uv.y;
		}
		
		colr = texture2D( gm_BaseTexture, uv );
	}
	
	float _aa = 3. / max(dimension.x, dimension.y);
	gl_FragColor = mix(gapCol, colr, aa == 1? smoothstep(thk - _aa, thk, hc.y) : step(thk, hc.y));
} #endregion