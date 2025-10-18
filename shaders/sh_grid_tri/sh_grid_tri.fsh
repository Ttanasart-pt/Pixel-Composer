#pragma use(sampler_simple)

#region -- sampler_simple -- [1729740692.1417658]
    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define c30     (1.0 / 0.86602540378)
#define PI      3.14159265359

uniform vec2  position;
uniform vec2  dimension;
uniform float seed;
uniform int   mode;
uniform int   aa;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      width;
uniform int       widthUseSurf;
uniform sampler2D widthSurf;

uniform vec4  gapCol;
uniform int   gradient_use;
uniform vec2  level;

uniform int   textureTruchet;
uniform float truchetSeed;
uniform float truchetThres;
uniform vec2  truchetAngle;

float random (in vec2 st) { return fract(sin(dot(st.xy + vec2(85.456034, 64.54065), vec2(12.9898, 78.233))) * (43758.5453123 + seed) ); }

#region //////////////////////////////////// GRADIENT ////////////////////////////////////
	#define GRADIENT_LIMIT 128
	
	uniform int		  gradient_blend;
	uniform vec4	  gradient_color[GRADIENT_LIMIT];
	uniform float	  gradient_time[GRADIENT_LIMIT];
	uniform int		  gradient_keys;
	uniform int       gradient_use_map;
	uniform vec4      gradient_map_range;
	uniform sampler2D gradient_map;

	vec3 linearToGamma(vec3 c) { return pow(c, vec3(     2.2)); }
	vec3 gammaToLinear(vec3 c) { return pow(c, vec3(1. / 2.2)); }
	
	vec3 rgbMix(vec3 c1, vec3 c2, float t) { #region
		vec3 k1 = linearToGamma(c1);
		vec3 k2 = linearToGamma(c2);
		
		return gammaToLinear(mix(k1, k2, t));
	} #endregion 
	
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
					float t  = (prog - gradient_time[i - 1]) / (gradient_time[i] - gradient_time[i - 1]);
					vec3  c0 = gradient_color[i - 1].rgb;
					vec3  c1 = gradient_color[i].rgb;
					float a  = mix(gradient_color[i - 1].a, gradient_color[i].a, t);
					
					if(gradient_blend == 0)
						col = vec4(mix(c0, c1, t), a);
						
					else if(gradient_blend == 1)
						col = gradient_color[i - 1];
						
					else if(gradient_blend == 2)
						col = vec4(hsvMix(c0, c1, t), a);
						
					else if(gradient_blend == 3)
						col = vec4(oklabMax(c0, c1, t), a);
					
					else if(gradient_blend == 4)
						col = vec4(rgbMix(c0, c1, t), a);
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

vec3 triGrid(vec2 p) {
    float _stx = (p.x + c30 / 2.0 * p.y);
    float stx  = abs(fract(_stx) - 0.5);
   	
    float _sty = (p.x - c30 / 2.0 * p.y);
    float sty  = abs(fract(_sty) - 0.5);
    float sth  = abs(fract(p.y * c30) - 0.5);
    float sm   = 1.;
    
	float n = min(smoothstep(sm, -sm, stx), min(smoothstep(sm, -sm, sty), smoothstep(sm, -sm, sth)));
	n = (n - .16) / (.35 - .16);
	
    return vec3((floor(_stx) + floor(_sty) + 1.) / 2., floor(p.y * c30), n);
}

void main() {
	#region params
		vec2 sca = scale;
		if(scaleUseSurf == 1) {
			vec4 _vMap = texture2D( scaleSurf, v_vTexcoord );
			sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
		}
		sca = dimension / sca;
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
		
		float wid = width.x;
		if(widthUseSurf == 1) {
			vec4 _vMap = texture2D( widthSurf, v_vTexcoord );
			wid = mix(width.x, width.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
    mat2  rot = mat2(cos(ang), - sin(ang), sin(ang), cos(ang));
	vec2  asp = vec2(dimension.x / dimension.y, 1.);
    vec2  pos = (v_vTexcoord - position) * asp;
    vec2 _pos = pos * rot * sca;
	
	vec3  tri  = triGrid(_pos);
	float dist = max(0., tri.z);
	vec4 colr;
	
	if(mode == 1) {
		dist = (dist - level.x) / (level.y - level.x);
		gl_FragColor = vec4(vec3(dist), 1.);
		return;
	}
	
	if(mode == 0) {
		vec2 uv = tri.xy / sca / vec2(dimension.x / dimension.y, c30);
		     uv = fract(fract(uv) + 1.);
		colr = gradientEval(random(uv));
		
	} else if(mode == 2) {
		vec2 uv  = fract((_pos * vec2(1., c30) - tri.xy) + vec2(0.5, 0.));
		
		if(textureTruchet == 1) {
			float rx  = random(floor(tri.xy) + truchetSeed / 100.);
			float ry  = random(floor(tri.xy) + truchetSeed / 100. + vec2(0.4864, 0.6879));
			float ang = 0.;
			
			if(rx > truchetThres) ang += 120.;
			if(ry > truchetThres) ang += 120.;
			
			ang += truchetAngle.x + (truchetAngle.y - truchetAngle.x) * random(floor(tri.xy) + truchetSeed / 100. + vec2(0.9843, 0.1636));
			ang = radians(ang);
			
			uv = 0.5 + mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * (uv - 0.5);
		}
		
		colr = sampleTexture( gm_BaseTexture, uv );
		
	} else if(mode == 3) {
		vec2 uv = clamp(tri.xy / sca / vec2(dimension.x / dimension.y, c30), 0., 1.);
		colr = sampleTexture( gm_BaseTexture, uv );
	}
	
	float _aa = 3. / max(dimension.x, dimension.y);
	gl_FragColor = mix(gapCol, colr, aa == 1? smoothstep(wid * 2. - _aa, wid * 2., dist) : step(wid * 2., dist));
}