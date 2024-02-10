varying vec2 v_vTexcoord;
varying vec4 v_vColour;

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

uniform int   textureTruchet;
uniform float truchetSeed;
uniform float truchetThres;
uniform vec2  truchetAngle;

uniform float tileLength;

#define PI  3.14159265359
#define TAU 6.28318530718

float random (in vec2 st) {	return fract(sin(dot(st.xy + vec2(85.456034, 64.54065), vec2(12.9898, 78.233))) * (43758.5453123 + seed) ); }

#region //////////////////////////////////// GRADIENT ////////////////////////////////////
	#define GRADIENT_LIMIT 128
	
	uniform int		  gradient_blend;
	uniform vec4	  gradient_color[GRADIENT_LIMIT];
	uniform float	  gradient_time[GRADIENT_LIMIT];
	uniform int		  gradient_keys;
	uniform int       gradient_use_map;
	uniform vec4      gradient_map_range;
	uniform sampler2D gradient_map;

	vec3 rgb2oklab(vec3 c) { #region
		const mat3 kCONEtoLMS = mat3(                
	         0.4121656120,  0.2118591070,  0.0883097947,
	         0.5362752080,  0.6807189584,  0.2818474174,
	         0.0514575653,  0.1074065790,  0.6302613616);
	    
		c = pow(c, vec3(2.2));
		c = pow( kCONEtoLMS * c, vec3(1.0 / 3.0) );
		
		return c;
	} #endregion
	
	vec3 oklab2rgb(vec3 c) { #region
		const mat3 kLMStoCONE = mat3(
	         4.0767245293, -1.2681437731, -0.0041119885,
	        -3.3072168827,  2.6093323231, -0.7034763098,
	         0.2307590544, -0.3411344290,  1.7068625689);
        
		c = kLMStoCONE * (c * c * c);
		c = pow(c, vec3(1. / 2.2));
		
	    return c;
	} #endregion

	vec3 oklabMax(vec3 c1, vec3 c2, float t) { #region
		vec3 k1 = rgb2oklab(c1);
		vec3 k2 = rgb2oklab(c2);
		
		return oklab2rgb(mix(k1, k2, t));
	} #endregion 
	
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
					float a = mix(gradient_color[i - 1].a, gradient_color[i].a, t);
					
					if(gradient_blend == 0)
						col = mix(gradient_color[i - 1], gradient_color[i], t);
					else if(gradient_blend == 1)
						col = gradient_color[i - 1];
					else if(gradient_blend == 2)
						col = vec4(hsvMix(gradient_color[i - 1].rgb, gradient_color[i].rgb, t), a);
					else if(gradient_blend == 3)
						col = vec4(oklabMax(gradient_color[i - 1].rgb, gradient_color[i].rgb, t), a);
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
	
#endregion //////////////////////////////////// GRADIENT ////////////////////////////////////

float round(float val) { return fract(val) >= 0.5? ceil(val) : floor(val); }

vec4 HerringboneCoords(vec2 uv) { #region
	float scale = 20.;
	
	float xshifted = (uv.x - floor(uv.y)) * .5;
    float mask = fract(xshifted / tileLength) > .5 ? 1. : 0.;
    
    // apply mask
    if (mask > 0.) {  // shift down and rotate
        uv.x -= tileLength - 1.;
    	uv = uv.yx;
    }
	
    uv.x /= tileLength;
    uv.x -= floor(uv.y) / tileLength;
	vec2 id = floor(uv);
    uv = fract(uv);
	
	vec2   _uv = uv;
    float maxH = 1.;
    uv   = abs(uv - .5) * 2.;
	uv.x = uv.x * tileLength - tileLength + 1.;
    
    float h = 1. - max(uv.x, uv.y);
    h = min(h, maxH);
	
	return vec4(random(id), h / maxH, _uv);
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
	
	vec2 pos = (v_vTexcoord - position) * sca, _pos;
	float ratio = dimension.x / dimension.y;
	_pos.x = pos.x * ratio * cos(ang) - pos.y * sin(ang);
	_pos.y = pos.x * ratio * sin(ang) + pos.y * cos(ang);
	
    vec4 hc = HerringboneCoords(_pos);
	vec4 colr;
	
	if(mode == 1) {
		gl_FragColor = vec4(vec3(hc.y), 1.0);
		return;
	}
	
	if(mode == 0) {
		colr = gradientEval(hc.x);
	} else if(mode == 2) {
		vec2 uv = hc.zw;
		
		if(textureTruchet == 1) { 
			float rx = random(floor(hc.zw / sca) + truchetSeed / 1000.);
			float ry = random(floor(hc.zw / sca) + truchetSeed / 1000. + vec2(0.4864, 0.6879));
			
			if(rx > truchetThres) uv.x = 1. - uv.x;
			if(ry > truchetThres) uv.y = 1. - uv.y;
			
			float ang = radians(truchetAngle.x + (truchetAngle.y - truchetAngle.x) * random(floor(hc.zw / sca) + truchetSeed / 100. + vec2(0.9843, 0.1636)));
			uv = 0.5 + mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * (uv - 0.5);
		}
		
		colr = texture2D( gm_BaseTexture, uv );
	}
	
	float _aa = 3. / max(dimension.x, dimension.y);
	gl_FragColor = mix(gapCol, colr, aa == 1? smoothstep(thk - _aa, thk, hc.y) : step(thk, hc.y));
} #endregion